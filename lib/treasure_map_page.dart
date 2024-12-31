import 'package:flutter/material.dart';

class TreasureMapPage extends StatelessWidget {
  final List<String> clues = [
    'Le trésor est caché sous l\'arbre à l\'est.',
    'Cherchez près de la plage de sable.',
    'Les pierres anciennes marquent le chemin.'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte du Trésor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/treasure_map.png', height: 300), // Carte du trésor
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showClueDialog(context);
              },
              child: Text('Obtenir un indice'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Indice du Trésor'),
          content: Text(clues[(clues.length * 0.5).toInt()]), // Affiche un indice
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
