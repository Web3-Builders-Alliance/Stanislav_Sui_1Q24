module sui_games::main {
    // === Imports ===

    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    // use sui::clock::{Self, Clock};
    use sui::vec_map::{Self, VecMap};


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

    // === Public-View Functions ===

    // === Admin Functions ===
    public fun add_game<GAME: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<GAME>();
        assert!(!vec_map::contains(&self.game_types, &game), EGameAlreadyAdded);
        vec_map::insert(&mut self.game_types, game, GameStats {games_played: 0});
    }

    public fun update_game<OLD: drop, NEW: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<OLD>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        let (_, game_stats) = vec_map::remove(&mut self.game_types, &game);
        vec_map::insert(&mut self.game_types, type_name::get<NEW>(), game_stats);
    }

    public fun delete_game<GAME: drop>(_: &AdminCap, self: &mut Games) {
        let game = type_name::get<GAME>();
        assert!(vec_map::contains(&self.game_types, &game), EGameDoesNotExist);
        vec_map::remove(&mut self.game_types, &game);
    }

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}