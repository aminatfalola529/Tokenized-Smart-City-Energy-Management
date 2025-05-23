;; Grid Integration Contract
;; Coordinates with utility systems

(define-data-var admin principal tx-sender)
(define-data-var grid-operator principal tx-sender)

;; Grid status: 0 = normal, 1 = peak demand, 2 = surplus, 3 = emergency
(define-data-var grid-status uint u0)
(define-data-var current-grid-capacity uint u0)  ;; in kW
(define-data-var current-grid-demand uint u0)    ;; in kW

;; Building grid participation
(define-map building-grid-participation
  { building-id: (string-utf8 36) }
  {
    can-reduce-load: bool,
    can-feed-in: bool,
    max-reduction: uint,    ;; in kW
    max-feed-in: uint,      ;; in kW
    participation-level: uint  ;; 0 = none, 1 = low, 2 = medium, 3 = high
  }
)

;; Grid events
(define-map grid-events
  { event-id: uint }
  {
    timestamp: uint,
    event-type: uint,  ;; 0 = demand response, 1 = feed-in request
    duration: uint,    ;; in blocks
    compensation-rate: uint,
    active: bool
  }
)

;; Building responses to grid events
(define-map building-responses
  {
    event-id: uint,
    building-id: (string-utf8 36)
  }
  {
    response-type: uint,  ;; 0 = load reduction, 1 = feed-in
    amount: uint,         ;; in kW
    compensation: uint    ;; in tokens
  }
)

;; Update grid status (grid operator only)
(define-public (update-grid-status
    (new-status uint)
    (capacity uint)
    (demand uint))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get grid-operator))
      (begin
        (var-set grid-status new-status)
        (var-set current-grid-capacity capacity)
        (var-set current-grid-demand demand)
        (ok true))
      (err u403))))

;; Register building for grid participation
(define-public (register-for-grid
    (building-id (string-utf8 36))
    (can-reduce-load bool)
    (can-feed-in bool)
    (max-reduction uint)
    (max-feed-in uint)
    (participation-level uint))
  (if (<= participation-level u3)
    (if (map-insert building-grid-participation
          { building-id: building-id }
          {
            can-reduce-load: can-reduce-load,
            can-feed-in: can-feed-in,
            max-reduction: max-reduction,
            max-feed-in: max-feed-in,
            participation-level: participation-level
          })
      (ok true)
      (err u1))
    (err u2)))

;; Create grid event (grid operator only)
(define-public (create-grid-event
    (event-id uint)
    (event-type uint)
    (duration uint)
    (compensation-rate uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (is-eq caller (var-get grid-operator))
      (if (map-insert grid-events
            { event-id: event-id }
            {
              timestamp: current-time,
              event-type: event-type,
              duration: duration,
              compensation-rate: compensation-rate,
              active: true
            })
        (ok true)
        (err u1))
      (err u403))))

;; End grid event (grid operator only)
(define-public (end-grid-event (event-id uint))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get grid-operator))
      (match (map-get? grid-events { event-id: event-id })
        event (begin
          (map-set grid-events
            { event-id: event-id }
            (merge event { active: false }))
          (ok true))
        (err u404))
      (err u403))))

;; Respond to grid event
(define-public (respond-to-event
    (event-id uint)
    (building-id (string-utf8 36))
    (response-type uint)
    (amount uint))
  (let ((caller tx-sender))
    (match (map-get? grid-events { event-id: event-id })
      event (if (get active event)
              (match (map-get? building-grid-participation { building-id: building-id })
                participation (let ((compensation (* amount (get compensation-rate event))))
                  (map-insert building-responses
                    {
                      event-id: event-id,
                      building-id: building-id
                    }
                    {
                      response-type: response-type,
                      amount: amount,
                      compensation: compensation
                    })
                  (ok compensation))
                (err u404))
              (err u2))
      (err u404))))

;; Get current grid status
(define-read-only (get-grid-status)
  {
    status: (var-get grid-status),
    capacity: (var-get current-grid-capacity),
    demand: (var-get current-grid-demand)
  })

;; Get building participation details
(define-read-only (get-building-participation (building-id (string-utf8 36)))
  (map-get? building-grid-participation { building-id: building-id }))

;; Get grid event details
(define-read-only (get-event-details (event-id uint))
  (map-get? grid-events { event-id: event-id }))

;; Get building response to an event
(define-read-only (get-building-response
    (event-id uint)
    (building-id (string-utf8 36)))
  (map-get? building-responses
    {
      event-id: event-id,
      building-id: building-id
    }))

;; Set new grid operator
(define-public (set-grid-operator (new-operator principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (begin
        (var-set grid-operator new-operator)
        (ok true))
      (err u403))))

;; Set new admin
(define-public (set-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (begin
        (var-set admin new-admin)
        (ok true))
      (err u403))))
