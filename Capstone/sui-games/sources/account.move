module sui_games::account {
    // === Imports ===

    use std::string::{Self, String};

    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::clock::{Self, Clock};

    // === Friends ===

    // === Errors ===

    // === Constants ===

    // === Structs ===

    struct Account has key, store {
        id: UID,
        name: String,
        // creation timestamp
        created_at: u64
    }

    // === Public-Mutative Functions ===

    public fun create_account(name: vector<u8>, clock: &Clock, ctx: &mut TxContext): Account {
        Account {
            id: object::new(ctx),
            name: string::utf8(name),
            created_at: clock::timestamp_ms(clock)
        }
    }

    public fun change_name(self: &mut Account, name: vector<u8>) {
        self.name = string::utf8(name);
    }

    public fun delete_account(self: Account) {
        let Account { id, name: _, created_at: _ } = self;
        object::delete(id);
    }

    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===
}