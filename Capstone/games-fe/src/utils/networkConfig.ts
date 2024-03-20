import { getFullnodeUrl } from "@mysten/sui.js/client";
import {
  DEVNET_SUIGAMES_PACKAGE_ID,
  DEVNET_GAMESPACK_ID,
  DEVNET_HEXGAME_PACKAGE_ID,
  DEVNET_TICTACTOE_PACKAGE_ID,
  TESTNET_SUIGAMES_PACKAGE_ID,
  TESTNET_GAMESPACK_ID,
  TESTNET_HEXGAME_PACKAGE_ID,
  TESTNET_TICTACTOE_PACKAGE_ID,
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
        tictactoePackageId: DEVNET_TICTACTOE_PACKAGE_ID,
        tictactoeType: DEVNET_TICTACTOE_PACKAGE_ID + "::main::TicTacToe",
        tictactoeBoardType: DEVNET_TICTACTOE_PACKAGE_ID + "::board::Board",
      },
    },
    testnet: {
      url: getFullnodeUrl("testnet"),
      variables: {
        suigamesPackageId: TESTNET_SUIGAMES_PACKAGE_ID,
        gamespackId: TESTNET_GAMESPACK_ID,
        hexgamePackageId: TESTNET_HEXGAME_PACKAGE_ID,
        hexgameType: TESTNET_HEXGAME_PACKAGE_ID + "::main::HexGame",
        hexgameBoardType: TESTNET_HEXGAME_PACKAGE_ID + "::board::Board",
        tictactoePackageId: TESTNET_TICTACTOE_PACKAGE_ID,
        tictactoeType: TESTNET_TICTACTOE_PACKAGE_ID + "::main::TicTacToe",
        tictactoeBoardType: TESTNET_TICTACTOE_PACKAGE_ID + "::board::Board",
      },
    },
  });

export { useNetworkVariable, useNetworkVariables, networkConfig };
