module tic_tac_toe_5_in_row::board {
    // === Imports ===

    use std::vector;

    // === Friends ===

    friend tic_tac_toe_5_in_row::main;
    #[test_only]
    friend tic_tac_toe_5_in_row::board_tests;

    // === Structs ===

    struct Board has store, drop {
        size: u8,
        field: vector<u8>,
    }

    // === Public-Friend Functions ===

    public(friend) fun create_board(size: u8): Board {
        let board = Board { size, field: vector::empty() };
        let i = size * size;
        while (i > 0) {
            i = i - 1;
            vector::push_back(&mut board.field, 0);
        };

        board
    }

    public(friend) fun is_tile_free(self: &Board, tile: u8): bool {
        *vector::borrow(&self.field, (tile as u64)) == 0
    }

    public(friend) fun set_tile(self: &mut Board, tile: u8, player_num: u8) {
        *vector::borrow_mut(&mut self.field, (tile as u64)) = player_num;
    }

    // direction: 0 - from top to bottom, 1 - from left to right, 2 - from top-left to bottom-right, 3 - from top-right to bottom-left
    public(friend) fun is_path_correct(self: &Board, path: &vector<u8>, direction: u8, player_num: u8): bool {
        if (vector::length(path) != 5) {
            return false
        };
        if (direction > 3) {
            return false
        };

        let prev_tile_col = 0;
        let prev_tile_row = 0;

        let i = 0;
        while (i < vector::length(path)) {
            let tile = *vector::borrow(path, i);

            if (tile >= self.size * self.size) {
                return false
            };
            if (*vector::borrow(&self.field, (tile as u64)) != player_num) {
                return false
            };

            let tile_col = tile % self.size;
            let tile_row = tile / self.size;

            if (i > 0) {
                if (direction == 0) {
                    if (!(tile_col == prev_tile_col && tile_row - 1 == prev_tile_row)) {
                        return false
                    };
                } else if (direction == 1) {
                    if (!(tile_row == prev_tile_row && tile_col - 1 == prev_tile_col)) {
                        return false
                    };
                } else if (direction == 2) {
                    if (!(tile_col - 1 == prev_tile_col && tile_row - 1 == prev_tile_row)) {
                        return false
                    };
                } else {
                    if (!(tile_col + 1 == prev_tile_col && tile_row - 1 == prev_tile_row)) {
                        return false
                    };
                }
            };

            prev_tile_col = tile_col;
            prev_tile_row = tile_row;

            i = i + 1;
        };

        true

    }

    // === Test Functions ===

    #[test_only]
    public fun create_board_for_testing(size: u8, field: vector<u8>): Board {
        Board { size, field }
    }

    #[test_only]
    public fun get_field_for_testing(board: Board): vector<u8> {
        board.field
    }

}