import 'package:flutter/material.dart';

enum GameDifficulty { easy, medium, hard }

class GameConfig {
  final int width;
  final int height;
  final int mines;
  final Color hiddenColor;
  final Color revealedColor;
  final Map<int, Color> numberColors;

  GameConfig({
    required this.width,
    required this.height,
    required this.mines,
    this.hiddenColor = const Color(0xFFBBBBBB),
    this.revealedColor = const Color(0xFFEEEEEE),
    this.numberColors = const {
      1: Colors.blue,
      2: Colors.green,
      3: Colors.red,
      4: Colors.purple,
      5: Colors.brown,
      6: Colors.teal,
      7: Colors.black,
      8: Colors.grey,
    },
  });

  factory GameConfig.difficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return GameConfig(width: 8, height: 8, mines: 10);
      case GameDifficulty.medium:
        return GameConfig(width: 10, height: 10, mines: 20);
      case GameDifficulty.hard:
        return GameConfig(width: 12, height: 12, mines: 40);
    }
  }
}