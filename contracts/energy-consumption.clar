;; Energy Consumption Contract
;; Tracks usage patterns for buildings

(define-data-var admin principal tx-sender)

;; Energy consumption records
(define-map energy-consumption
  {
    building-id: (string-utf8 36),
    timestamp: uint
  }
  {
    kwh: uint,
    peak-load: uint,
    recorded-by: principal
  }
)

;; Total consumption per building
(define-map building-totals
  { building-id: (string-utf8 36) }
  {
    total-kwh: uint,
    readings-count: uint,
    last-updated: uint
  }
)

;; Record energy consumption
(define-public (record-consumption
    (building-id (string-utf8 36))
    (kwh uint)
    (peak-load uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (begin
      ;; Record the consumption data
      (map-insert energy-consumption
        {
          building-id: building-id,
          timestamp: current-time
        }
        {
          kwh: kwh,
          peak-load: peak-load,
          recorded-by: caller
        })

      ;; Update the building totals
      (match (map-get? building-totals { building-id: building-id })
        existing-total (map-set building-totals
          { building-id: building-id }
          {
            total-kwh: (+ (get total-kwh existing-total) kwh),
            readings-count: (+ (get readings-count existing-total) u1),
            last-updated: current-time
          })
        (map-insert building-totals
          { building-id: building-id }
          {
            total-kwh: kwh,
            readings-count: u1,
            last-updated: current-time
          }))

      (ok true))))

;; Get consumption for a specific time
(define-read-only (get-consumption
    (building-id (string-utf8 36))
    (timestamp uint))
  (map-get? energy-consumption
    {
      building-id: building-id,
      timestamp: timestamp
    }))

;; Get building consumption totals
(define-read-only (get-building-totals (building-id (string-utf8 36)))
  (map-get? building-totals { building-id: building-id }))

;; Calculate average consumption
(define-read-only (get-average-consumption (building-id (string-utf8 36)))
  (match (map-get? building-totals { building-id: building-id })
    totals (if (> (get readings-count totals) u0)
             (/ (get total-kwh totals) (get readings-count totals))
             u0)
    u0))

;; Set new admin
(define-public (set-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (begin
        (var-set admin new-admin)
        (ok true))
      (err u1))))
