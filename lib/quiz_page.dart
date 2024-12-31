import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  final String difficulty;
  final int questionCount;
  final int userId;
  final int lessonId;

  QuizPage({
    required this.difficulty,
    required this.questionCount,
    required this.userId,
    required this.lessonId,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int correctAnswers = 0;
  bool isLoading = true;
  bool hasError = false;

  List<Map<String, dynamic>> questions = [];  // Modification ici (String -> dynamic)

  @override
  void initState() {
    super.initState();
    initUser();
    fetchQuestions();
  }

  Future<void> initUser() async {
    final url = Uri.parse('http://192.168.1.35:5000/init-user/${widget.userId}');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('Utilisateur initialisé avec succès');
    } else {
      print('Erreur lors de l\'initialisation de l\'utilisateur');
    }
  }

  Future<void> fetchQuestions() async {
    final url = Uri.parse('http://192.168.1.35:5000/get-quiz/${widget.lessonId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> fetchedQuestions = data['questions'];

        setState(() {
          questions = fetchedQuestions
              .take(widget.questionCount)
              .map((q) => {
                    'question': q['question'].toString(),
                    'choices': List<String>.from(json.decode(q['choices'])),  // Ajouter les choix
                    'answer': q['answer'].toString(),
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> sendQuizResult(double score) async {
    final url = Uri.parse('http://192.168.1.35:5000/quiz-result/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': widget.userId,
        'score': score,
        'lesson_id': widget.lessonId,  // Utiliser l'ID de la leçon en cours
      }),
    );

    if (response.statusCode == 200) {
      print('Progression mise à jour');
    } else {
      print('Erreur lors de la mise à jour de la progression');
    }
  }

  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == questions[currentQuestion]['answer']) {
      correctAnswers++;
    }

    setState(() {
      if (currentQuestion < widget.questionCount - 1) {
        currentQuestion++;
      } else {
        double score = (correctAnswers / widget.questionCount) * 100;
        sendQuizResult(score);
        Navigator.pop(context, score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestion + 1) / widget.questionCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${widget.difficulty.toUpperCase()}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erreur lors du chargement des questions.'))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              color: Colors.blue,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          Text(
                            '${((progress) * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        questions[currentQuestion]['question']!,
                        style: TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: List.generate(
                          questions[currentQuestion]['choices'].length,
                          (index) {
                            String choice =
                                questions[currentQuestion]['choices'][index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  checkAnswer(choice);
                                },
                                child: Text(choice),
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
