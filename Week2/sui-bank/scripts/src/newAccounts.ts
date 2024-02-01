import { TransactionBlock } from "@mysten/sui.js/transactions";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { client, keypair, getId } from "./utils.ts";

const ACCOUNTS_NUM = 3;

(async () => {
  try {
    const tx = new TransactionBlock();

    for (let i = 0; i < ACCOUNTS_NUM; i++) {
      let kp = Ed25519Keypair.generate();

      let [account] = tx.moveCall({
        target: `${getId("package")}::bank::new_account`,
        arguments: [],
      });

      tx.transferObjects([account], kp.getPublicKey().toSuiAddress());
    }

    const result = await client.signAndExecuteTransactionBlock({
      signer: keypair,
      transactionBlock: tx,
      options: {
        showObjectChanges: true,
      },
      requestType: "WaitForLocalExecution",
    });

    console.log("result: ", JSON.stringify(result, null, 2));
  } catch (e) {
    console.log(e);
  }
})();
