// [Previous test imports and setup remain unchanged...]

Clarinet.test({
  name: "Test royalty validation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const artist = accounts.get('wallet_1')!;
    
    // Test invalid royalty
    let invalidRoyaltyBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-nft', [
        types.utf8("ipfs://Qm..."),
        types.utf8("Invalid Royalty"),
        types.utf8("Should fail"),
        types.uint(101) // Invalid royalty > 100
      ], artist.address)
    ]);
    
    invalidRoyaltyBlock.receipts[0].result.expectErr(108); // err-invalid-royalty
  }
});

// [Previous tests remain unchanged...]

Clarinet.test({
  name: "Test collection supply limits",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const artist = accounts.get('wallet_1')!;
    
    // Create collection with limit 1
    let createBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'create-collection', [
        types.utf8("Limited Collection"),
        types.utf8("Test supply limit"),
        types.uint(1)
      ], artist.address)
    ]);
    
    createBlock.receipts[0].result.expectOk();
    
    // Mint first token (should succeed)
    let mintBlock1 = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-collection-nft', [
        types.utf8("ipfs://Qm1..."),
        types.utf8("Token 1"),
        types.utf8("First token"),
        types.uint(50),
        types.uint(1)
      ], artist.address)
    ]);
    
    mintBlock1.receipts[0].result.expectOk();
    
    // Attempt to mint second token (should fail)
    let mintBlock2 = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-collection-nft', [
        types.utf8("ipfs://Qm2..."),
        types.utf8("Token 2"),
        types.utf8("Second token"),
        types.uint(50),
        types.uint(1)
      ], artist.address)
    ]);
    
    mintBlock2.receipts[0].result.expectErr(107); // err-collection-limit
  }
});
