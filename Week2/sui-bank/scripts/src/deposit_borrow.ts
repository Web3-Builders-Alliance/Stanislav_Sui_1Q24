import { TransactionBlock } from "@mysten/sui.js/transactions";
import {
  client,
  keypair,
  getId,
  getAccountForAddress,
  getSuiDollarBalance,
} from "./utils.ts";

(async () => {
  try {
    const txb = new TransactionBlock();

    const accountId = await getAccountForAddress(
      keypair.getPublicKey().toSuiAddress()
    );

    if (accountId === undefined) {
      console.log("No account");
      return;
    }
    let account = txb.object(accountId);

    let [coin] = txb.splitCoins(txb.gas, [txb.pure(1000)]);

    txb.moveCall({
      target: `${getId("package")}::bank::deposit`,
      arguments: [txb.object(`${getId("bank::Bank")}`), account, coin],
    });

    let [dollar_coin] = txb.moveCall({
      target: `${getId("package")}::bank::borrow`,
      arguments: [
        account,
        txb.object(`${getId("sui_dollar::CapWrapper")}`),
        txb.pure(100),
      ],
    });

    txb.transferObjects([dollar_coin], keypair.getPublicKey().toSuiAddress());

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
  } finally {
    const sd_bal = await getSuiDollarBalance();
    console.log(sd_bal);
  }
})();
