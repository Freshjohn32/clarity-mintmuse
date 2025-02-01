# MintMuse

A decentralized NFT platform built on Stacks that enables musicians and artists to mint and trade their digital creations as NFTs.

## Features
- Mint unique music/art NFTs with metadata
- Create limited edition collections with maximum supply caps
- Batch mint multiple NFTs efficiently
- List NFTs for sale at fixed prices
- Transfer NFTs between users
- Royalty payments to original creators
- View NFT ownership history

## Getting Started

1. Install the dependencies using `clarinet install`
2. Run tests using `clarinet test`
3. Deploy contract using Clarinet console

## Contract Interface

### Collections
- create-collection: Create a new limited edition collection
- mint-collection-nft: Mint an NFT within a collection
- get-collection: Get collection details
- get-collection-tokens: Get tokens in a collection

### Minting
- mint-nft: Create new NFT with metadata
- batch-mint: Mint multiple NFTs in one transaction
- get-token-uri: Get NFT metadata URI

### Trading
- list-nft: List NFT for sale
- unlist-nft: Remove NFT listing
- buy-nft: Purchase listed NFT
- transfer: Transfer NFT ownership

### View Functions  
- get-owner: Get NFT owner
- get-listing: Get NFT listing details
- get-royalty-recipient: Get royalty recipient
- get-token-count: Get total NFTs minted
