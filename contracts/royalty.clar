;; Royalty Contract

(define-map creator-royalties
  { token-id: uint, nft-contract: principal }
  { creator: principal, percentage: uint }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant MAX_PERCENTAGE u1000) ;; 10% in basis points

(define-public (set-royalty (token-id uint) (nft-contract principal) (creator principal) (percentage uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (<= percentage MAX_PERCENTAGE) ERR_NOT_AUTHORIZED)
    (map-set creator-royalties
      { token-id: token-id, nft-contract: nft-contract }
      { creator: creator, percentage: percentage }
    )
    (ok true)
  )
)

(define-read-only (get-royalty (token-id uint) (nft-contract principal))
  (map-get? creator-royalties { token-id: token-id, nft-contract: nft-contract })
)

(define-public (pay-royalty (token-id uint) (nft-contract principal) (sale-amount uint))
  (let
    ((royalty-info (unwrap! (get-royalty token-id nft-contract) (ok u0))))
    (if (> (get percentage royalty-info) u0)
      (let
        ((royalty-amount (/ (* sale-amount (get percentage royalty-info)) u10000)))
        (try! (stx-transfer? royalty-amount tx-sender (get creator royalty-info)))
        (ok royalty-amount)
      )
      (ok u0)
    )
  )
)
