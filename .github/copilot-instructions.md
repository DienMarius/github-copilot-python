# Copilot Instructions

## Project Scope and Stack

This repository contains a Sudoku application in `starter/` built with:

- Python 3.11+ and Flask 3.x for the backend and HTML rendering.
- Vanilla JavaScript for browser behavior and API calls.
- Plain CSS for responsive layout, light/dark themes, and Sudoku styling.
- Python `unittest` for regression tests.

## Ownership Boundaries

- Keep Flask routes, request validation, and JSON responses in `starter/app.py`.
- Keep Sudoku generation, solving, validation, and difficulty rules in `starter/sudoku_logic.py`.
- Keep browser rendering, event handling, timer, hints, theme switching, and local scores in `starter/static/main.js`.
- Keep page structure in `starter/templates/index.html` and visual rules in `starter/static/styles.css`.
- Keep backend regression tests in `starter/test_sudoku.py`.

Do not duplicate Sudoku algorithms in Flask routes or browser code. Keep route handlers small: validate input, call the logic layer, and return a template or JSON response.

## Data Model and Sudoku Rules

- A board is a 9x9 list of lists of integers.
- The integer `0` represents an empty cell; playable values are integers `1` through `9`.
- Every generated solution must be a valid Sudoku with no duplicate values in any row, column, or 3x3 box.
- Before accepting any clue removal, count the puzzle's solutions and accept the removal only when the count is exactly one.
- Use an early-stop solution counter with a limit of two so multiple solutions are detected efficiently.
- Easy, Medium, and Hard must retain their configured clue counts.
- Keep the puzzle and completed solution separate, and never expose the solution from the `/new` response.

## API and Error Handling

- Parse JSON with `request.get_json(silent=True)`.
- Return consistent JSON errors in the shape `{"error": "readable message"}` with HTTP 400 for malformed or invalid client input.
- Validate board dimensions and every cell value before checking a solution.
- Validate difficulty names and hint coordinates at the route boundary.
- Escape user-controlled names before inserting them into browser HTML.

## Coding Conventions

- Use descriptive `snake_case` names and type annotations in Python.
- Use descriptive `camelCase` names in JavaScript.
- Prefer small, single-purpose functions and constants for shared values.
- Use event delegation for dynamically rendered Sudoku cells.
- Keep prefilled and hinted cells disabled so they cannot be overwritten.
- Preserve accessible labels, live status messages, keyboard-friendly controls, and responsive dimensions.
- Avoid unrelated refactors, generated files, caches, secrets, and dependency churn.

## Verified Run and Test Commands

Run commands from `starter/` with the project virtual environment:

```powershell
..\source\Scripts\python.exe -m unittest -v test_sudoku.py
..\source\Scripts\python.exe app.py
```

Before completing a change, run the regression suite and, when relevant, verify clue counts, exact-one-solution generation, malformed JSON handling, invalid board shapes, and the browser at mobile and desktop widths.

## Active Review Example

A random cell-removal suggestion was rejected because it could create puzzles with multiple solutions. The implementation instead tentatively removes each cell, calls `count_solutions`, and restores the value unless exactly one solution remains.
