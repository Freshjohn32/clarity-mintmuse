import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// Previous tests remain...

Clarinet.test({
  name: "Test collection creation and minting",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const artist = accounts.get('wallet_1')!;
    
    // Create collection
    let createCollectionBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'create-collection', [
        types.utf8("Summer Album"),
        types.utf8("Limited edition summer tracks"),
        types.uint(100)
      ], artist.address)
    ]);
    
    createCollectionBlock.receipts[0].result.expectOk();
    assertEquals(createCollectionBlock.receipts[0].result, types.ok(types.uint(1)));
    
    // Mint NFT in collection
    let mintBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-collection-nft', [
        types.utf8("ipfs://Qm..."),
        types.utf8("Summer Song #1"),
        types.utf8("First track of summer"),
        types.uint(50),
        types.uint(1)
      ], artist.address)
    ]);
    
    mintBlock.receipts[0].result.expectOk();
    
    // Verify collection data
    let collectionBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'get-collection', [
        types.uint(1)
      ], artist.address)
    ]);
    
    let collection = collectionBlock.receipts[0].result.expectOk();
    assertEquals(collection.token_count, types.uint(1));
  }
});

Clarinet.test({
  name: "Test batch minting",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const artist = accounts.get('wallet_1')!;
    
    let batchBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'batch-mint', [
        types.list([
          types.utf8("ipfs://Qm1..."),
          types.utf8("ipfs://Qm2..."),
          types.utf8("ipfs://Qm3...")
        ]),
        types.list([
          types.utf8("Song 1"),
          types.utf8("Song 2"), 
          types.utf8("Song 3")
        ]),
        types.list([
          types.utf8("Description 1"),
          types.utf8("Description 2"),
          types.utf8("Description 3")  
        ]),
        types.list([
          types.uint(50),
          types.uint(50),
          types.uint(50)
        ])
      ], artist.address)
    ]);
    
    batchBlock.receipts[0].result.expectOk();
    
    // Verify ownership of batch minted tokens
    for (let i = 1; i <= 3; i++) {
      let ownerBlock = chain.mineBlock([
        Tx.contractCall('mint-muse', 'get-owner', [
          types.uint(i)
        ], artist.address)
      ]);
      assertEquals(
        ownerBlock.receipts[0].result.expectOk(),
        artist.address
      );
    }
  }
});
