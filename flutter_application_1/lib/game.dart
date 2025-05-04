import 'dart:math';
import 'tile.dart';
import 'config.dart';

class MinesweeperGame {
  late List<List<Tile>> board;
  final GameConfig config;
  bool gameOver = false;
  bool gameWon = false;
  int flagsPlaced = 0;
  DateTime? startTime;

  MinesweeperGame(this.config) {
    startTime = DateTime.now();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(
      config.height,
      (y) => List.generate(config.width, (x) => Tile()),
    );
    _placeMines();
    _calculateAdjacentMines();
  }

  void _placeMines() {
    Random random = Random();
    int minesPlaced = 0;

    while (minesPlaced < config.mines) {
      int x = random.nextInt(config.width);
      int y = random.nextInt(config.height);

      if (!board[y][x].isMine) {
        board[y][x].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int y = 0; y < config.height; y++) {
      for (int x = 0; x < config.width; x++) {
        if (!board[y][x].isMine) {
          int count = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              int nx = x + dx;
              int ny = y + dy;
              if (nx >= 0 &&
                  nx < config.width &&
                  ny >= 0 &&
                  ny < config.height &&
                  board[ny][nx].isMine) {
                count++;
              }
            }
          }
          board[y][x].adjacentMines = count;
        }
      }
    }
  }

  void revealTile(int x, int y) {
    if (gameOver || gameWon || board[y][x].isRevealed || board[y][x].isFlagged) {
      return;
    }

    board[y][x].isRevealed = true;

    if (board[y][x].isMine) {
      gameOver = true;
      return;
    }

    if (board[y][x].adjacentMines == 0) {
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          int nx = x + dx;
          int ny = y + dy;
          if (nx >= 0 && nx < config.width && ny >= 0 && ny < config.height) {
            revealTile(nx, ny);
          }
        }
      }
    }

    _checkWinCondition();
  }

  void toggleFlag(int x, int y) {
    if (gameOver || gameWon || board[y][x].isRevealed) return;

    board[y][x].isFlagged = !board[y][x].isFlagged;
    flagsPlaced += board[y][x].isFlagged ? 1 : -1;
  }

  void _checkWinCondition() {
    bool allNonMinesRevealed = true;
    for (int y = 0; y < config.height; y++) {
      for (int x = 0; x < config.width; x++) {
        if (!board[y][x].isMine && !board[y][x].isRevealed) {
          allNonMinesRevealed = false;
          break;
        }
      }
      if (!allNonMinesRevealed) break;
    }

    if (allNonMinesRevealed) {
      gameWon = true;
    }
  }

  int get elapsedTime =>
      startTime != null ? DateTime.now().difference(startTime!).inSeconds : 0;
}
