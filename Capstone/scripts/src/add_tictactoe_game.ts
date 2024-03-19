import { TransactionBlock } from "@mysten/sui.js/transactions";
import { client, keypair, getSgId, getHexId } from "./utils.ts";

(async () => {
  try {
    const txb = new TransactionBlock();

    txb.moveCall({
      target: `${getSgId("package")}::games_pack::add_game_type`,
      arguments: [
        txb.object(`${getSgId("games_pack::AdminCap")}`),
        txb.object(`${getSgId("games_pack::GamesPack")}`),
      ],
      typeArguments: [`${getHexId("package")}::main::TicTacToe`],
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
