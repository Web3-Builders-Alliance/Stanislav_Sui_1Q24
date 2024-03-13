import type { MoveValue, SuiObjectData } from "@mysten/sui.js/client";

export function getAccountFields(data: SuiObjectData) {
  if (data.content?.dataType !== "moveObject") {
    return null;
  }

  return data.content.fields as { created_at: number; name: string };
}

export type Game = {
  bet: number;
  created_at: number;
  game_state: {
    fields: {
      [key: string]: MoveValue;
    };
  };
  is_first_player_turn: boolean;
  is_started: boolean;
  is_swapable: boolean;
  player1: string;
  player2: string;
  turn_number: number;
  winner_index: number;
};

export function getGameFields(data: SuiObjectData) {
  if (data.content?.dataType !== "moveObject") {
    return null;
  }

  return data.content.fields as Game;
}

export function getBoardFromState(data: {
  fields: {
    [key: string]: MoveValue;
  };
}) {
  return data.fields as { field: [number]; size: number };
}

export function getGamesFromGamepack(data: SuiObjectData, gameType: string) {
  if (data.content?.dataType !== "moveObject") {
    return null;
  }

  // @ts-ignore
  let games = data.content.fields.games.fields.contents as [];

  for (let game of games) {
    // @ts-ignore
    if (game.fields.key.fields.name == gameType.slice(2)) {
      // @ts-ignore
      return game.fields.value.fields.id.id;
    }
  }
}
