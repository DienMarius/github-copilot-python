const SIZE = 9;
const SCORES_KEY = 'sudoku-top-scores';
const THEME_KEY = 'sudoku-theme';
let puzzle = [];
let difficulty = 'medium';
let seconds = 0;
let hintsUsed = 0;
let startTime = 0;
let timerId = null;
let finished = false;
let selectedNumber = null;
let noteMode = false;
let notes = new Map();
let solving = false;

const boardElement = () => document.getElementById('sudoku-board');
const inputs = () => [...boardElement().querySelectorAll('input')];
const cellAt = (row, col) => inputs().find((input) => Number(input.dataset.row) === row && Number(input.dataset.col) === col);
const cellKey = (row, col) => `${row}-${col}`;

function showMessage(text, kind = '') {
  const message = document.getElementById('message');
  message.textContent = text;
  message.className = kind;
}

function formatTime(value) {
  return `${String(Math.floor(value / 60)).padStart(2, '0')}:${String(value % 60).padStart(2, '0')}`;
}

function startTimer() {
  clearInterval(timerId);
  startTime = Date.now();
  seconds = 0;
  hintsUsed = 0;
  finished = false;
  document.getElementById('timer').textContent = formatTime(seconds);
  timerId = setInterval(() => {
    if (!finished) {
      seconds = Math.floor((Date.now() - startTime) / 1000);
      document.getElementById('timer').textContent = formatTime(seconds);
    }
  }, 1000);
}

function stopTimer() {
  clearInterval(timerId);
  timerId = null;
  seconds = Math.floor((Date.now() - startTime) / 1000);
  document.getElementById('timer').textContent = formatTime(seconds);
}

function createBoard() {
  boardElement().innerHTML = Array.from({ length: SIZE }, (_, row) =>
    `<div class="sudoku-row" role="row">${Array.from({ length: SIZE }, (_, col) =>
      `<div class="cell-wrap box-${(Math.floor(row / 3) + Math.floor(col / 3)) % 2 ? 'b' : 'a'}"><input class="sudoku-cell" role="gridcell" type="text" inputmode="numeric" maxlength="1" aria-label="Row ${row + 1}, column ${col + 1}" data-row="${row}" data-col="${col}"><span class="cell-notes" aria-hidden="true"></span></div>`
    ).join('')}</div>`
  ).join('');
}

function renderPuzzle(nextPuzzle) {
  puzzle = nextPuzzle;
  notes = new Map();
  selectedNumber = null;
  noteMode = false;
  createBoard();
  inputs().forEach((input) => {
    const row = Number(input.dataset.row);
    const col = Number(input.dataset.col);
    if (puzzle[row][col]) {
      input.value = puzzle[row][col];
      input.disabled = true;
      input.classList.add('prefilled');
    }
  });
  document.getElementById('difficulty-label').textContent = `${difficulty[0].toUpperCase()}${difficulty.slice(1)} puzzle`;
  updateNoteMode();
  renderNumberPalette();
  startTimer();
  showMessage('');
}

function readBoard() {
  return Array.from({ length: SIZE }, (_, row) =>
    Array.from({ length: SIZE }, (_, col) => Number(cellAt(row, col).value) || 0)
  );
}

function hasConflict(row, col, value, board) {
  for (let index = 0; index < SIZE; index += 1) {
    if ((index !== col && board[row][index] === value) || (index !== row && board[index][col] === value)) return true;
  }
  const startRow = row - row % 3;
  const startCol = col - col % 3;
  for (let boxRow = startRow; boxRow < startRow + 3; boxRow += 1) {
    for (let boxCol = startCol; boxCol < startCol + 3; boxCol += 1) {
      if ((boxRow !== row || boxCol !== col) && board[boxRow][boxCol] === value) return true;
    }
  }
  return false;
}

