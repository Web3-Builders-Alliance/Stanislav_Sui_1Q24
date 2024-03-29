module hex_game::main {
    // === Imports ===

    use sui::tx_context::{TxContext};
    use sui::coin::Coin;
    use sui::sui::SUI;
    use sui::clock::Clock;

    use sui_games::game::{Self, Game};
    use sui_games::games_pack::GamesPack;
    use sui_games::account::Account;

    use hex_game::board::{Self, Board};

    // === Friends ===

    // === Errors ===

    const ETileAlreadyTaken: u64 = 0;
    const EWrongPath: u64 = 1;

    // === Constants ===

    // should be < 16
    const BOARD_SIZE: u8 = 11;

    // === Structs ===

    struct HexGame has drop {}

    // === Public-Mutative Functions ===

    public fun create_game(
        games: &mut GamesPack,
        player: &Account,
        opponent: address,
        bet: Coin<SUI>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let board = board::create_board(BOARD_SIZE);
        game::create_game(
            games,
            HexGame {},
            true,
            false,
            board,
            player,
            opponent,
            bet,
            clock,
            ctx
        );
    }

    public fun make_move(game: &mut Game<HexGame, Board>, player: &Account, tile: u8) {
        let (board, player_num) = game::make_move(game, player, HexGame {});

        assert!(board::is_tile_free(board, tile), ETileAlreadyTaken);

        board::set_tile(board, tile, player_num);
    }

    public fun swap_sides(game: &mut Game<HexGame, Board>, player: &Account) {
        game::swap_sides(game, player, HexGame {});
    }

    public fun give_up(game: &mut Game<HexGame, Board>, games_pack: &mut GamesPack, player: &Account) {
        game::give_up(game, games_pack, player, HexGame {});
    }

    public fun declare_win(game: &mut Game<HexGame, Board>, games_pack: &mut GamesPack, player: &Account, path: vector<u8>) {
        let (board, player_num, winner_request) = sui_games::game::get_state_to_win(game, player, HexGame {});

        assert!(board::is_path_correct(board, &path, player_num), EWrongPath);
        game::declare_win(game, games_pack, winner_request, HexGame {});
    }


    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}