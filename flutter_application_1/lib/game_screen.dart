import 'package:flutter/material.dart';
import 'config.dart';
import 'game.dart';
import 'tile.dart';
import 'win_screen.dart';

class GameScreen extends StatefulWidget {
  final GameDifficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MinesweeperGame game;
  late GameConfig config;

  @override
  void initState() {
    super.initState();
    config = GameConfig.difficulty(widget.difficulty);
    game = MinesweeperGame(config);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Помощь'),
            content: const Text(
              '• Клик - открыть клетку\n'
              '• Долгое нажатие - поставить флаг 🚩\n'
              '• Число показывает количество мин рядом\n'
              '• Откройте все безопасные клетки для победы!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Понятно'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сапер - ${widget.difficulty.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showHelpDialog,
            tooltip: 'Помощь',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Флаги: ${game.flagsPlaced}/${config.mines}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Время: ${game.elapsedTime}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: config.width,
              ),
              itemCount: config.width * config.height,
              itemBuilder: (context, index) {
                int x = index % config.width;
                int y = index ~/ config.width;
                return GestureDetector(
                  onTap: () => _handleTap(x, y),
                  onLongPress: () => _handleLongPress(x, y),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getTileColor(game.board[y][x]),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: Center(child: _getTileContent(game.board[y][x])),
                  ),
                );
              },
            ),
            if (game.gameOver || game.gameWon) ...[
              const SizedBox(height: 20),
              Text(
                game.gameOver ? 'Игра окончена!' : 'Победа!',
                style: TextStyle(
                  fontSize: 24,
                  color: game.gameOver ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (game.gameWon) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WinScreen(
                              difficulty: widget.difficulty,
                              time: game.elapsedTime,
                            ),
                      ),
                    );
                  } else {
                    setState(() {
                      game = MinesweeperGame(config);
                    });
                  }
                },
                child: Text(
                  game.gameWon ? 'Посмотреть результат' : 'Играть снова',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTap(int x, int y) {
    setState(() {
      game.revealTile(x, y);
    });
  }

  void _handleLongPress(int x, int y) {
    setState(() {
      game.toggleFlag(x, y);
    });
  }

  Color _getTileColor(Tile tile) {
    if (tile.isRevealed) {
      return tile.isMine ? Colors.red : config.revealedColor;
    }
    return config.hiddenColor;
  }

  Widget? _getTileContent(Tile tile) {
    if (!tile.isRevealed) {
      return tile.isFlagged
          ? const Text('🚩', style: TextStyle(fontSize: 20))
          : null;
    }
    if (tile.isMine) {
      return const Text('💣', style: TextStyle(fontSize: 20));
    }
    if (tile.adjacentMines > 0) {
      return Text(
        tile.adjacentMines.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: config.numberColors[tile.adjacentMines],
        ),
      );
    }
    return null;
  }
}
