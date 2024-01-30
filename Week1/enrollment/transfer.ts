import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import wallet from "./dev-wallet.json";

// Import our dev wallet keypair from the wallet file
const keypair = Ed25519Keypair.fromSecretKey(new Uint8Array(wallet.privateKey));

// Define our WBA SUI Address
const to = "0x869f44bf444f1a4aa432c9f0dc4234984eb234b8e5957626cf4bda403b3ab1a7";

//Create a Sui testnet client
const client = new SuiClient({ url: getFullnodeUrl("testnet") });

(async () => {
  try {
    //create Transaction Block.
    const txb = new TransactionBlock();
    //Split coins
    // let [coin] = txb.splitCoins(txb.gas, [1000]);
    //Add a transferObject transaction
    // txb.transferObjects([coin], to);
    txb.transferObjects([txb.gas], to);
    let txid = await client.signAndExecuteTransactionBlock({
      signer: keypair,
      transactionBlock: txb,
    });
    console.log(`Success! Check our your TX here:
        https://suiexplorer.com/txblock/${txid.digest}?network=testnet`);
  } catch (e) {
    console.error(`Oops, something went wrong: ${e}`);
  }
})();
