import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class QuestionPage extends StatefulWidget {
  final Map<String, dynamic> question;
  final String userId;

  QuestionPage({required this.question, required this.userId});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String selectedAnswer = '';

  Future<void> submitAnswer(String answer) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.35:5000/quiz-result/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'user_answer': answer,
          'correct_answer': widget.question['correct_answer']
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        bool isCorrect = answer == widget.question['correct_answer'];

        // Affiche une alerte en cas de bonne ou mauvaise réponse
        _showResultDialog(isCorrect);
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void _showResultDialog(bool correct) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(correct ? 'Bravo !' : 'Oups...'),
          content: Text(correct
              ? 'Bonne réponse ! 🎉'
              : 'Mauvaise réponse. Essayez encore ! 😢'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (correct) {
                  Navigator.of(context).pop(); // Retourner à la liste de questions
                }
              },
              child: Text(correct ? 'Continuer' : 'Réessayer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = [
      widget.question['correct_answer'],
      'Option 2',
      'Option 3'
    ];
    options.shuffle();

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${widget.question['id']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question['question'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...options.map((option) {
              return ListTile(
                title: Text(option),
                leading: Radio<String>(
                  value: option,
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value!;
                    });
                  },
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedAnswer.isNotEmpty) {
                  submitAnswer(selectedAnswer);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez choisir une réponse'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
