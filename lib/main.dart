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
      title: 'Pirate Language Adventure',
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
  String userId = 'user123';
  Map<String, dynamic> userProgress = {'level': 1, 'treasure_pieces': 0};
  List<dynamic> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuiz('easy');
  }

  Future<void> fetchQuiz(String difficulty) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.35:5000/get-quiz/$difficulty'));
      if (response.statusCode == 200) {
        setState(() {
          questions = json.decode(response.body)['questions'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Erreur lors de la récupération des questions : ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur: $e');
    }
  }

  Future<void> submitAnswer(String answer, String correctAnswer) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.35:5000/quiz-result/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'user_answer': answer, 'correct_answer': correctAnswer}),
      );
      if (response.statusCode == 200) {
        setState(() {
          userProgress = json.decode(response.body)['user_progress'];
        });
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pirate Language Adventure'),
      ),
      body: Container(
        color: Colors.grey[200],  // Arrière-plan léger
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Level: ${userProgress['level']} | Treasure Pieces: ${userProgress['treasure_pieces']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: questions.isEmpty
                        ? Center(child: Text('Aucune question disponible'))
                        : ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],  // Couleur de fond
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        question['question'] ?? 'Question indisponible',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          submitAnswer(
                                            'Sample Answer',
                                            question['correct_answer'] ?? '',
                                          );
                                        },
                                        child: Text('Répondre'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
