module bank::bank {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::dynamic_field as df;
    use sui::balance;
    use sui::transfer;

    struct Bank has key {
        id: UID
    }

    struct OwnerCap has key, store {
        id: UID
    }

    struct UserBalance has copy, drop, store {
       user: address
    }

    struct AdminBalance has copy, drop, store {}

    const FEE: u128 = 5;

    const EInvalidUser:u64 = 0;
    const EInvalidWithdrawalAmount: u64 = 1;

    fun init(ctx: &mut TxContext) {
        let bank = Bank {id: object::new(ctx)};

        df::add(&mut bank.id, AdminBalance{}, balance::zero<SUI>());

        transfer::share_object(bank);

        transfer::transfer(OwnerCap{id: object::new(ctx)}, tx_context::sender(ctx));
    }

    public fun deposit(self: &mut Bank, token: Coin<SUI>, ctx: &mut TxContext) {
        let value = coin::value(&token);

        let deposit_value = value - (((value as u128) * FEE / 100) as u64);
        let admin_fee = value - deposit_value;

        let admin_coin = coin::split(&mut token, admin_fee, ctx);

        let old_admin_balance = df::borrow_mut(&mut self.id, AdminBalance{});
        balance::join(old_admin_balance, coin::into_balance(admin_coin));

        let key = UserBalance {user: tx_context::sender(ctx)};

        if (df::exists_(&self.id, key)) {
            let old_user_balance = df::borrow_mut(&mut self.id, key);
            balance::join(old_user_balance, coin::into_balance(token));
        } else {
            df::add(&mut self.id, key, coin::into_balance(token))
        }

    }

    public fun withdraw_all(self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
        let sender = tx_context::sender(ctx);
        let key = UserBalance {user: sender};
        assert!(df::exists_(&self.id, key), EInvalidUser);

        let user_balance = df::borrow_mut(&mut self.id, key);
        coin::from_balance(balance::withdraw_all(user_balance), ctx)
    }

    public fun withdraw_amount(self: &mut Bank, amount: u64, ctx: &mut TxContext): Coin<SUI> {
        let sender = tx_context::sender(ctx);
        let key = UserBalance {user: sender};
        assert!(df::exists_(&self.id, key), EInvalidUser);

        let user_balance = df::borrow_mut(&mut self.id, key);
        assert!(balance::value<SUI>(user_balance) >= amount, EInvalidWithdrawalAmount);

        coin::from_balance(balance::split(user_balance, amount), ctx)
    }

    public fun claim(_: &OwnerCap, self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
        // coin::from_balance(df::remove(&mut self.id, AdminBalance{}), ctx)
        let admin_balance = df::borrow_mut(&mut self.id, AdminBalance { });
        coin::from_balance(balance::withdraw_all(admin_balance), ctx)
    }

    public fun balance(self: &Bank, user: address): u64 {
        let key = UserBalance {user: user};
        if (df::exists_(&self.id, key)) {
            balance::value<SUI>(df::borrow(&self.id, key))
        } else {
            0
        }
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    #[test_only]
    public fun admin_balance(self: &Bank): u64{
        balance::value<SUI>(df::borrow(&self.id, AdminBalance { }))
    }

}

