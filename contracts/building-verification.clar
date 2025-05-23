;; Building Verification Contract
;; Validates urban structures and their energy profiles

(define-data-var admin principal tx-sender)

;; Building status: 0 = unverified, 1 = verified, 2 = rejected
(define-map buildings
  { building-id: (string-utf8 36) }
  {
    owner: principal,
    status: uint,
    energy-class: (string-utf8 2),
    verification-date: uint,
    square-meters: uint
  }
)

;; Register a new building
(define-public (register-building
    (building-id (string-utf8 36))
    (energy-class (string-utf8 2))
    (square-meters uint))
  (let ((caller tx-sender))
    (if (map-insert buildings
          { building-id: building-id }
          {
            owner: caller,
            status: u0,
            energy-class: energy-class,
            verification-date: u0,
            square-meters: square-meters
          })
        (ok true)
        (err u1))))

;; Verify a building (admin only)
(define-public (verify-building
    (building-id (string-utf8 36)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (match (map-get? buildings { building-id: building-id })
        building (begin
          (map-set buildings
            { building-id: building-id }
            (merge building {
              status: u1,
              verification-date: block-height
            }))
          (ok true))
        (err u2))
      (err u3))))

;; Reject a building (admin only)
(define-public (reject-building
    (building-id (string-utf8 36)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (match (map-get? buildings { building-id: building-id })
        building (begin
          (map-set buildings
            { building-id: building-id }
            (merge building {
              status: u2,
              verification-date: block-height
            }))
          (ok true))
        (err u2))
      (err u3))))

;; Get building details
(define-read-only (get-building-details (building-id (string-utf8 36)))
  (map-get? buildings { building-id: building-id }))

;; Transfer building ownership
(define-public (transfer-building
    (building-id (string-utf8 36))
    (new-owner principal))
  (let ((caller tx-sender))
    (match (map-get? buildings { building-id: building-id })
      building (if (is-eq (get owner building) caller)
                 (begin
                   (map-set buildings
                     { building-id: building-id }
                     (merge building { owner: new-owner }))
                   (ok true))
                 (err u4))
      (err u2))))

;; Set new admin
(define-public (set-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (begin
        (var-set admin new-admin)
        (ok true))
      (err u3))))
