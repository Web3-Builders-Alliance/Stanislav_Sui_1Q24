#[test_only]
module hex_game::main_tests {

    use hex_game::main::{Self, HexGame};
    use hex_game::board::Board;
    use sui_games::games_pack::{Self, GamesPack};
    use sui_games::game::{Self, Game};
    use sui_games::account::{Self, Account};

    use std::string;

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
    fun full_game_test() {
        let scenario = init_test();

        create_account_test(&mut scenario, PLAYER_1, b"player1");
        create_account_test(&mut scenario, PLAYER_2, b"player2");

        add_game_type_test(&mut scenario);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        create_game_test(&mut scenario, PLAYER_1, PLAYER_2, bet);

        let bet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        join_game_test(&mut scenario, PLAYER_2, bet);

        play_game_test(&mut scenario);

        let path = vector[55, 56, 67, 78, 79, 69, 59, 49, 39, 40, 41, 52, 63, 74, 75, 65];
        declare_win_test(&mut scenario, PLAYER_2, path);

        withdraw_test(&mut scenario, PLAYER_2, 200);

        delete_game_test(&mut scenario, PLAYER_2);

        ts::end(scenario);
    }

    #[test]
    fun full_game_with_swap_test() {
        let scenario = init_test();

        create_account_test(&mut scenario, PLAYER_1, b"player1");
        create_account_test(&mut scenario, PLAYER_2, b"player2");

        add_game_type_test(&mut scenario);

        let bet = coin::zero(ctx(&mut scenario));
        create_game_test(&mut scenario, PLAYER_1, PLAYER_2, bet);

        let bet = coin::zero(ctx(&mut scenario));
        join_game_test(&mut scenario, PLAYER_2, bet);

        play_game_with_swap_test(&mut scenario);

        let path = vector[55, 56, 67, 78, 79, 69, 59, 49, 39, 40, 41, 52, 63, 74, 75, 65];
        declare_win_test(&mut scenario, PLAYER_1, path);

        ts::end(scenario);
    }

