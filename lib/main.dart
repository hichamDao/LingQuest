import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu Pirate Langue',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userId = 'user123';  // Identifiant de l'utilisateur (statique pour l'exemple)
  int level = 1;
  int treasurePieces = 0;
  List<dynamic> leaderboard = [];

  // Envoi des réponses de l'utilisateur
  Future<void> submitQuizAnswer(String userAnswer, String correctAnswer) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.35:5000/quiz-result/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'user_id': userId,
        'user_answer': userAnswer,
        'correct_answer': correctAnswer,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        level = data['user_progress']['level'];
        treasurePieces = data['user_progress']['treasure_pieces'];
      });
    } else {
      print('Erreur de la requête');
    }
  }

  // Récupérer le leaderboard
  Future<void> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/leaderboard'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        leaderboard = data['leaderboard'];
      });
    } else {
      print('Erreur lors du chargement du leaderboard');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jeu Pirate Langue')),
      body: Column(
        children: <Widget>[
          // Afficher la progression
          Text('Niveau: $level, Pièces du trésor: $treasurePieces'),
          
          // Simuler une question
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => submitQuizAnswer('Bonjour', 'Bonjour'),
              child: Text('Répondre à la question'),
            ),
          ),
          
          // Afficher le leaderboard
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                return ListTile(
                  title: Text(user['user_id']),
                  subtitle: Text('Niveau: ${user['level']} | Pièces: ${user['treasure_pieces']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
