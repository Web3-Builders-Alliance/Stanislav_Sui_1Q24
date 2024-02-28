module sui_games::games_pack {
    // === Imports ===

    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    // use sui::clock::{Self, Clock};
    use sui::vec_map::{Self, VecMap};
    // use sui::event;


    // === Friends ===

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

    struct GamesPack has key {
        id: UID,
        game_types: VecMap<TypeName, GameStats>
    }

    // === Init ===

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap {id: object::new(ctx)},
            tx_context::sender(ctx)
        );

        transfer::share_object(GamesPack {
            id: object::new(ctx),
            game_types: vec_map::empty()
        });
    }

    // === Public-Mutative Functions ===

    // === Public-View Functions ===
    public fun has_game<GAME_TYPE>(self: &GamesPack): bool {
        let game_type = type_name::get<GAME_TYPE>();
        vec_map::contains(&self.game_types, &game_type)
    }

    // === Admin Functions ===
    public fun add_game_type<GAME_TYPE: drop>(_: &AdminCap, self: &mut GamesPack) {
        let game = type_name::get<GAME_TYPE>();
        assert!(!vec_map::contains(&self.game_types, &game), EGameAlreadyAdded);
        vec_map::insert(&mut self.game_types, game, GameStats {games_played: 0});
    }

    public fun update_game_type<OLD_TYPE: drop, NEW_TYPE: drop>(_: &AdminCap, self: &mut GamesPack) {
        let game = type_name::get<OLD_TYPE>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        let (_, game_stats) = vec_map::remove(&mut self.game_types, &game);
        vec_map::insert(&mut self.game_types, type_name::get<NEW_TYPE>(), game_stats);
    }

    public fun delete_game_type<GAME_TYPE: drop>(_: &AdminCap, self: &mut GamesPack) {
        let game = type_name::get<GAME_TYPE>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        vec_map::remove(&mut self.game_types, &game);
    }

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}