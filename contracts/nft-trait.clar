;; NFT Trait Contract

(define-trait nft-trait
  (
    ;; Last token ID, limited to uint range
    (get-last-token-id () (response uint uint))

    ;; URI for a token ID
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

    ;; Owner of a token ID
    (get-owner (uint) (response (optional principal) uint))

    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)