function markConflicts(board) {
  inputs().forEach((input) => {
    if (input.disabled || !input.value) {
      input.classList.remove('invalid');
      return;
    }
    const row = Number(input.dataset.row);
    const col = Number(input.dataset.col);
    input.classList.toggle('invalid', hasConflict(row, col, board[row][col], board));
  });
}

function handleInput(event) {
  const input = event.target;
  if (!input.matches('input')) return;
  input.value = input.value.replace(/[^1-9]/g, '').slice(0, 1);
  input.classList.remove('incorrect');
  if (!input.value) return;
  const board = readBoard();
  markConflicts(board);
  const invalid = input.classList.contains('invalid');
  highlightNumber();
  if (invalid) showMessage('That number conflicts with this row, column, or square.', 'error');
  else showMessage('');
}

function renderNumberPalette() {
  const palette = document.getElementById('number-palette');
  palette.innerHTML = Array.from({ length: SIZE }, (_, index) => `<button type="button" class="number-button" data-number="${index + 1}" aria-pressed="false">${index + 1}</button>`).join('');
  highlightNumber();
}

function highlightNumber() {
  const board = readBoard();
  inputs().forEach((input) => input.classList.toggle('number-selected', selectedNumber !== null && Number(input.value) === selectedNumber));
  const used = selectedNumber === null ? 0 : board.flat().filter((value) => value === selectedNumber).length;
  const status = document.getElementById('number-status');
  status.textContent = selectedNumber === null ? 'Select a number to highlight it.' : `${selectedNumber}: ${used} of 9 used${used === 9 ? '. All used!' : '.'}`;
}

function updateNotes(input) {
  const row = Number(input.dataset.row);
  const col = Number(input.dataset.col);
  const key = cellKey(row, col);
  const cellNotes = notes.get(key) || new Set();
  const noteElement = input.parentElement.querySelector('.cell-notes');
  noteElement.textContent = [...cellNotes].sort().join(' ');
}

function toggleNote(input, value) {
  if (input.disabled || input.value || value < 1 || value > 9) return;
  const key = cellKey(Number(input.dataset.row), Number(input.dataset.col));
  const cellNotes = notes.get(key) || new Set();
  cellNotes.has(value) ? cellNotes.delete(value) : cellNotes.add(value);
  notes.set(key, cellNotes);
  updateNotes(input);
}

function updateNoteMode() {
  const button = document.getElementById('note-mode');
  button.setAttribute('aria-pressed', String(noteMode));
  button.textContent = `Note mode: ${noteMode ? 'on' : 'off'}`;
}

async function newGame() {
  difficulty = document.getElementById('difficulty').value;
  const data = await requestJson(`/new?difficulty=${difficulty}`);
  if (!data) return;
  renderPuzzle(data.puzzle);
}

async function checkSolution() {
  if (finished) return;
  const data = await requestJson('/check', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ board: readBoard() }) });
  if (!data) return;
  const incorrect = new Set(data.incorrect.map(([row, col]) => `${row}-${col}`));
  inputs().forEach((input) => {
    if (!input.disabled) input.classList.toggle('incorrect', incorrect.has(`${input.dataset.row}-${input.dataset.col}`));
  });
  if (incorrect.size) return showMessage('Some entries need another look.', 'error');
  finished = true;
  stopTimer();
  const name = window.prompt(`Solved in ${formatTime(seconds)} with ${hintsUsed} hint${hintsUsed === 1 ? '' : 's'}. Enter your name for the Top 10:`, 'Anonymous');
  if (name !== null) saveScore(name.trim() || 'Anonymous');
  showMessage(`Puzzle solved in ${formatTime(seconds)} with ${hintsUsed} hint${hintsUsed === 1 ? '' : 's'}. Excellent work!`, 'success');
}

async function giveHint() {
  const openCell = inputs().find((input) => !input.disabled && !input.value);
  if (!openCell) return showMessage('There are no empty cells left.', 'error');
  const data = await requestJson('/hint', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ row: Number(openCell.dataset.row), col: Number(openCell.dataset.col) }) });
  if (!data) return;
  if (!applyHint(openCell, data.value)) return showMessage('That hint could not be applied.', 'error');
  showMessage('A correct cell has been revealed and locked.', 'success');
}

