// [Previous test imports and setup]

Clarinet.test({
  name: "Test batch minting functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const artist = accounts.get('wallet_1')!;
    
    // Test batch mint with 2 tokens
    let batchMintBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'batch-mint', [
        types.list([
          types.utf8("ipfs://Qm1..."),
          types.utf8("ipfs://Qm2...")
        ]),
        types.list([
          types.utf8("Token 1"),
          types.utf8("Token 2")
        ]),
        types.list([
          types.utf8("First token"),
          types.utf8("Second token")
        ]),
        types.list([
          types.uint(50),
          types.uint(50)
        ])
      ], artist.address)
    ]);
    
    batchMintBlock.receipts[0].result.expectOk();
    
    // Verify both tokens were minted
    let token1Metadata = chain.callReadOnlyFn(
      'mint-muse',
      'get-token-metadata',
      [types.uint(1)],
      artist.address
    );
    
    let token2Metadata = chain.callReadOnlyFn(
      'mint-muse',
      'get-token-metadata',
      [types.uint(2)],
      artist.address
    );
    
    token1Metadata.result.expectOk();
    token2Metadata.result.expectOk();
  }
});

// [Previous tests remain unchanged]
