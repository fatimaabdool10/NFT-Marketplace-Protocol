;; Escrow Contract

(define-map escrows
  { escrow-id: uint }
  {
    buyer: principal,
    seller: principal,
    amount: uint,
    token-id: uint,
    nft-contract: principal,
    status: (string-ascii 20)
  }
)

(define-data-var escrow-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u400))

(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

(define-public (create-escrow (buyer principal) (seller principal) (amount uint) (token-id uint) (nft-contract principal))
  (let
    ((new-escrow-id (+ (var-get escrow-nonce) u1)))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows
      { escrow-id: new-escrow-id }
      {
        buyer: buyer,
        seller: seller,
        amount: amount,
        token-id: token-id,
        nft-contract: nft-contract,
        status: "pending"
      }
    )
    (var-set escrow-nonce new-escrow-id)
    (ok new-escrow-id)
  )
)

(define-public (release-escrow (escrow-id uint))
  (let
    ((escrow (unwrap! (get-escrow escrow-id) ERR_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get buyer escrow)) (is-eq tx-sender CONTRACT_OWNER)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status escrow) "pending") ERR_INVALID_STATUS)
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "released" })
    )
    (ok true)
  )
)

(define-public (refund-escrow (escrow-id uint))
  (let
    ((escrow (unwrap! (get-escrow escrow-id) ERR_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get seller escrow)) (is-eq tx-sender CONTRACT_OWNER)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status escrow) "pending") ERR_INVALID_STATUS)
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get buyer escrow))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "refunded" })
    )
    (ok true)
  )
)

