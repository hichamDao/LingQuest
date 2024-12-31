import 'package:flutter/material.dart';
import 'quiz_page.dart';

class DifficultySelectionPage extends StatelessWidget {
  final Map<String, String> level;

  DifficultySelectionPage({required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${level['title']} - Choisissez la difficulté')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choisissez la difficulté pour commencer le quiz.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz page with the selected difficulty
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      difficulty: 'easy',  // Example difficulty
                    ),
                  ),
                );
              },
              child: Text('Facile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      difficulty: 'medium',  // Example difficulty
                    ),
                  ),
                );
              },
              child: Text('Moyenne'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      difficulty: 'hard',  // Example difficulty
                    ),
                  ),
                );
              },
              child: Text('Difficile'),
            ),
          ],
        ),
      ),
    );
  }
}
