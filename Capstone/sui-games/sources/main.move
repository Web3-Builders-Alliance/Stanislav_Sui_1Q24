module sui_games::main {
    // === Imports ===

    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    // use sui::clock::{Self, Clock};
    use sui::vec_map::{Self, VecMap};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    // use sui::event;

    use sui_games::user::{User};


    // === Friends ===

    // === Errors ===
    const EGameAlreadyAdded: u64 = 0;
    const EGameDoesNotExist: u64 = 1;
    const ESamePlayer: u64 = 2;
    const EWrongBet: u64 = 3;
    const EAlreadyJoined: u64 = 4;
    const EWrongPlayer: u64 = 5;
    const EAlreadyStarted: u64 = 6;
    const ENotStarted: u64 = 7;
    const EGameAlreadyOver: u64 = 8;
    const ENotSwapable: u64 = 9;
    const ENotFirstTurn: u64 = 10;
    const EWrongGame: u64 = 11;

    // === Constants ===

    // === Structs ===

    struct AdminCap has key, store {
        id: UID,
    }

    struct GameStats has store, drop {
        games_played: u64
    }

    struct Game<phantom GAME_TYPE, STATE> has key {
        id: UID,
        player1: address,
        player2: address,
        is_first_player_turn: bool,
        // pie (swap) rule can be used is the first turn
        is_swapable: bool,
        turn_number: u32,
        is_started: bool,
        winner_index: u8,
        bet: Balance<SUI>,
        game_state: STATE
    }

    struct WinnerRequest {
        game_id: ID,
        winner_index: u8
    }

    struct Games has key {
        id: UID,
        game_types: VecMap<TypeName, GameStats>
    }

    // === Init ===

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap {id: object::new(ctx)},
            tx_context::sender(ctx)
        );

        transfer::share_object(Games {
            id: object::new(ctx),
            game_types: vec_map::empty()
        });
    }

    // === Public-Mutative Functions ===

    public fun create_game<GAME_TYPE: drop, STATE: store>(
        self: &Games,
        _: GAME_TYPE,
        is_swapable: bool,
        game_state: STATE,
        player1: &User,
        opponent: address,
        bet: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let game_type = type_name::get<GAME_TYPE>();
        assert!(vec_map::contains(&self.game_types, &game_type), EGameDoesNotExist);
        let player1 = object::id_address(player1);
        let player2 = opponent;
        assert!(player1 != player2, ESamePlayer);
        let game = Game<GAME_TYPE, STATE> {
            id: object::new(ctx),
            player1: player1,
            player2: player2,
            is_first_player_turn: true,
            is_swapable,
            turn_number: 0,
            is_started: false,
            winner_index: 0,
            bet: coin::into_balance(bet),
            game_state,
        };
        // maybe return here, not share ??? -> need to add `store`
        transfer::share_object(game);
    }

    public fun cancel_game<GAME_TYPE, STATE>(
        game: Game<GAME_TYPE, STATE>,
        player: &User,
        ctx: &mut TxContext
    ): (Coin<SUI>, STATE) {
        assert!(!game.is_started, EAlreadyStarted);
        let player = object::id_address(player);
        assert!(game.player1 == player, EWrongPlayer);

        let Game {
            id,
            player1: _,
            player2: _,
            is_first_player_turn: _,
            is_swapable: _,
            turn_number: _,
            is_started: _,
            winner_index: _,
            bet,
            game_state
            } = game;
        object::delete(id);
        (coin::from_balance(bet, ctx), game_state)
    }

    public fun join_game<GAME_TYPE, STATE: store>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        bet: Coin<SUI>
    ) {
        assert!(coin::value(&bet) == balance::value(&game.bet), EWrongBet);
        let player2 = object::id_address(player);
        assert!(player2 != game.player1, EAlreadyJoined);
        assert!(!game.is_started, EAlreadyStarted);
        if (game.player2 != @0) {
            assert!(game.player2 == player2, EWrongPlayer);
        } else {
            game.player2 = player2;
        };
        balance::join(&mut game.bet, coin::into_balance(bet));
        game.is_started = true;
    }

    // is "_: GAME_TYPE" needed?
    public fun make_move<GAME_TYPE: drop, STATE>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        _: GAME_TYPE
    ): (&mut STATE, u8) {
        assert!(game.is_started, ENotStarted);
        assert!(game.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        if (game.is_first_player_turn) {
            assert!(player == game.player1, EWrongPlayer);
        } else {
            assert!(player == game.player2, EWrongPlayer);
            game.turn_number = game.turn_number + 1;
        };

        let cur_player_num = if (game.is_first_player_turn) 1 else 2;

        game.is_first_player_turn = !game.is_first_player_turn;
        (&mut game.game_state, cur_player_num)
    }

    // is "_: GAME_TYPE" needed?
    public fun swap_sides<GAME_TYPE: drop, STATE>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        _: GAME_TYPE
    ): &mut STATE {
        assert!(game.is_started, ENotStarted); // not neccessary?
        assert!(game.is_swapable, ENotSwapable);
        let player = object::id_address(player);
        assert!(game.turn_number == 0, ENotFirstTurn);
        assert!(player == game.player2 && !game.is_first_player_turn, EWrongPlayer);

        game.player2 = game.player1;
        game.player1 = player;

        &mut game.game_state
    }

    public fun give_up<GAME_TYPE: drop, STATE>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        _: GAME_TYPE
    ): &mut STATE {
        assert!(game.is_started, ENotStarted);
        assert!(game.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        assert!(player == game.player1 || player == game.player2, EWrongPlayer);
        game.winner_index = if (player == game.player1) 2 else 1;
        &mut game.game_state
    }

    public fun get_state_to_win<GAME_TYPE: drop, STATE>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        _: GAME_TYPE
    ): (&mut STATE, u8, WinnerRequest) {
        assert!(game.is_started, ENotStarted);
        assert!(game.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        assert!(player == game.player1 || player == game.player2, EWrongPlayer);
        let cur_player_num = if (player == game.player1) 1 else 2;
        let winner_request = WinnerRequest {
            game_id: object::uid_to_inner(&game.id),
            winner_index: cur_player_num
        };
        (&mut game.game_state, cur_player_num, winner_request)
    }

    public fun declare_win<GAME_TYPE: drop, STATE>(
        game: &mut Game<GAME_TYPE, STATE>,
        player: &User,
        win_req: WinnerRequest,
        _: GAME_TYPE
    ) {
        let WinnerRequest {game_id, winner_index} = win_req;
        assert!(game_id == object::uid_to_inner(&game.id), EWrongGame);
        game.winner_index = winner_index;
    }

    // === Public-View Functions ===

    // === Admin Functions ===
    public fun add_game_type<GAME: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<GAME>();
        assert!(!vec_map::contains(&self.game_types, &game), EGameAlreadyAdded);
        vec_map::insert(&mut self.game_types, game, GameStats {games_played: 0});
    }

    public fun update_game_type<OLD: drop, NEW: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<OLD>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        let (_, game_stats) = vec_map::remove(&mut self.game_types, &game);
        vec_map::insert(&mut self.game_types, type_name::get<NEW>(), game_stats);
    }

    public fun delete_game_type<GAME: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<GAME>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        vec_map::remove(&mut self.game_types, &game);
    }

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}