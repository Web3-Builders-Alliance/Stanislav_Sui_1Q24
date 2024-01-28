module prereqs::capability {
    use std::string::{Self, String};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct AdminCap has key {
        id: UID
    }

    struct Item has key, store {
        id: UID,
        name: String
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(AdminCap {id: object::new(ctx)}, tx_context::sender(ctx))
    }

    public fun create_and_send(_: &AdminCap, name: vector<u8>, to: address, ctx: &mut TxContext) {
        transfer::transfer(
            Item {
                id: object::new(ctx),
                name: string::utf8(name)
            },
            to)
    }
}