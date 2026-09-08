from __future__ import annotations

import copy
import random
from typing import Final

SIZE = 9
EMPTY = 0
MIN_CLUES = 17
MAX_GENERATION_ATTEMPTS = 5
DIFFICULTIES: Final = {'easy': 45, 'medium': 36, 'hard': 30}

def deep_copy(board: list[list[int]]) -> list[list[int]]:
    return copy.deepcopy(board)

def create_empty_board() -> list[list[int]]:
    return [[EMPTY for _ in range(SIZE)] for _ in range(SIZE)]

def is_safe(board: list[list[int]], row: int, col: int, num: int) -> bool:
    for x in range(SIZE):
        if board[row][x] == num or board[x][col] == num:
            return False
    start_row = row - row % 3
    start_col = col - col % 3
    for i in range(3):
        for j in range(3):
            if board[start_row + i][start_col + j] == num:
                return False
    return True

def fill_board(board: list[list[int]]) -> bool:
    for row in range(SIZE):
        for col in range(SIZE):
            if board[row][col] == EMPTY:
                possible = list(range(1, SIZE + 1))
                random.shuffle(possible)
                for candidate in possible:
                    if is_safe(board, row, col, candidate):
                        board[row][col] = candidate
                        if fill_board(board):
                            return True
                        board[row][col] = EMPTY
                return False
    return True

def _is_valid_partial_board(board: list[list[int]]) -> bool:
    for row in range(SIZE):
        for col in range(SIZE):
            value = board[row][col]
            if type(value) is not int or not 0 <= value <= SIZE:
                return False
            if value != EMPTY:
                board[row][col] = EMPTY
                valid = is_safe(board, row, col, value)
                board[row][col] = value
                if not valid:
                    return False
    return True


def _count_solutions(board: list[list[int]], limit: int) -> int:
    for row in range(SIZE):
        for col in range(SIZE):
            if board[row][col] == EMPTY:
                total = 0
                for candidate in range(1, SIZE + 1):
                    if is_safe(board, row, col, candidate):
                        board[row][col] = candidate
                        total += _count_solutions(board, limit - total)
                        board[row][col] = EMPTY
                        if total >= limit:
                            return total
                return total
    return 1


def count_solutions(board: list[list[int]], limit: int = 2) -> int:
    """Count valid completions, stopping after ``limit`` solutions."""
    if limit <= 0 or not _is_valid_partial_board(board):
        return 0
    return _count_solutions(board, limit)


def remove_cells(board: list[list[int]], clues: int) -> bool:
    """Remove only cells that preserve a single solution.

    A random-removal suggestion was rejected after recognizing that removing
    clues without solving the candidate can leave multiple valid completions.
    Each tentative removal is therefore verified with count_solutions and
    restored unless the candidate has exactly one solution.
    """
    positions = [(row, col) for row in range(SIZE) for col in range(SIZE)]
    random.shuffle(positions)
    for row, col in positions:
        if sum(cell != EMPTY for line in board for cell in line) <= clues:
            return True
        value = board[row][col]
        board[row][col] = EMPTY
        if count_solutions(board) != 1:
            board[row][col] = value
    return sum(cell != EMPTY for line in board for cell in line) == clues

def generate_puzzle(clues: int = 36) -> tuple[list[list[int]], list[list[int]]]:
    if not MIN_CLUES <= clues <= SIZE * SIZE:
        raise ValueError(f'clues must be between {MIN_CLUES} and {SIZE * SIZE}')
    for _ in range(MAX_GENERATION_ATTEMPTS):
        board = create_empty_board()
        fill_board(board)
        solution = deep_copy(board)
        if remove_cells(board, clues):
            return deep_copy(board), solution
    raise RuntimeError(f'Could not generate a unique puzzle with {clues} clues')


#sudoku logic revised from copilot suggestion.