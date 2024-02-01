import {
  CoinBalance,
  getFullnodeUrl,
  PaginatedObjectsResponse,
  SuiClient,
  SuiObjectResponse,
} from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import dotenv from "dotenv";
import * as fs from "fs";

export interface IObjectInfo {
  type: string | undefined;
  id: string | undefined;
}

dotenv.config();

export const keypair = Ed25519Keypair.fromSecretKey(
  Uint8Array.from(Buffer.from(process.env.KEY!, "base64")).slice(1)
);

export const client = new SuiClient({ url: getFullnodeUrl("testnet") });

export const getId = (type: string): string | undefined => {
  try {
    const rawData = fs.readFileSync("./created.json", "utf8");
    const parsedData: IObjectInfo[] = JSON.parse(rawData);
    const typeToId = new Map(parsedData.map((item) => [item.type, item.id]));
    return typeToId.get(type);
  } catch (error) {
    console.error("Error reading the created file:", error);
  }
};

export const getAccountForAddress = async (
  addr: string
): Promise<string | undefined> => {
  let hasNextPage = true;
  let nextCursor = null;
  let account = undefined;

  while (hasNextPage) {
    const objects: PaginatedObjectsResponse = await client.getOwnedObjects({
      owner: addr,
      cursor: nextCursor,
      options: { showType: true },
    });

    account = objects.data?.find(
      (obj: SuiObjectResponse) =>
        obj.data?.type === `${getId("package")}::bank::Account`
    );
    if (account !== undefined) break;
    hasNextPage = objects.hasNextPage;
    nextCursor = objects.nextCursor;
  }

  return account?.data?.objectId;
};

export const getSuiDollarBalance = async (): Promise<CoinBalance> => {
  return await client.getBalance({
    owner: keypair.getPublicKey().toSuiAddress(),
    coinType: `${getId("package")}::sui_dollar::SUI_DOLLAR`,
  });
}
