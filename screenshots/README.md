# Copilot Evidence Screenshots

These screenshots are named for the checklist task they document:

- `testing-framework-setup.png`: the automated test setup and passing regression suite.
- `puzzle-uniqueness-validation.png`: the uniqueness validation behavior documented by the generator and tests.
- `top-10-local-storage.png`: the Top 10 local-storage UI and persistent score surface.
- `sudoku-3x3-grid-styling.png`: the alternating 3x3 square styling and locked-cell presentation.
- `immediate-conflict-feedback.png`: both cells in a duplicate entry highlighted immediately.
- `layout-mobile-360px-light.png` and `layout-mobile-360px-dark.png`: mobile layout and theme checks.
- `layout-desktop-1200px-light.png` and `layout-desktop-1200px-dark.png`: desktop layout and theme checks.

The implementation details behind the evidence are in `starter/test_sudoku.py`, `starter/sudoku_logic.py`, `starter/static/main.js`, and `starter/static/styles.css`.

## Visual Check Results

- The board rendered as 9 rows and 81 cells at both tested sizes.
- Each 3x3 box had exactly one alternating `box-a` or `box-b` color, with the pattern A/B/A, B/A/B, A/B/A.
- The board measured 486px in the narrow browser viewport and 630px at desktop width.
- Toggling the dark theme preserved the board dimensions and updated colors through CSS variables.
- Completed scores store and display the number of hints used; older scores default to zero hints.
- Solving a puzzle clears the timer interval, and starting a new puzzle resets the timer and hint count.

## Conversation Evidence Status

The available Copilot session export contains session metadata only, not readable prompt/response content. Authentic Copilot conversation screenshots cannot be generated from it without reconstructing an interaction, so no conversation is fabricated or relabeled here.

When authentic chat captures are available, use these descriptive filenames:

- `copilot_testing_setup.png`
- `copilot_unique_solution.png`
- `copilot_top10_storage.png`
- `copilot_box_colors.png`

Each capture must show the real focused prompt, a readable response section, and any follow-up review. The existing images in this folder are authentic application/source evidence, but they are not conversation screenshots.

The real evaluation example is documented in `starter/sudoku_logic.py`: random clue removal was rejected because it can leave multiple valid completions; tentative removals are now retained only when `count_solutions` confirms exactly one solution. `starter/test_sudoku.py` verifies that behavior.