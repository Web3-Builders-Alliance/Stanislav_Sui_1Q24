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

    let obj = await client.getObject({
      id: accountId,
      options: { showContent: true },
    });

    type Account = {
      debt: string;
      deposit: string;
    };

    let deposit = 0;

    if (obj.data?.content?.dataType === "moveObject") {
      deposit = parseInt((obj.data?.content?.fields as Account).deposit);
      console.log(`Account deposit = ${deposit}`);
    }

    const dollar_coins = await client.getCoins({
      owner: keypair.getPublicKey().toSuiAddress(),
      coinType: `${getId("package")}::sui_dollar::SUI_DOLLAR`,
    });

    // console.log(dollar_coins);

    const dollar_coins_object = dollar_coins.data.map((coin) =>
      txb.object(coin.coinObjectId)
    );

    if (dollar_coins_object.length > 1) {
      txb.mergeCoins(dollar_coins_object[0], [...dollar_coins_object.slice(1)]);
    }
    // console.log(txb);

    txb.moveCall({
      target: `${getId("package")}::bank::repay`,
      arguments: [
        account,
        txb.object(`${getId("sui_dollar::CapWrapper")}`),
        dollar_coins_object[0],
      ],
    });

    let [coin] = txb.moveCall({
      target: `${getId("package")}::bank::withdraw`,
      arguments: [
        txb.object(`${getId("bank::Bank")}`),
        account,
        txb.pure(deposit),
      ],
    });

    txb.transferObjects([coin], keypair.getPublicKey().toSuiAddress());

    txb.moveCall({
      target: `${getId("package")}::bank::destroy_empty_account`,
      arguments: [account],
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
