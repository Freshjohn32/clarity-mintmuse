# MintMuse

A decentralized NFT platform built on Stacks that enables musicians and artists to mint and trade their digital creations as NFTs.

## Features
- Mint unique music/art NFTs with metadata
- List NFTs for sale at fixed prices
- Transfer NFTs between users
- Royalty payments to original creators
- View NFT ownership history

## Getting Started

1. Install the dependencies using `clarinet install`
2. Run tests using `clarinet test`
3. Deploy contract using Clarinet console

## Contract Interface

### Minting
- mint-nft: Create new NFT with metadata
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