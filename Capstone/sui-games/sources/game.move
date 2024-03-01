module sui_games::game {
    // === Imports ===

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    // use sui::event;

    use sui_games::games_pack::{Self, GamesPack};
    use sui_games::account::{Account};

    // === Friends ===

    // === Errors ===
    const EGameTypeDoesNotExist: u64 = 0;
    const ESamePlayer: u64 = 1;
    const EWrongBet: u64 = 2;
    const EAlreadyJoined: u64 = 3;
    const EWrongPlayer: u64 = 4;
    const EAlreadyStarted: u64 = 5;
    const ENotStarted: u64 = 6;
    const EGameAlreadyOver: u64 = 7;
    const EGameNotOver: u64 = 8;
    const ENotSwapable: u64 = 9;
    const ENotFirstTurn: u64 = 10;
    const EWrongGame: u64 = 11;
    const ENotWinner: u64 = 12;

    // === Constants ===

    // === Structs ===

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
        created_at: u64,
        game_state: STATE
    }

    struct WinnerRequest {
        game_id: ID,
        winner_index: u8
    }

    // === Public-Mutative Functions ===

    public fun create_game<GAME_TYPE: drop, STATE: store>(
        games: &GamesPack,
        _: GAME_TYPE,
        is_swapable: bool,
        game_state: STATE,
        player1: &Account,
        opponent: address,
        bet: Coin<SUI>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert!(games_pack::has_game<GAME_TYPE>(games), EGameTypeDoesNotExist);
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
            created_at: clock::timestamp_ms(clock),
            game_state,
        };
        // maybe return here, not share ??? -> need to add `store`
        transfer::share_object(game);
    }

    public fun cancel_game<GAME_TYPE, STATE>(
        self: Game<GAME_TYPE, STATE>,
        player: &Account,
        ctx: &mut TxContext
    ): (Coin<SUI>, STATE) {
        assert!(!self.is_started, EAlreadyStarted);
        let player = object::id_address(player);
        assert!(self.player1 == player, EWrongPlayer);

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
            created_at: _,
            game_state
            } = self;
        object::delete(id);
        (coin::from_balance(bet, ctx), game_state)
    }

    public fun join_game<GAME_TYPE, STATE: store>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        bet: Coin<SUI>
    ) {
        assert!(coin::value(&bet) == balance::value(&self.bet), EWrongBet);
        let player2 = object::id_address(player);
        assert!(player2 != self.player1, EAlreadyJoined);
        assert!(!self.is_started, EAlreadyStarted);
        if (self.player2 != @0) {
            assert!(self.player2 == player2, EWrongPlayer);
        } else {
            self.player2 = player2;
        };
        balance::join(&mut self.bet, coin::into_balance(bet));
        self.is_started = true;
    }

    public fun make_move<GAME_TYPE: drop, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        _: GAME_TYPE
    ): (&mut STATE, u8) {
        assert!(self.is_started, ENotStarted);
        assert!(self.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        if (self.is_first_player_turn) {
            assert!(player == self.player1, EWrongPlayer);
        } else {
            assert!(player == self.player2, EWrongPlayer);
            self.turn_number = self.turn_number + 1;
        };

        let cur_player_num = if (self.is_first_player_turn) 1 else 2;

        self.is_first_player_turn = !self.is_first_player_turn;
        (&mut self.game_state, cur_player_num)
    }

    public fun swap_sides<GAME_TYPE: drop, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        _: GAME_TYPE
    ): &mut STATE {
        assert!(self.is_started, ENotStarted); // not neccessary?
        assert!(self.is_swapable, ENotSwapable);
        let player = object::id_address(player);
        assert!(self.turn_number == 0, ENotFirstTurn);
        assert!(player == self.player2 && !self.is_first_player_turn, EWrongPlayer);

        self.player2 = self.player1;
        self.player1 = player;

        &mut self.game_state
    }

    public fun give_up<GAME_TYPE: drop, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        _: GAME_TYPE
    ): &mut STATE {
        assert!(self.is_started, ENotStarted);
        assert!(self.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        assert!(player == self.player1 || player == self.player2, EWrongPlayer);
        self.winner_index = if (player == self.player1) 2 else 1;
        &mut self.game_state
    }

    public fun get_state_to_win<GAME_TYPE: drop, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        _: GAME_TYPE
    ): (&mut STATE, u8, WinnerRequest) {
        assert!(self.is_started, ENotStarted);
        assert!(self.winner_index == 0, EGameAlreadyOver);
        let player = object::id_address(player);
        assert!(player == self.player1 || player == self.player2, EWrongPlayer);
        let player_num = if (player == self.player1) 1 else 2;
        let winner_request = WinnerRequest {
            game_id: object::uid_to_inner(&self.id),
            winner_index: player_num
        };
        (&mut self.game_state, player_num, winner_request)
    }

    // is "_: GAME_TYPE" needed?
    public fun declare_win<GAME_TYPE: drop, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        win_req: WinnerRequest,
        _: GAME_TYPE
    ) {
        let WinnerRequest {game_id, winner_index} = win_req;
        assert!(game_id == object::uid_to_inner(&self.id), EWrongGame);
        self.winner_index = winner_index;
    }

    public fun withdraw<GAME_TYPE, STATE>(
        self: &mut Game<GAME_TYPE, STATE>,
        player: &Account,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(self.winner_index != 0, EGameNotOver);
        let player = object::id_address(player);
        if (self.winner_index == 1) {
            assert!(player == self.player1, ENotWinner);
        };
        if (self.winner_index == 2) {
            assert!(player == self.player2, ENotWinner);
        };
        coin::from_balance(balance::withdraw_all(&mut self.bet), ctx)
    }

    public fun delete_game<GAME_TYPE, STATE>(
        self: Game<GAME_TYPE, STATE>,
        player: &Account
    ): STATE {
        assert!(self.winner_index != 0, EGameNotOver);
        let player = object::id_address(player);
        if (self.winner_index == 1) {
            assert!(player == self.player1, ENotWinner);
        };
        if (self.winner_index == 2) {
            assert!(player == self.player2, ENotWinner);
        };
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
            created_at: _,
            game_state
        } = self;
        balance::destroy_zero(bet);
        object::delete(id);
        game_state
    }

    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}