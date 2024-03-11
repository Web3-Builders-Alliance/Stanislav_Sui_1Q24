import type { SuiObjectData } from "@mysten/sui.js/client";

export function getAccountFields(data: SuiObjectData) {
  if (data.content?.dataType !== "moveObject") {
    return null;
  }

  return data.content.fields as { created_at: number; name: string };
}
