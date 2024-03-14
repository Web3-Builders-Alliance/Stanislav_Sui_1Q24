import { TransactionBlock } from "@mysten/sui.js/transactions";
import { client, keypair, getSgId, getHexId } from "./utils.ts";

(async () => {
  try {
    const txb = new TransactionBlock();

    let accountId =
      "0xfe8802eedd538ad501f028f9641803b2a1f9a3c65846e18dfd3875d9c52eda2c";
    let gameId =
      "0xc4f047252be3a0afd748c23f3fa703d0cf1c2cb27043c2c84f6e73fa89f30708";

    let [coin, state] = txb.moveCall({
      arguments: [
        txb.object(gameId),
        txb.object(`${getSgId("games_pack::GamesPack")}`),
        txb.object(accountId),
      ],
      target: `${getSgId("package")}::game::cancel_game`,
      typeArguments: [
        `${getHexId("package")}::main::HexGame`,
        `${getHexId("package")}::board::Board`,
      ],
    });

    txb.transferObjects([coin], keypair.toSuiAddress());

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
