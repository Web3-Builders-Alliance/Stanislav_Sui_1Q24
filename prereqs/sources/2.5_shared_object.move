module prereqs::shared_object {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const ENotEnough: u64 = 0;

    struct ShopOwnerCap has key {
        id: UID
    }

    struct Chocolate has key {
        id: UID
    }

    struct ChocolateShop has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap {id: object::new(ctx)}, tx_context::sender(ctx));

        transfer::share_object(ChocolateShop {
            id: object::new(ctx),
            price: 20,
            balance: balance::zero()
        })
    }

    public fun buy_chocolate(shop: &mut ChocolateShop, payment: &mut Coin<SUI>, ctx: &mut TxContext) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);

        balance::join(&mut shop.balance, paid);

        transfer::transfer(Chocolate {id: object::new(ctx)}, tx_context::sender(ctx))
    }

    public fun eat_chocolate(c: Chocolate) {
        let Chocolate { id } = c;
        object::delete(id);
    }

    public fun collect_profits(_: &ShopOwnerCap, shop: &mut ChocolateShop, ctx: &mut TxContext): Coin<SUI> {
        let amount = balance::value(&shop.balance);
        coin::take(&mut shop.balance, amount, ctx)
    }

}