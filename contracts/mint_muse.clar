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

;; Define NFT token
(define-non-fungible-token mint-muse-nft uint)

;; Data Variables 
(define-data-var token-id-nonce uint u0)
(define-data-var platform-fee uint u25) ;; 2.5% fee in basis points
(define-data-var collection-id-nonce uint u0)

;; Data Maps
(define-map token-uris {token-id: uint} {uri: (string-utf8 256)})
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

(define-map collections
    {collection-id: uint}
    {
        name: (string-utf8 64),
        creator: principal,
        description: (string-utf8 256),
        token-count: uint,
        max-supply: uint
    }
)

(define-map token-listings
    {token-id: uint}
    {
        price: uint,
        seller: principal
    }
)

;; Private Functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? mint-muse-nft token-id) false))
)

(define-private (mint-single 
    (uri (string-utf8 256)) 
    (title (string-utf8 64)) 
    (description (string-utf8 256)) 
    (royalty-percent uint)
    (collection-id (optional uint))
)
    (let
        (
            (token-id (+ (var-get token-id-nonce) u1))
        )
        ;; Update collection if specified
        (match collection-id collection-id-some
            (let ((collection (unwrap! (map-get? collections {collection-id: collection-id-some}) err-invalid-collection)))
                (asserts! (< (get token-count collection) (get max-supply collection)) err-collection-limit)
                (map-set collections 
                    {collection-id: collection-id-some}
                    (merge collection {token-count: (+ (get token-count collection) u1)})
                )
            )
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

;; Public Functions
(define-public (create-collection (name (string-utf8 64)) (description (string-utf8 256)) (max-supply uint))
    (let
        (
            (collection-id (+ (var-get collection-id-nonce) u1))
        )
        (map-set collections
            {collection-id: collection-id}
            {
                name: name,
                creator: tx-sender,
                description: description,
                token-count: u0,
                max-supply: max-supply
            }
        )
        (var-set collection-id-nonce collection-id)
        (ok collection-id)
    )
)

(define-public (mint-nft (uri (string-utf8 256)) (title (string-utf8 64)) (description (string-utf8 256)) (royalty-percent uint))
    (mint-single uri title description royalty-percent none)
)

(define-public (mint-collection-nft 
    (uri (string-utf8 256)) 
    (title (string-utf8 64)) 
    (description (string-utf8 256)) 
    (royalty-percent uint)
    (collection-id uint)
)
    (mint-single uri title description royalty-percent (some collection-id))  
)

(define-public (batch-mint 
    (uris (list 200 (string-utf8 256)))
    (titles (list 200 (string-utf8 64)))
    (descriptions (list 200 (string-utf8 256)))
    (royalty-percents (list 200 uint))
)
    (let
        ((entries (fold add-entry-to-result (list) uris titles descriptions royalty-percents)))
        (ok entries)
    )
)

(define-private (add-entry-to-result 
    (uri (string-utf8 256))
    (title (string-utf8 64))
    (description (string-utf8 256))
    (royalty-percent uint)
    (result (list 200 uint))
)
    (unwrap-panic (mint-single uri title description royalty-percent none))
)

;; Existing functions remain unchanged...
;; [Previous list-nft, unlist-nft, buy-nft, transfer functions]

;; New read-only functions
(define-read-only (get-collection (collection-id uint))
    (ok (unwrap! (map-get? collections {collection-id: collection-id}) err-invalid-collection))
)

(define-read-only (get-collection-tokens (collection-id uint))
    (ok (unwrap! (map-get? collections {collection-id: collection-id}) err-invalid-collection))
)
