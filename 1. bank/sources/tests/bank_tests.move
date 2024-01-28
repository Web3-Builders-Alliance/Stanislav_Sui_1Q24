#[test_only]
module bank::bank_tests {
    use sui::test_utils::assert_eq;
    use sui::coin::{Self, mint_for_testing, burn_for_testing};
    use sui::test_scenario as ts;

    use bank::bank::{Self, Bank, OwnerCap};

    const ADMIN: address = @0xb0b;
    const USER: address = @0xa11ce;
    const NO_USER: address = @0xdead;

    #[test]
    fun test_deposit() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        ts::end(scenario_val);
    }

    #[test, expected_failure]
    fun test_deposit_fail() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 6);

        ts::end(scenario_val);
    }

     #[test]
    fun test_withdraw_all() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        withdraw_all_test_helper(scenario, USER, 95);

        ts::end(scenario_val);
    }

    #[test, expected_failure(abort_code = bank::bank::EInvalidUser)]
    fun test_withdraw_all_wrong_user() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        withdraw_all_test_helper(scenario, NO_USER, 95);

        ts::end(scenario_val);
    }

    #[test]
    fun test_withdraw_amount() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        withdraw_amount_test_helper(scenario, USER, 95);

        ts::end(scenario_val);
    }

    #[test, expected_failure(abort_code = bank::bank::EInvalidUser)]
    fun test_withdraw_amount_wrong_user() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        withdraw_amount_test_helper(scenario, NO_USER, 95);

        ts::end(scenario_val);
    }

    #[test, expected_failure(abort_code = bank::bank::EInvalidWithdrawalAmount)]
    fun test_withdraw_amount_wrong_amount() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        withdraw_amount_test_helper(scenario, USER, 100);

        ts::end(scenario_val);
    }

    #[test]
    fun test_claim() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        claim_test_helper(scenario, 5);

        ts::end(scenario_val);
    }

    fun init_test_helper(): ts::Scenario{
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        {
            bank::init_for_testing(ts::ctx(scenario));
        };
        scenario_val
    }

    fun deposit_test_helper(scenario: &mut ts::Scenario, addr: address, amount: u64, fee_percent: u8) {
        ts::next_tx(scenario, addr);
        {
            let bank = ts::take_shared<Bank>(scenario);
            bank::deposit(&mut bank, mint_for_testing(amount, ts::ctx(scenario)), ts::ctx(scenario));

            let (user_amount, admin_amount) = calculate_fee_helper(amount, fee_percent);

            assert_eq(bank::balance(&bank, addr), user_amount);
            assert_eq(bank::admin_balance(&bank), admin_amount);

            ts::return_shared(bank);
        }
    }

    fun withdraw_all_test_helper(scenario: &mut ts::Scenario, addr: address, expected_amount: u64) {
        ts::next_tx(scenario, addr);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let user_coin = bank::withdraw_all(&mut bank, ts::ctx(scenario));
            assert_eq(coin::value(&user_coin), expected_amount);
            assert_eq(bank::balance(&bank, addr), 0);

            burn_for_testing(user_coin);
            ts::return_shared(bank);
        }
    }

    fun withdraw_amount_test_helper(scenario: &mut ts::Scenario, addr: address, amount: u64) {
        ts::next_tx(scenario, addr);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let balance_before = bank::balance(&bank, addr);
            let user_coin = bank::withdraw_amount(&mut bank, amount, ts::ctx(scenario));
            assert_eq(coin::value(&user_coin), amount);
            assert_eq(bank::balance(&bank, addr), balance_before - amount);

            burn_for_testing(user_coin);
            ts::return_shared(bank);
        }
    }

    fun claim_test_helper(scenario: &mut ts::Scenario, expected_amount: u64) {
        ts::next_tx(scenario, ADMIN);
        {
            {
            let bank = ts::take_shared<Bank>(scenario);
            let owner_cap = ts::take_from_sender<OwnerCap>(scenario);

            let admin_coin = bank::claim(&owner_cap, &mut bank, ts::ctx(scenario));
            assert_eq(coin::value(&admin_coin), expected_amount);

            burn_for_testing(admin_coin);
            ts::return_to_sender(scenario, owner_cap);
            ts::return_shared(bank);
        };
        }
    }

    fun calculate_fee_helper(amount: u64, fee_percent: u8): (u64, u64) {
        let deposit_value = amount - (((amount as u128) * (fee_percent  as u128) / 100) as u64);
        let admin_fee = amount - deposit_value;

        (deposit_value, admin_fee)
    }
}