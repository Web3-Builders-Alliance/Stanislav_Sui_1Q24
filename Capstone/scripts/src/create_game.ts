import { TransactionBlock } from "@mysten/sui.js/transactions";
import { client, keypair, getSgId, getHexId } from "./utils.ts";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";

(async () => {
  try {
    const txb = new TransactionBlock();

    let accountId =
      "0xfe8802eedd538ad501f028f9641803b2a1f9a3c65846e18dfd3875d9c52eda2c";
    let [coin] = txb.splitCoins(txb.gas, [0]);

    txb.moveCall({
      arguments: [
        txb.object(`${getSgId("games_pack::GamesPack")}`),
        txb.object(accountId),
        txb.pure("0x0000000000000000000000000000000000000000000000000000000000000000"),
        coin,
        txb.object(SUI_CLOCK_OBJECT_ID),
      ],
      target: `${getHexId("package")}::main::create_game`,
    });

    const result = await client.signAndExecuteTransactionBlock({
      signer: keypair,
      transactionBlock: txb,
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
