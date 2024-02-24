module hex_game::board {
    // === Imports ===

    use std::vector;

    // === Friends ===

    friend hex_game::main;

    // === Structs ===

    struct Board has store {
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

    public(friend) fun is_path_correct(self: &Board, path: &vector<u8>, player_num: u8): bool {
        // if (vector::length(path) < (board.size as u64)) {
        //     return false;
        // };

        let board_size = self.size;

        let board_size_full = board_size * board_size;

        let prev_tile_col = 0;
        let prev_tile_row = 0;

        let i = 0;
        while (i < vector::length(path)) {
            let tile_num = *vector::borrow(path, i);
            if (tile_num >= board_size_full) {
                return false
            };

            if (*vector::borrow(&self.field, (tile_num as u64)) != player_num) {
                return false
            };
            let tile_col = tile_num % board_size;
            let tile_row = tile_num / board_size;

            if (i == 0) {
                if (player_num == 1) {
                    if (tile_row != 0) return false
                } else {
                    if (tile_col != 0) return false
                };

            } else {
                if (!(tile_col - 1 == prev_tile_col && tile_row == prev_tile_row
                    || tile_col + 1 == prev_tile_col && tile_row == prev_tile_row
                    || tile_col == prev_tile_col && tile_row - 1 == prev_tile_row
                    || tile_col == prev_tile_col && tile_row + 1 == prev_tile_row
                    || tile_col + 1 == prev_tile_col && tile_row - 1 == prev_tile_row
                    || tile_col - 1 == prev_tile_col && tile_row + 1 == prev_tile_row))
                {
                    return false
                };
            };

            prev_tile_col = tile_col;
            prev_tile_row = tile_row;

            i = i + 1;
        };

        if (player_num == 1) {
            if (prev_tile_row != (board_size - 1)) return false;
        } else {
            if (prev_tile_col != (board_size - 1)) return false;
        };

        true

    }
}