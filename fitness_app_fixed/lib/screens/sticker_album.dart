import 'package:flutter/material.dart';

class StickerAlbumScreen extends StatelessWidget {
  final List<String> earnedStickers = [
    'Lion Sticker',
    'Rainbow Sticker',
    'Rocket Sticker',
  ]; // Dynamically load from DB if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎨 Sticker Album")),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: earnedStickers.map((sticker) {
          return Card(
            color: Colors.purple[50],
            child: Center(
              child: Text(
                sticker,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