async function animateSolution() {
  if (solving || finished) return;
  solving = true;
  const data = await requestJson('/solve-steps');
  if (!data) { solving = false; return; }
  for (const step of data.steps) {
    const input = cellAt(step.row, step.col);
    if (input && !input.disabled) {
      input.value = step.value;
      input.disabled = true;
      input.classList.add('solver-cell');
      updateNotes(input);
      highlightNumber();
      await new Promise((resolve) => setTimeout(resolve, 90));
    }
  }
  solving = false;
  finished = true;
  stopTimer();
  showMessage('Solver animation complete. Every empty cell matches the solution.', 'success');
}

function loadScores() {
  try { return JSON.parse(localStorage.getItem(SCORES_KEY)) || []; } catch { return []; }
}

function saveScore(name) {
  const scores = [...loadScores(), { name, time: seconds, difficulty, hints: hintsUsed }].sort((a, b) => a.time - b.time).slice(0, 10);
  try { localStorage.setItem(SCORES_KEY, JSON.stringify(scores)); } catch { showMessage('Score saved for this session only.', 'error'); }
  renderScores();
}

function applyHint(input, value) {
  if (input.disabled || input.value !== '') return false;
  if (!Number.isInteger(value) || value < 1 || value > 9) return false;
  input.value = String(value);
  input.disabled = true;
  input.classList.add('hinted');
  hintsUsed += 1;
  return true;
}

function renderScores() {
  const list = document.getElementById('scores');
  const scores = loadScores();
  list.innerHTML = scores.length ? scores.map((score) => `<li><strong>${escapeHtml(score.name)}</strong><span>${formatTime(score.time)} · ${score.difficulty} · ${score.hints ?? 0} hint${score.hints === 1 ? '' : 's'}</span></li>`).join('') : '<li class="empty-score">No scores yet</li>';
}

function escapeHtml(value) {
  return value.replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[character]));
}

function toggleTheme() {
  const dark = document.body.classList.toggle('dark');
  localStorage.setItem(THEME_KEY, dark ? 'dark' : 'light');
}

async function requestJson(url, options = {}) {
  try {
    const response = await fetch(url, options);
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || 'Request failed.');
    return data;
  } catch (error) {
    showMessage(error.message || 'Unable to contact the server.', 'error');
    return null;
  }
}

window.addEventListener('DOMContentLoaded', () => {
  if (localStorage.getItem(THEME_KEY) === 'dark') document.body.classList.add('dark');
  boardElement().addEventListener('input', handleInput);
  boardElement().addEventListener('keydown', (event) => {
    const input = event.target;
    if (!input.matches('input') || !noteMode || !/^[1-9]$/.test(event.key)) return;
    event.preventDefault();
    toggleNote(input, Number(event.key));
  });
  boardElement().addEventListener('focusin', (event) => { if (event.target.matches('input')) highlightNumber(); });
  document.getElementById('number-palette').addEventListener('click', (event) => {
    const button = event.target.closest('[data-number]');
    if (!button) return;
    selectedNumber = Number(button.dataset.number);
    document.querySelectorAll('.number-button').forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
    highlightNumber();
  });
  document.getElementById('new-game').addEventListener('click', newGame);
  document.getElementById('difficulty').addEventListener('change', newGame);
  document.getElementById('hint').addEventListener('click', giveHint);
  document.getElementById('check-solution').addEventListener('click', checkSolution);
  document.getElementById('note-mode').addEventListener('click', () => { noteMode = !noteMode; updateNoteMode(); showMessage(noteMode ? 'Note mode on. Press 1-9 to toggle notes in the focused cell.' : 'Note mode off.'); });
  document.getElementById('solve-animation').addEventListener('click', animateSolution);
  document.getElementById('theme-toggle').addEventListener('click', toggleTheme);
  renderScores();
  newGame();
});
