module hex_game::main {
    // === Imports ===

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use hex_game::board::{Self, Board};

    // === Friends ===

    // === Errors ===

    const ESamePlayer: u64 = 0;
    const EAlreadyJoined: u64 = 1;
    const EAlreadyStarted: u64 = 2;
    const EWrongOpponent: u64 = 3;
    // const ENotYourTurn: u64 = 4;
    // const EGameAlreadyOver: u64 = 5;

    // === Constants ===

    // should be < 16
    const BOARD_SIZE: u8 = 11;

    // === Structs ===

    struct HexGame has drop {}

    struct Game has key, store {
        id: UID,
        player1: address,
        player2: address,
        board: Board,
        is_first_player_turn: bool,
        is_started: bool,
        winner_index: u8,
    }

    // struct Games has key {
    //     id: UID,
    //     available_games: Table<ID, Game>,
    // }

    // === Public-Mutative Functions ===

    #[allow(lint(share_owned))]
    public fun create_game(opponent: address, ctx: &mut TxContext) {
        let player1 = tx_context::sender(ctx);
        let player2 = opponent;
        assert!(player1 != player2, ESamePlayer);
        let game = create_game_intl(player1, player2, BOARD_SIZE, ctx);
        transfer::share_object(game);
    }

    public fun join_game(game: &mut Game, ctx: &mut TxContext) {
        let player2 = tx_context::sender(ctx);
        assert!(player2 != game.player1, EAlreadyJoined);
        assert!(!game.is_started, EAlreadyStarted);
        assert!(game.player2 == @0 || game.player2 == player2, EWrongOpponent);
        game.player2 = player2;
        game.is_started = true;
    }

    // public fun make_move(game: &mut Game, tile: u8) {

    // }

    // public fun declare_win(game: &mut Game, tile: u8, path: vector<u8>) {

    // }

    // public fun give_up(game: &mut Game) {

    // }

     // === Private Functions ===

    fun create_game_intl(player1: address, player2: address, board_size: u8, ctx: &mut TxContext): Game {
        Game {
            id: object::new(ctx),
            player1: player1,
            player2: player2,
            board: board::create_board(board_size),
            is_first_player_turn: true,
            is_started: false,
            winner_index: 0,
        }
    }


}