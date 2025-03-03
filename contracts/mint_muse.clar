;; MintMuse - NFT Platform for Musicians and Artists

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-listing-not-found (err u102))
(define-constant err-token-not-found (err u103))
(define-constant err-already-listed (err u104))
(define-constant err-insufficient-funds (err u105))
(define-constant err-invalid-collection (err u106))
(define-constant err-collection-limit (err u107))
(define-constant err-invalid-royalty (err u108))
(define-constant err-invalid-input (err u109))
(define-constant err-mint-failed (err u110))

;; Define NFT token
(define-non-fungible-token mint-muse-nft uint)

;; Data Variables
(define-data-var token-id-nonce uint u0)

;; Maps
(define-map token-uris 
    {token-id: uint} 
    {uri: (string-utf8 256)}
)

(define-map token-metadata
    {token-id: uint}
    {
        creator: principal,
        royalty-percent: uint,
        title: (string-utf8 64),
        description: (string-utf8 256),
        collection-id: (optional uint)
    }
)

;; Helper Functions
(define-private (validate-royalty (royalty-percent uint))
  (and (>= royalty-percent u0) (<= royalty-percent u100))
)

(define-private (update-collection-count (collection-id uint))
  (let ((collection (unwrap! (map-get? collections {collection-id: collection-id}) err-invalid-collection)))
    (asserts! (< (get token-count collection) (get max-supply collection)) err-collection-limit)
    (ok (map-set collections 
        {collection-id: collection-id}
        (merge collection {token-count: (+ (get token-count collection) u1)})
    ))
  )
)

(define-private (mint-single 
    (uri (string-utf8 256)) 
    (title (string-utf8 64)) 
    (description (string-utf8 256)) 
    (royalty-percent uint)
    (collection-id (optional uint))
)
    (begin
        (asserts! (validate-royalty royalty-percent) err-invalid-royalty)
        (let
            ((token-id (+ (var-get token-id-nonce) u1)))
            
            ;; Update collection if specified
            (match collection-id collection-id-some
                (try! (update-collection-count collection-id-some))
                true
            )
            
            (try! (nft-mint? mint-muse-nft token-id tx-sender))
            (map-set token-uris {token-id: token-id} {uri: uri})
            (map-set token-metadata 
                {token-id: token-id}
                {
                    creator: tx-sender,
                    royalty-percent: royalty-percent,
                    title: title,
                    description: description,
                    collection-id: collection-id
                }
            )
            (var-set token-id-nonce token-id)
            (ok token-id)
        )
    )
)

(define-private (add-entry-to-result 
    (uri (string-utf8 256))
    (title (string-utf8 64))
    (description (string-utf8 256))
    (royalty-percent uint)
    (acc (list 200 (response uint uint)))
)
    (append acc (list (mint-single uri title description royalty-percent none)))
)

(define-public (batch-mint 
    (uris (list 200 (string-utf8 256)))
    (titles (list 200 (string-utf8 64)))
    (descriptions (list 200 (string-utf8 256)))
    (royalty-percents (list 200 uint))
)
    (begin
        (asserts! (and 
            (is-eq (len uris) (len titles))
            (is-eq (len titles) (len descriptions))
            (is-eq (len descriptions) (len royalty-percents))
        ) err-invalid-input)
        (ok (fold add-entry-to-result 
            uris titles descriptions royalty-percents 
            (list)))
    )
)

;; Read-only functions
(define-read-only (get-token-metadata (token-id uint))
    (ok (unwrap! (map-get? token-metadata {token-id: token-id}) err-token-not-found))
)

(define-read-only (get-collection-tokens (collection-id uint))
    (let ((collection (unwrap! (map-get? collections {collection-id: collection-id}) err-invalid-collection)))
        (ok {
            collection: collection,
            tokens: (filter get-collection-token-ids (var-get token-id-nonce))
        })
    )
)

(define-private (get-collection-token-ids (token-id uint))
    (match (get collection-id (unwrap! (map-get? token-metadata {token-id: token-id}) false))
        target-id (is-some target-id)  ;; Fixed comparison
        false
    )
)
