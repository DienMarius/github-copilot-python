import unittest

import sudoku_logic
from app import app


class SudokuLogicTests(unittest.TestCase):
    def test_solution_counter_handles_unique_ambiguous_and_unsolvable_boards(self):
        solved = [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ]
        self.assertEqual(sudoku_logic.count_solutions([row[:] for row in solved]), 1)
        self.assertEqual(sudoku_logic.count_solutions(sudoku_logic.create_empty_board()), 2)
        unsolvable = sudoku_logic.create_empty_board()
        unsolvable[0][0] = 1
        unsolvable[0][1] = 1
        self.assertEqual(sudoku_logic.count_solutions(unsolvable), 0)

    def test_each_difficulty_has_expected_clues_and_unique_solution(self):
        for difficulty, clues in sudoku_logic.DIFFICULTIES.items():
            with self.subTest(difficulty=difficulty):
                puzzle, solution = sudoku_logic.generate_puzzle(clues)
                self.assertEqual(sum(cell != sudoku_logic.EMPTY for row in puzzle for cell in row), clues)
                self.assertEqual(sudoku_logic.count_solutions([row[:] for row in puzzle]), 1)
                self.assertEqual(sudoku_logic.count_solutions([row[:] for row in solution]), 1)


class SudokuApiTests(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_difficulty_and_hint_endpoints(self):
        response = self.client.get('/new?difficulty=hard')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['difficulty'], 'hard')
        self.assertEqual(sum(cell == 0 for row in response.json['puzzle'] for cell in row), 51)
        puzzle = response.json['puzzle']
        empty_cell = next((row, col) for row, values in enumerate(puzzle) for col, value in enumerate(values) if value == 0)
        self.assertEqual(self.client.post('/hint', json={'row': empty_cell[0], 'col': empty_cell[1]}).status_code, 200)
        filled_cell = next((row, col) for row, values in enumerate(puzzle) for col, value in enumerate(values) if value != 0)
        response = self.client.post('/hint', json={'row': filled_cell[0], 'col': filled_cell[1]})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'That cell is already filled'})

    def test_solver_steps_use_only_empty_cells_and_solution_values(self):
        response = self.client.get('/new?difficulty=easy')
        puzzle = response.json['puzzle']
        steps = self.client.get('/solve-steps')
        self.assertEqual(steps.status_code, 200)
        self.assertEqual(len(steps.json['steps']), sum(value == 0 for row in puzzle for value in row))
        self.assertTrue(all(puzzle[step['row']][step['col']] == 0 for step in steps.json['steps']))
        self.assertTrue(all(1 <= step['value'] <= 9 for step in steps.json['steps']))

    def test_invalid_board_is_rejected(self):
        self.client.get('/new?difficulty=easy')
        response = self.client.post('/check', json={'board': []})
        self.assertEqual(response.status_code, 400)

    def test_invalid_difficulty_returns_consistent_json_error(self):
        response = self.client.get('/new?difficulty=expert')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'Difficulty must be easy, medium, or hard'})

    def test_custom_clues_validate_before_generation(self):
        response = self.client.get('/new?clues=abc')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'clues must be an integer'})

        response = self.client.get('/new?clues=-1')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'clues must be between 17 and 81'})

        response = self.client.get('/new?clues=82')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'clues must be between 17 and 81'})

        response = self.client.get('/new?clues=0')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json, {'error': 'clues must be between 17 and 81'})

        response = self.client.get('/new?clues=35')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['difficulty'], 'custom')

    def test_malformed_check_payloads_return_json_errors(self):
        self.client.get('/new?difficulty=easy')
        for payload in ({}, {'board': [[1]]}):
            with self.subTest(payload=payload):
                response = self.client.post('/check', json=payload)
                self.assertEqual(response.status_code, 400)
                self.assertEqual(response.json, {'error': 'Expected a 9x9 board of integers 0-9'})


if __name__ == '__main__':
    unittest.main()