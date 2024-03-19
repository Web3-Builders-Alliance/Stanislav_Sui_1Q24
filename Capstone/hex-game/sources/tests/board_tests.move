#[test_only]
module hex_game::board_tests {

    use hex_game::board::{Self};
    use sui::test_utils::assert_eq;

    #[test]
    fun test_is_path_correct1() {
        // 0,  1,  2,  3,  4,
        //  5,  6,  7,  8,  9,
        //   10, 11, 12, 13, 14,
        //    15, 16, 17, 18, 19,
        //     20, 21, 22, 23, 24
        let field = vector[
            0, 0, 0, 1, 0,
             0, 0, 1, 0, 0,
              0, 0, 1, 1, 0,
               0, 0, 0, 1, 0,
                0, 1, 1, 0, 0,
        ];

        let size = 5;

        let board = board::create_board_for_testing(size, field);
        let path = vector[3, 7, 12, 13, 18, 22];
        assert_eq(board::is_path_correct(&board, &path, 1), true);
        assert_eq(board::is_path_correct(&board, &path, 2), false);

        let path = vector[3, 7, 12, 13, 18, 23];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 7, 12, 13, 18];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 7, 12, 13, 18, 21];
        assert_eq(board::is_path_correct(&board, &path, 1), false);
    }

    #[test]
    fun test_is_path_correct2() {
        // 0,  1,  2,  3,  4,
        //  5,  6,  7,  8,  9,
        //   10, 11, 12, 13, 14,
        //    15, 16, 17, 18, 19,
        //     20, 21, 22, 23, 24
        let field = vector[
            0, 0, 0, 1, 1,
             0, 1, 1, 0, 1,
              1, 0, 1, 1, 0,
               1, 0, 0, 0, 0,
                1, 1, 1, 0, 0,
        ];

        let size = 5;

        let board = board::create_board_for_testing(size, field);
        let path = vector[3, 4, 9, 13, 12, 7, 6, 10, 15, 20];
        assert_eq(board::is_path_correct(&board, &path, 1), true);

        let path = vector[4, 9, 13, 12, 7, 6, 10, 15, 20];
        assert_eq(board::is_path_correct(&board, &path, 1), true);

        let path = vector[9, 13, 12, 7, 6, 10, 15, 20];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 4, 9, 13, 12, 7, 6, 10, 15];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 9, 13, 12, 7, 6, 10, 15, 20];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 8, 13, 12, 7, 6, 10, 15, 20];
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[3, 4, 9, 13, 12, 7, 6, 10, 15, 21];
        assert_eq(board::is_path_correct(&board, &path, 1), false);
    }

    #[test]
    fun test_is_path_correct3() {
        // 0,  1,  2,  3,  4,  5,  6
        //  7,  8,  9, 10, 11, 12, 13
        //   14, 15, 16, 17, 18, 19, 20
        //    21, 22, 23, 24, 25, 26, 27
        //     28, 29, 30, 31, 32, 33, 34
        //      35, 36, 37, 38, 39, 40, 41
        //       42, 43, 44, 45, 46, 47, 48
        let field = vector[
            0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 2, 2,
               2, 2, 0, 0, 2, 0, 0,
                0, 2, 0, 2, 0, 0, 0,
                 0, 2, 2, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0, 0,
        ];

        let size = 7;

        let board = board::create_board_for_testing(size, field);
        let path = vector[21, 22, 29, 36, 37, 31, 25, 19, 20];
        assert_eq(board::is_path_correct(&board, &path, 2), true);
        assert_eq(board::is_path_correct(&board, &path, 1), false);

        let path = vector[21, 22, 29, 36, 37, 31, 25, 19];
        assert_eq(board::is_path_correct(&board, &path, 2), false);

        let path = vector[22, 29, 36, 37, 31, 25, 19, 20];
        assert_eq(board::is_path_correct(&board, &path, 2), false);
    }
}