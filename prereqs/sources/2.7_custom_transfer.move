module prereqs::custom_transfer {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const EWrongAmount: u64 = 0;

    struct GovermentCapability has key {
        id: UID
    }

    struct TitleDeed has key {
        id: UID
    }

    struct LandRegistry has key {
        id: UID,
        balance: Balance<SUI>,
        fee: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(GovermentCapability {id: object::new(ctx)}, tx_context::sender(ctx));

        transfer::share_object(LandRegistry {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            fee: 1000
        })
    }

    public fun issue_title_deed(_: &GovermentCapability, for: address, ctx: &mut TxContext) {
        transfer::transfer(TitleDeed {id: object::new(ctx)}, for)
    }

    public fun transfer_ownership(registry: &mut LandRegistry, td: TitleDeed, fee: Coin<SUI>, to: address) {
        assert!(coin::value(&fee) == registry.fee, EWrongAmount);

        balance::join(&mut registry.balance, coin::into_balance(fee));

        transfer::transfer(td, to)
    }
}