    #[test]
    fun account_test() {
        let scenario = init_test();

        create_account_test(&mut scenario, PLAYER_1, b"player1");

        ts::next_tx(&mut scenario, ADMIN);
        {
            let account1 = ts::take_from_address<Account>(&scenario, PLAYER_1);
            assert_eq(account::name(&account1), string::utf8(b"player1"));
            assert_eq(account::created_at(&account1), 1);
            ts::return_to_address(PLAYER_1, account1);
        };

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
            games_pack::add_game_type<HexGame>(&cap, &mut games_pack, ctx(scenario));

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

            hex_game::main::create_game(&mut games_pack, &account, opponent_account_id, bet, &clock, ctx(scenario));

            ts::return_to_sender(scenario, account);

            ts::return_shared(games_pack);
            ts::return_shared(clock);
        };
    }

    fun join_game_test(scenario: &mut Scenario, player: address, bet: Coin<SUI>) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            game::join_game<HexGame, Board>(&mut game, &account, bet);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun make_move_test(scenario: &mut Scenario, player: address, tile: u8) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            main::make_move(&mut game, &account, tile);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun swap_sides_test(scenario: &mut Scenario, player: address) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            main::swap_sides(&mut game, &account);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun declare_win_test(scenario: &mut Scenario, player: address, path: vector<u8>) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            let games_pack = ts::take_shared<GamesPack>(scenario);
            main::declare_win(&mut game, &mut games_pack,&account, path);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
            ts::return_shared(games_pack);
        };
    }

    fun withdraw_test(scenario: &mut Scenario, player: address, winner_amount: u64) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            let winner_coin = game::withdraw(&mut game, &account, ctx(scenario));
            assert_eq(coin::value(&winner_coin), winner_amount);
            coin::burn_for_testing(winner_coin);
            ts::return_to_sender(scenario, account);
            ts::return_shared(game);
        };
    }

    fun delete_game_test(scenario: &mut Scenario, player: address) {
        ts::next_tx(scenario, player);
        {
            let account = ts::take_from_address<Account>(scenario, player);
            let game = ts::take_shared<Game<HexGame, Board>>(scenario);
            let games_pack = ts::take_shared<GamesPack>(scenario);
            game::delete_game( game, &mut games_pack, &account);
            ts::return_shared(games_pack);
            ts::return_to_sender(scenario, account);
        };
    }

    fun play_game_test(scenario: &mut Scenario) {
                // 0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10
        //  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21
        //   22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  32
        //    33, 34,  35,  36,  37,  38,  39,  40,  41,  42,  43
        //     44, 45,  46,  47,  48,  49,  50,  51,  52,  53,  54
        //      55, 56,  57,  58,  59,  60,  61,  62,  63,  64,  65
        //       66, 67,  68,  69,  70,  71,  72,  73,  74,  75,  76
        //        77, 78,  79,  80,  81,  82,  83,  84,  85,  86,  87
        //         88, 89,  90,  91,  92,  93,  94,  95,  96,  97,  98
        //          99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109
        //           110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120
        
        // 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
        //  0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
        //   0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
        //    0, 0, 1, 1, 0, 0, 2, 2, 2, 0, 0
        //     0, 0, 1, 1, 0, 2, 0, 0, 2, 0, 0
        //      2, 2, 0, 1, 2, 0, 0, 0, 2, 0, 2
        //       0, 2, 0, 2, 1, 1, 1, 0, 2, 2, 0
        //        0, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0
        //         0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
        //          0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
        //           0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0

        make_move_test(scenario, PLAYER_1, 1);
        make_move_test(scenario, PLAYER_2, 55);

        make_move_test(scenario, PLAYER_1, 12);
        make_move_test(scenario, PLAYER_2, 56);

        make_move_test(scenario, PLAYER_1, 23);
        make_move_test(scenario, PLAYER_2, 67);

        make_move_test(scenario, PLAYER_1, 24);
        make_move_test(scenario, PLAYER_2, 78);

        make_move_test(scenario, PLAYER_1, 35);
        make_move_test(scenario, PLAYER_2, 79);

        make_move_test(scenario, PLAYER_1, 36);
        make_move_test(scenario, PLAYER_2, 69);

        make_move_test(scenario, PLAYER_1, 46);
        make_move_test(scenario, PLAYER_2, 59);

        make_move_test(scenario, PLAYER_1, 47);
        make_move_test(scenario, PLAYER_2, 49);

        make_move_test(scenario, PLAYER_1, 58);
        make_move_test(scenario, PLAYER_2, 39);

        make_move_test(scenario, PLAYER_1, 70);
        make_move_test(scenario, PLAYER_2, 40);

        make_move_test(scenario, PLAYER_1, 71);
        make_move_test(scenario, PLAYER_2, 41);

        make_move_test(scenario, PLAYER_1, 72);
        make_move_test(scenario, PLAYER_2, 52);

        make_move_test(scenario, PLAYER_1, 83);
        make_move_test(scenario, PLAYER_2, 63);

        make_move_test(scenario, PLAYER_1, 94);
        make_move_test(scenario, PLAYER_2, 74);

        make_move_test(scenario, PLAYER_1, 104);
        make_move_test(scenario, PLAYER_2, 75);

        make_move_test(scenario, PLAYER_1, 114);
        make_move_test(scenario, PLAYER_2, 65);
    }

    fun play_game_with_swap_test(scenario: &mut Scenario) {

        make_move_test(scenario, PLAYER_1, 1);
        swap_sides_test(scenario, PLAYER_2);

        make_move_test(scenario, PLAYER_1, 55);

        make_move_test(scenario, PLAYER_2, 12);
        make_move_test(scenario, PLAYER_1, 56);

        make_move_test(scenario, PLAYER_2, 23);
        make_move_test(scenario, PLAYER_1, 67);

        make_move_test(scenario, PLAYER_2, 24);
        make_move_test(scenario, PLAYER_1, 78);

        make_move_test(scenario, PLAYER_2, 35);
        make_move_test(scenario, PLAYER_1, 79);

        make_move_test(scenario, PLAYER_2, 36);
        make_move_test(scenario, PLAYER_1, 69);

        make_move_test(scenario, PLAYER_2, 46);
        make_move_test(scenario, PLAYER_1, 59);

        make_move_test(scenario, PLAYER_2, 47);
        make_move_test(scenario, PLAYER_1, 49);

        make_move_test(scenario, PLAYER_2, 58);
        make_move_test(scenario, PLAYER_1, 39);

        make_move_test(scenario, PLAYER_2, 70);
        make_move_test(scenario, PLAYER_1, 40);

        make_move_test(scenario, PLAYER_2, 71);
        make_move_test(scenario, PLAYER_1, 41);

        make_move_test(scenario, PLAYER_2, 72);
        make_move_test(scenario, PLAYER_1, 52);

        make_move_test(scenario, PLAYER_2, 83);
        make_move_test(scenario, PLAYER_1, 63);

        make_move_test(scenario, PLAYER_2, 94);
        make_move_test(scenario, PLAYER_1, 74);

        make_move_test(scenario, PLAYER_2, 104);
        make_move_test(scenario, PLAYER_1, 75);

        make_move_test(scenario, PLAYER_2, 114);
        make_move_test(scenario, PLAYER_1, 65);
    }

}