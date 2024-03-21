module sui_games::games_pack {
    // === Imports ===

    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    // use sui::clock::{Self, Clock};
    use sui::vec_map::{Self, VecMap};
    use sui::table::{Self, Table};
    // use sui::event;


    // === Friends ===
    friend sui_games::game;

    // === Errors ===
    const EGameAlreadyAdded: u64 = 0;
    const EGameDoesNotExist: u64 = 1;


    // === Constants ===

    // === Structs ===

    struct AdminCap has key, store {
        id: UID,
    }

    struct GameStats has store, drop {
        games_played: u64
    }

    struct PlayerScores has store, drop {
        wins: u64,
        losses: u64,
        draws: u64
    }

    struct GamesPack has key {
        id: UID,
        game_types: VecMap<TypeName, GameStats>,
        // game_type -> (account_address -> PlayerScores)
        scores: VecMap<TypeName, Table<address, PlayerScores>>,
        // game_type -> game_ids
        games: VecMap<TypeName, Table<ID, bool>>
    }


    // === Init ===

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap {id: object::new(ctx)},
            tx_context::sender(ctx)
        );

        transfer::share_object(GamesPack {
            id: object::new(ctx),
            game_types: vec_map::empty(),
            scores: vec_map::empty(),
            games: vec_map::empty()
        });
    }

    // === Public-Mutative Functions ===

    // === Public-View Functions ===
    public fun has_game<GameType>(self: &GamesPack): bool {
        let game_type = type_name::get<GameType>();
        vec_map::contains(&self.game_types, &game_type)
    }

    // === Admin Functions ===
    public fun add_game_type<GameType: drop>(_: &AdminCap, self: &mut GamesPack, ctx: &mut TxContext) {
        let game_type = type_name::get<GameType>();
        assert!(!vec_map::contains(&self.game_types, &game_type), EGameAlreadyAdded);
        vec_map::insert(&mut self.game_types, game_type, GameStats {games_played: 0});
        vec_map::insert(&mut self.scores, game_type, table::new(ctx));
        vec_map::insert(&mut self.games, game_type, table::new(ctx));
    }

    public fun update_game_type<OLD_TYPE: drop, NEW_TYPE: drop>(_: &AdminCap, self: &mut GamesPack) {
        let game_type = type_name::get<OLD_TYPE>();
        assert!(vec_map::contains(&self.game_types, &game_type), EGameDoesNotExist);
        let (_, game_stats) = vec_map::remove(&mut self.game_types, &game_type);
        vec_map::insert(&mut self.game_types, type_name::get<NEW_TYPE>(), game_stats);
        let (_, scores) = vec_map::remove(&mut self.scores, &game_type);
        vec_map::insert(&mut self.scores, type_name::get<NEW_TYPE>(), scores);
        let (_, games) = vec_map::remove(&mut self.games, &game_type);
        vec_map::insert(&mut self.games, type_name::get<NEW_TYPE>(), games);
    }

    public fun delete_game_type<GameType: drop>(_: &AdminCap, self: &mut GamesPack) {
        let game_type = type_name::get<GameType>();
        assert!(vec_map::contains(&self.game_types, &game_type), EGameDoesNotExist);
        vec_map::remove(&mut self.game_types, &game_type);
        let (_, scores) = vec_map::remove(&mut self.scores, &game_type);
        table::drop(scores);
        let (_, games) = vec_map::remove(&mut self.games, &game_type);
        table::drop(games);
    }

    // === Public-Friend Functions ===
    public(friend) fun add_game<GameType>(self: &mut GamesPack, game_id: ID) {
        let game_type = type_name::get<GameType>();
        if (!vec_map::contains(&self.game_types, &game_type)) return;

        let  games = vec_map::get_mut(&mut self.games, &game_type);
        table::add(games, game_id, true);
    }

    public(friend) fun remove_game<GameType>(self: &mut GamesPack, game_id: ID) {
        let game_type = type_name::get<GameType>();
        if (!vec_map::contains(&self.game_types, &game_type)) return;

        let  games = vec_map::get_mut(&mut self.games, &game_type);
        table::remove(games, game_id);
    }

    public(friend) fun player_win<GameType>(self: &mut GamesPack, player: address) {
        let game_type = type_name::get<GameType>();
        if (!vec_map::contains(&self.game_types, &game_type)) return;
        let player_stats = vec_map::get_mut(&mut self.scores, &game_type);
        if (!table::contains(player_stats, player)) {
            table::add(player_stats, player, PlayerScores {wins: 1, losses: 0, draws: 0});
        } else {
            let player_stats = table::borrow_mut(player_stats, player);
            player_stats.wins = player_stats.wins + 1;
        }
    }

    public(friend) fun player_lose<GameType>(self: &mut GamesPack, player: address) {
        let game_type = type_name::get<GameType>();
        if (!vec_map::contains(&self.game_types, &game_type)) return;
        let player_stats = vec_map::get_mut(&mut self.scores, &game_type);
        if (!table::contains(player_stats, player)) {
            table::add(player_stats, player, PlayerScores {wins: 0, losses: 1, draws: 0});
        } else {
            let player_stats = table::borrow_mut(player_stats, player);
            player_stats.losses = player_stats.losses + 1;
        }
    }

    public(friend) fun player_draw<GameType>(self: &mut GamesPack, player: address) {
        let game_type = type_name::get<GameType>();
        if (!vec_map::contains(&self.game_types, &game_type)) return;
        let player_stats = vec_map::get_mut(&mut self.scores, &game_type);
        if (!table::contains(player_stats, player)) {
            table::add(player_stats, player, PlayerScores {wins: 0, losses: 0, draws: 1});
        } else {
            let player_stats = table::borrow_mut(player_stats, player);
            player_stats.draws = player_stats.draws + 1;
        }
    }

    // === Private Functions ===

    // === Test Functions ===

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
}