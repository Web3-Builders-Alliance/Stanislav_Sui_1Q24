module prereqs::entry_functions {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    struct MyObject has key {
        id: UID
    }

    public fun create_object(ctx: &mut TxContext): MyObject {
        MyObject {
            id: object::new(ctx)
        }
    }

    entry fun create_and_transfer(to: address, ctx: &mut TxContext) {
        transfer::transfer(create_object(ctx), to)
    }
}