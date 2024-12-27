import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can mint NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-nft', [
        types.utf8("ipfs://Qm..."),
        types.utf8("My First Song"),
        types.utf8("An amazing song"),
        types.uint(50) // 5% royalty
      ], wallet1.address)
    ]);
    
    // Assert successful mint
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].result, types.ok(types.uint(1)));
    
    // Verify ownership
    let ownerBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'get-owner', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    assertEquals(
      ownerBlock.receipts[0].result.expectOk(),
      wallet1.address
    );
  }
});

Clarinet.test({
  name: "Test NFT marketplace functions",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const seller = accounts.get('wallet_1')!;
    const buyer = accounts.get('wallet_2')!;
    
    // First mint an NFT
    let mintBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'mint-nft', [
        types.utf8("ipfs://Qm..."),
        types.utf8("Test Song"),
        types.utf8("Test Description"),
        types.uint(50)
      ], seller.address)
    ]);
    
    // List NFT for sale
    let listBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'list-nft', [
        types.uint(1),
        types.uint(100000000) // 100 STX
      ], seller.address)
    ]);
    
    listBlock.receipts[0].result.expectOk();
    
    // Verify listing
    let listingBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'get-listing', [
        types.uint(1)
      ], buyer.address)
    ]);
    
    let listing = listingBlock.receipts[0].result.expectOk();
    assertEquals(listing.price, types.uint(100000000));
    assertEquals(listing.seller, seller.address);
    
    // Buy NFT
    let buyBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'buy-nft', [
        types.uint(1)
      ], buyer.address)
    ]);
    
    buyBlock.receipts[0].result.expectOk();
    
    // Verify new owner
    let ownerBlock = chain.mineBlock([
      Tx.contractCall('mint-muse', 'get-owner', [
        types.uint(1)
      ], buyer.address)
    ]);
    
    assertEquals(
      ownerBlock.receipts[0].result.expectOk(),
      buyer.address
    );
  }
});