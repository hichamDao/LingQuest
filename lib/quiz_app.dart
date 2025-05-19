import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  String generatedQuestion = "Appuyez sur le bouton pour générer une question.";

  // Fonction pour appeler l'API Flask
  Future<void> fetchQuestion(String difficulty, String theme) async {
    final url = Uri.parse('http://127.0.0.1:5000/generate_question'); // Remplacez <votre_IP> par l'adresse de votre serveur
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "difficulty": difficulty,
          "theme": theme,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedQuestion = data['question']; // Question retournée par l'API
        });
      } else {
        setState(() {
          generatedQuestion =
              "Erreur : ${response.statusCode} - ${response.body}";
        });
      }
    } catch (error) {
      setState(() {
        generatedQuestion = "Erreur lors de la connexion à l'API : $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Pirate")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              generatedQuestion,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchQuestion("easy", "pirates"); // Exemple : difficulté facile, thème pirates
              },
              child: Text("Générer une Question"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: QuizApp(),
  ));
}
