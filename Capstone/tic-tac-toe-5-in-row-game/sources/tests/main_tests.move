#[test_only]
module tic_tac_toe_5_in_row::main_tests {

    use tic_tac_toe_5_in_row::main::{Self, TicTacToe};
    use tic_tac_toe_5_in_row::board::Board;
    use sui_games::games_pack::{Self, GamesPack};
    use sui_games::game::{Self, Game};
    use sui_games::account::{Self, Account};

    use sui::clock::{Self, Clock};
    use sui::transfer;
    use sui::object;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::test_utils::assert_eq;
    use sui::test_scenario::{Self as ts,  ctx, Scenario};

    const ADMIN: address = @0x2;
    const PLAYER_1: address = @0x111;
    const PLAYER_2: address = @0x222;

    #[test]
    fun auto_draw_game_test() {
        let scenario = init_test();

        create_account_test(&mut scenario, PLAYER_1, b"player1");
        create_account_test(&mut scenario, PLAYER_2, b"player2");

        add_game_type_test(&mut scenario);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        create_game_test(&mut scenario, PLAYER_1, PLAYER_2, bet);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        join_game_test(&mut scenario, PLAYER_2, bet);

        let i = 0;
        while (i < 224) {
            make_move_test(&mut scenario, PLAYER_1, i);
            make_move_test(&mut scenario, PLAYER_2, i + 1);
            i = i + 2;
        };
        make_move_test(&mut scenario, PLAYER_1, 224);

        withdraw_test(&mut scenario, PLAYER_1, 100);
        withdraw_test(&mut scenario, PLAYER_2, 100);

        delete_game_test(&mut scenario, PLAYER_2);

        ts::end(scenario);
    }

    #[test]
    fun manual_draw_game_test() {
        let scenario = init_test();

        create_account_test(&mut scenario, PLAYER_1, b"player1");
        create_account_test(&mut scenario, PLAYER_2, b"player2");

        add_game_type_test(&mut scenario);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        create_game_test(&mut scenario, PLAYER_1, PLAYER_2, bet);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        join_game_test(&mut scenario, PLAYER_2, bet);

        draw_game_test(&mut scenario, PLAYER_1);
        draw_game_test(&mut scenario, PLAYER_2);

        withdraw_test(&mut scenario, PLAYER_1, 100);
        withdraw_test(&mut scenario, PLAYER_2, 100);

        delete_game_test(&mut scenario, PLAYER_2);

        ts::end(scenario);
    }

    fun init_test(): Scenario {
        let scenario = ts::begin(ADMIN);
        {
            let clock = clock::create_for_testing(ctx(&mut scenario));
            clock::share_for_testing(clock);
            games_pack::init_for_testing(ctx(&mut scenario));
        };
        scenario
    }

    fun add_game_type_test(scenario: &mut Scenario) {
        ts::next_tx(scenario, ADMIN);
        {
            let games_pack = ts::take_shared<GamesPack>(scenario);
            let cap = ts::take_from_sender<games_pack::AdminCap>(scenario);
            games_pack::add_game_type<TicTacToe>(&cap, &mut games_pack, ctx(scenario));

            ts::return_shared(games_pack);
            ts::return_to_sender(scenario, cap);
        };
    }

    fun create_account_test(scenario: &mut Scenario, player: address, name: vector<u8>) {
        ts::next_tx(scenario, player);
        {
            let clock = ts::take_shared<Clock>(scenario);
            clock::increment_for_testing(&mut clock, 1);
            let account = account::create_account(name, &clock, ctx(scenario));
            transfer::public_transfer(account, player);

            ts::return_shared(clock);
        };
    }

    fun create_game_test(scenario: &mut Scenario, player: address, opponent: address, bet: Coin<SUI>) {
        ts::next_tx(scenario, player);
        {
            let clock = ts::take_shared<Clock>(scenario);
            clock::increment_for_testing(&mut clock, 1);
            let account = ts::take_from_address<Account>(scenario, player);
            let games_pack = ts::take_shared<GamesPack>(scenario);

            let opponent_account_id: address;
            if (opponent == @0) {
                opponent_account_id = @0;
            } else {
                let opponent_account = ts::take_from_address<Account>(scenario, opponent);
                opponent_account_id = object::id_address(&opponent_account);
                ts::return_to_address(opponent, opponent_account);
            };

            main::create_game(&mut games_pack, &account, opponent_account_id, bet, &clock, ctx(scenario));

            ts::return_to_sender(scenario, account);

            ts::return_shared(games_pack);
            ts::return_shared(clock);
        };
    }

    fun join_game_test(scenario: &mut Scenario, player: address, bet: Coin<SUI>) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<TicTacToe, Board>>(scenario);
            game::join_game<TicTacToe, Board>(&mut game, &account, bet);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun draw_game_test(scenario: &mut Scenario, player: address) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<TicTacToe, Board>>(scenario);
            let games_pack = ts::take_shared<GamesPack>(scenario);
            game::suggest_draw(&mut game, &mut games_pack, &account);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
            ts::return_shared(games_pack);
        };
    }

    fun make_move_test(scenario: &mut Scenario, player: address, tile: u8) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<TicTacToe, Board>>(scenario);
            let games_pack = ts::take_shared<GamesPack>(scenario);
            main::make_move(&mut game, &mut games_pack, &account, tile);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
            ts::return_shared(games_pack);
        };
    }

    fun withdraw_test(scenario: &mut Scenario, player: address, expected_withdraw_amount: u64) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<TicTacToe, Board>>(scenario);
            let winner_coin = game::withdraw(&mut game, &account, ctx(scenario));
            assert_eq(coin::value(&winner_coin), expected_withdraw_amount);
            coin::burn_for_testing(winner_coin);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun delete_game_test(scenario: &mut Scenario, player: address) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<TicTacToe, Board>>(scenario);
            let games_pack = ts::take_shared<GamesPack>(scenario);
            game::delete_game( game, &mut games_pack, &account);
            ts::return_shared(games_pack);
            ts::return_to_sender(scenario, account);
        };
    }



}