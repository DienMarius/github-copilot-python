# Copilot Conversation Evidence

Required authentic captures, saved in this `Screenshots/` folder (case-insensitive on Windows):

- `copilot_testing_setup.png`
- `copilot_unique_solution.png`
- `copilot_top10_storage.png`
- `copilot_box_colors.png`

Each capture must show the real task prompt, a readable portion of Copilot's response, and any follow-up review. Do not ask Copilot to explain; ask it to perform the focused task.

The current session export contains metadata only, not readable prompt/response content. Therefore these four conversation screenshots have not been fabricated. The previous PNGs were application/source screenshots, not Copilot conversations, and have been removed from the submission.

Suggested focused prompts for authentic future captures:

- Testing: "In `starter/`, add a small `unittest` suite for the Flask Sudoku API and generator. Make the change, then run the focused test command and report the result."
- Uniqueness: "In `starter/sudoku_logic.py`, revise `remove_cells` so each tentative removal is accepted only when a bounded solution counter finds exactly one solution. Add tests for unique, ambiguous, and unsolvable boards, then run them."
- Top 10: "In `starter/static/main.js`, implement Top 10 localStorage ranking by elapsed seconds with name, difficulty, and hints. Integrate it into successful completion, handle malformed storage, and test more than ten records."
- Box colors: "In `starter/static/main.js` and `starter/static/styles.css`, make the nine 3x3 boxes alternate colors without layout shift. Use explicit box classes, preserve keyboard focus, and validate at mobile and desktop widths."

## Real Evaluation Example

The random clue-removal approach was rejected because removing a clue without counting completions can leave multiple valid solutions. The accepted implementation tentatively removes each clue, calls `count_solutions` with an early-stop limit of two, and restores the clue unless exactly one solution remains. `starter/test_sudoku.py` verifies unique, ambiguous, and unsolvable fixtures.