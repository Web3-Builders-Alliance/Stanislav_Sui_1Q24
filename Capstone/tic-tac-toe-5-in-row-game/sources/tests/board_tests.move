#[test_only]
module tic_tac_toe_5_in_row::board_tests {

    use tic_tac_toe_5_in_row::board::{Self};
    use sui::test_utils::assert_eq;

    #[test]
    fun test_is_path_correct1() {
        let field = vector[
            1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
            0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ];

        let size = 15;

        let board = board::create_board_for_testing(size, field);

        let path = vector[3 * 15 + 6, 4 * 15 + 7, 5 * 15 + 8, 6 * 15 + 9, 7 * 15 + 10];
        assert_eq(board::is_path_correct(&board, &path, 2, 1), true);
        assert_eq(board::is_path_correct(&board, &path, 2, 2), false);

        let path = vector[0 * 15 + 2, 1 * 15 + 2, 2 * 15 + 2, 3 * 15 + 2, 4 * 15 + 2];
        assert_eq(board::is_path_correct(&board, &path, 0, 1), true);

        let path = vector[0 * 15 + 14, 1 * 15 + 14, 2 * 15 + 14, 3 * 15 + 14, 4 * 15 + 14];
        assert_eq(board::is_path_correct(&board, &path, 0, 1), true);

        let path = vector[14 * 15 + 0, 14 * 15 + 1, 14 * 15 + 2, 14 * 15 + 3, 14 * 15 + 4];
        assert_eq(board::is_path_correct(&board, &path, 1, 1), true);

        let path = vector[11 * 15 + 8, 11 * 15 + 9, 11 * 15 + 10, 11 * 15 + 11, 11 * 15 + 12];
        assert_eq(board::is_path_correct(&board, &path, 1, 1), true);

        let path = vector[11 * 15 + 7, 11 * 15 + 8, 11 * 15 + 9, 11 * 15 + 10, 11 * 15 + 11];
        assert_eq(board::is_path_correct(&board, &path, 1, 1), false);

        let path = vector[11 * 15 + 8, 11 * 15 + 9, 11 * 15 + 10, 11 * 15 + 11, 11 * 15 + 13];
        assert_eq(board::is_path_correct(&board, &path, 1, 1), false);

        let path = vector[6 * 15 + 9, 7 * 15 + 8, 8 * 15 + 7, 9 * 15 + 6, 10 * 15 + 5];
        assert_eq(board::is_path_correct(&board, &path, 3, 1), true);

        // let path = vector[3, 7, 12, 13, 18, 23];
        // assert_eq(board::is_path_correct(&board, &path, 1), false);

        // let path = vector[3, 7, 12, 13, 18];
        // assert_eq(board::is_path_correct(&board, &path, 1), false);

        // let path = vector[3, 7, 12, 13, 18, 21];
        // assert_eq(board::is_path_correct(&board, &path, 1), false);
    }



}