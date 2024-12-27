;; MintMuse - NFT Platform for Musicians and Artists

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-listing-not-found (err u102))
(define-constant err-token-not-found (err u103))
(define-constant err-already-listed (err u104))
(define-constant err-insufficient-funds (err u105))

;; Define NFT token
(define-non-fungible-token mint-muse-nft uint)

;; Data Variables
(define-data-var token-id-nonce uint u0)
(define-data-var platform-fee uint u25) ;; 2.5% fee in basis points

;; Data Maps
(define-map token-uris {token-id: uint} {uri: (string-utf8 256)})
(define-map token-metadata 
    {token-id: uint}
    {
        creator: principal,
        royalty-percent: uint,
        title: (string-utf8 64),
        description: (string-utf8 256)
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

;; Public Functions
(define-public (mint-nft (uri (string-utf8 256)) (title (string-utf8 64)) (description (string-utf8 256)) (royalty-percent uint))
    (let
        (
            (token-id (+ (var-get token-id-nonce) u1))
        )
        (try! (nft-mint? mint-muse-nft token-id tx-sender))
        (map-set token-uris {token-id: token-id} {uri: uri})
        (map-set token-metadata 
            {token-id: token-id}
            {
                creator: tx-sender,
                royalty-percent: royalty-percent,
                title: title,
                description: description
            }
        )
        (var-set token-id-nonce token-id)
        (ok token-id)
    )
)

(define-public (list-nft (token-id uint) (price uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? mint-muse-nft token-id) err-token-not-found))
        )
        (asserts! (is-eq tx-sender owner) err-not-token-owner)
        (asserts! (is-none (map-get? token-listings {token-id: token-id})) err-already-listed)
        (map-set token-listings
            {token-id: token-id}
            {
                price: price,
                seller: tx-sender
            }
        )
        (ok true)
    )
)

(define-public (unlist-nft (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? token-listings {token-id: token-id}) err-listing-not-found))
        )
        (asserts! (is-eq tx-sender (get seller listing)) err-not-token-owner)
        (map-delete token-listings {token-id: token-id})
        (ok true)
    )
)

(define-public (buy-nft (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? token-listings {token-id: token-id}) err-listing-not-found))
            (price (get price listing))
            (seller (get seller listing))
            (metadata (unwrap! (map-get? token-metadata {token-id: token-id}) err-token-not-found))
            (royalty-amount (/ (* price (get royalty-percent metadata)) u1000))
            (platform-amount (/ (* price (var-get platform-fee)) u1000))
            (seller-amount (- price (+ royalty-amount platform-amount)))
        )
        ;; Transfer STX payments
        (try! (stx-transfer? royalty-amount tx-sender (get creator metadata)))
        (try! (stx-transfer? platform-amount tx-sender contract-owner))
        (try! (stx-transfer? seller-amount tx-sender seller))
        
        ;; Transfer NFT
        (try! (nft-transfer? mint-muse-nft token-id seller tx-sender))
        
        ;; Remove listing
        (map-delete token-listings {token-id: token-id})
        (ok true)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (let
        (
            (owner (unwrap! (nft-get-owner? mint-muse-nft token-id) err-token-not-found))
        )
        (asserts! (is-eq tx-sender owner) err-not-token-owner)
        (try! (nft-transfer? mint-muse-nft token-id tx-sender recipient))
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-token-uri (token-id uint))
    (ok (get uri (unwrap! (map-get? token-uris {token-id: token-id}) err-token-not-found)))
)

(define-read-only (get-token-metadata (token-id uint))
    (ok (unwrap! (map-get? token-metadata {token-id: token-id}) err-token-not-found))
)

(define-read-only (get-listing (token-id uint))
    (ok (unwrap! (map-get? token-listings {token-id: token-id}) err-listing-not-found))
)

(define-read-only (get-owner (token-id uint))
    (ok (unwrap! (nft-get-owner? mint-muse-nft token-id) err-token-not-found))
)

(define-read-only (get-token-count)
    (ok (var-get token-id-nonce))
)