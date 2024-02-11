module test_kiosk::royalty_rule {

    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap, TransferRequest};

    const EWrongBpAmount:u64 = 0;
    const EInsufficientAmount:u64 = 1;

    struct Config has store, drop {
        amount_bp: u16
    }

    struct Rule has drop {}

    public fun add_rule<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>, amount_bp: u16) {
        assert!(amount_bp < 10000, EWrongBpAmount);
        transfer_policy::add_rule(Rule {}, policy, cap, Config { amount_bp });
    }

    public fun pay_royalty<T>(policy: &mut TransferPolicy<T>, request: &mut TransferRequest<T>, royalty: Coin<SUI>) {
        let required_royalty = royalty_amount(policy, transfer_policy::paid(request));
        assert!(coin::value(&royalty) == required_royalty, EInsufficientAmount);

        transfer_policy::add_to_balance(Rule {}, policy, royalty);
        transfer_policy::add_receipt(Rule {}, request);
    }

    public fun royalty_amount<T>(policy: &TransferPolicy<T>, paid_amount: u64): u64 {
        let config: &Config = transfer_policy::get_rule(Rule {}, policy);
        let amount = (((paid_amount as u128) * (config.amount_bp as u128) / 10000) as u64);

        amount
    }
}