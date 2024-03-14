import { getFullnodeUrl } from "@mysten/sui.js/client";
import {
  DEVNET_SUIGAMES_PACKAGE_ID,
  DEVNET_GAMESPACK_ID,
  DEVNET_HEXGAME_PACKAGE_ID,
} from "./constants";
import { createNetworkConfig } from "@mysten/dapp-kit";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
  createNetworkConfig({
    devnet: {
      url: getFullnodeUrl("devnet"),
      variables: {
        suigamesPackageId: DEVNET_SUIGAMES_PACKAGE_ID,
        gamespackId: DEVNET_GAMESPACK_ID,
        hexgamePackageId: DEVNET_HEXGAME_PACKAGE_ID,
        hexgameType: DEVNET_HEXGAME_PACKAGE_ID + "::main::HexGame",
        hexgameBoardType: DEVNET_HEXGAME_PACKAGE_ID + "::board::Board",
      },
    },
  });

export { useNetworkVariable, useNetworkVariables, networkConfig };
