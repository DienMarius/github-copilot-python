# Project Instructions

## Tech Stack

- Python 3.11+ for the application backend.
- Flask 3.x for HTTP routes and server-side HTML rendering.
- Vanilla JavaScript for browser behavior and API calls.
- Plain CSS for responsive layout, light/dark themes, and Sudoku board styling.
- `unittest` for automated backend tests.
- The runnable application is in `starter/`.

## Project Structure

- `starter/app.py`: Flask application and JSON endpoints.
- `starter/sudoku_logic.py`: Sudoku generation, solving, validation, and difficulty rules.
- `starter/templates/index.html`: page structure and accessible controls.
- `starter/static/main.js`: board rendering, user interaction, timer, hints, theme, and local scores.
- `starter/static/styles.css`: visual design and responsive behavior.
- `starter/test_sudoku.py`: regression tests for puzzle generation and API behavior.
- `starter/requirements.txt`: Python dependencies.

## Coding Conventions

- Use clear, descriptive `snake_case` names in Python and `camelCase` names in JavaScript.
- Keep Sudoku rules and puzzle generation in `sudoku_logic.py`; do not duplicate them in Flask routes or browser code.
- Keep Flask routes small: validate request data, call the logic layer, and return JSON or a template.
- Add Python type annotations to new public functions and use constants for shared game values.
- Prefer small functions with one responsibility and avoid unrelated refactors.
- Use `request.get_json(silent=True)` and return a useful JSON error with HTTP 400 for invalid client input.
- Do not expose the solution in the `/new` response. The `/check` and `/hint` endpoints are responsible for solution-backed actions.
- Escape user-controlled text before inserting it into browser HTML.
- Use event delegation for dynamically rendered Sudoku cells.
- Keep prefilled and hinted cells disabled in the browser so users cannot overwrite them.
- Use accessible labels, status messages, keyboard-friendly controls, and responsive dimensions.

## Sudoku Requirements

- Every generated board must be a valid 9x9 Sudoku.
- Every puzzle must have exactly one solution. Use `count_solutions` with an early-stop limit of two while removing cells.
- Difficulty must change the exact number of clues:
  - Easy: 45 clues.
  - Medium: 36 clues.
  - Hard: 30 clues.
- Never remove a clue if doing so creates zero or multiple solutions.
- Preserve the completed solution separately from the puzzle presented to the player.
- Invalid row, column, or 3x3 square entries should receive immediate visual feedback.
- The check action must identify every cell that does not match the solution.
- A correctly completed board must show a clear completion message and stop the timer.

## Validation and Development

Run commands from `starter/` using the project virtual environment when available:

```powershell
..\source\Scripts\python.exe -m unittest -v test_sudoku.py
..\source\Scripts\python.exe app.py
```

Before completing a change:

1. Run the regression tests.
2. Confirm all configured difficulties still produce the expected clue count.
3. Confirm generated puzzles have exactly one solution.
4. Check Flask input validation for malformed JSON and invalid board shapes.
5. Check the UI at desktop and mobile widths when changing HTML or CSS.

Do not commit generated caches, virtual-environment files, or secrets.

## Copilot Review Example

One generated suggestion proposed removing cells at random until the requested clue count was reached. That approach was rejected because it can produce puzzles with multiple valid solutions. The implementation was adjusted to try each removal and restore the value unless `count_solutions` returns exactly one solution.
