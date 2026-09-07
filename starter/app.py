from flask import Flask, render_template, jsonify, request
import sudoku_logic

app = Flask(__name__)

# Keep a simple in-memory store for current puzzle and solution
CURRENT = {
    'puzzle': None,
    'solution': None
}

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/new')
def new_game():
    if 'clues' in request.args:
        try:
            clues = int(request.args['clues'])
        except (TypeError, ValueError):
            return jsonify({'error': 'clues must be an integer'}), 400
        if not sudoku_logic.MIN_CLUES <= clues <= sudoku_logic.SIZE ** 2:
            return jsonify({'error': f'clues must be between {sudoku_logic.MIN_CLUES} and {sudoku_logic.SIZE ** 2}'}), 400
        difficulty = 'custom'
    else:
        difficulty = request.args.get('difficulty', 'medium').lower()
        clues = sudoku_logic.DIFFICULTIES.get(difficulty)
        if clues is None:
            return jsonify({'error': 'Difficulty must be easy, medium, or hard'}), 400
    try:
        puzzle, solution = sudoku_logic.generate_puzzle(clues)
    except RuntimeError as error:
        return jsonify({'error': str(error)}), 503
    CURRENT['puzzle'] = puzzle
    CURRENT['solution'] = solution
    return jsonify({'puzzle': puzzle, 'difficulty': difficulty})

@app.route('/check', methods=['POST'])
def check_solution():
    data = request.get_json(silent=True)
    board = data.get('board') if isinstance(data, dict) else None
    solution = CURRENT.get('solution')
    if solution is None:
        return jsonify({'error': 'No game in progress'}), 400
    size = sudoku_logic.SIZE
    valid = (
        isinstance(board, list) and len(board) == size
        and all(isinstance(row, list) and len(row) == size
                and all(type(value) is int and 0 <= value <= size for value in row)
                for row in board)
    )
    if not valid:
        return jsonify({'error': 'Expected a 9x9 board of integers 0-9'}), 400
    incorrect = []
    for i in range(sudoku_logic.SIZE):
        for j in range(sudoku_logic.SIZE):
            if board[i][j] != solution[i][j]:
                incorrect.append([i, j])
    return jsonify({'incorrect': incorrect})


@app.route('/hint', methods=['POST'])
def hint():
    data = request.get_json(silent=True)
    row = data.get('row') if isinstance(data, dict) else None
    col = data.get('col') if isinstance(data, dict) else None
    solution = CURRENT.get('solution')
    puzzle = CURRENT.get('puzzle')
    if solution is None or puzzle is None:
        return jsonify({'error': 'No game in progress'}), 400
    if not isinstance(row, int) or not isinstance(col, int) or not 0 <= row < 9 or not 0 <= col < 9:
        return jsonify({'error': 'Invalid cell'}), 400
    if puzzle[row][col] != sudoku_logic.EMPTY:
        return jsonify({'error': 'That cell is already filled'}), 400
    return jsonify({'row': row, 'col': col, 'value': solution[row][col]})


@app.route('/solve-steps')
def solve_steps():
    puzzle = CURRENT.get('puzzle')
    solution = CURRENT.get('solution')
    if puzzle is None or solution is None:
        return jsonify({'error': 'No game in progress'}), 400
    steps = [
        {'row': row, 'col': col, 'value': solution[row][col]}
        for row in range(sudoku_logic.SIZE)
        for col in range(sudoku_logic.SIZE)
        if puzzle[row][col] == sudoku_logic.EMPTY
    ]
    return jsonify({'steps': steps})

if __name__ == '__main__':
    app.run(debug=True)