import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<double> progressLevels = [0.0, 0.0, 0.0];
  List<int> attempts = [1, 1, 1];
  List<bool> isPressed = [false, false, false];
  int hearts = 5;
  int gold = 0;
  Timer? heartRegenTimer;
  DateTime? lastLostHeartTime;
  Duration regenDuration = Duration(hours: 3);
  int? userId;
  String? username;  // Définit le nom d'utilisateur

  @override
  void initState() {
    super.initState();
    
    // Vérifie si l'utilisateur est connecté et récupère sa progression
    if (userId != null) {
      fetchUserProgress();
    }
    
    // Démarre le timer de régénération des cœurs
    startHeartRegenTimer();
  }

  void startHeartRegenTimer() {
    heartRegenTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (hearts < 5 && lastLostHeartTime != null) {
        final now = DateTime.now();
        final timeSinceLoss = now.difference(lastLostHeartTime!);
        if (timeSinceLoss >= regenDuration) {
          setState(() {
            hearts++;
            lastLostHeartTime = (hearts < 5) ? DateTime.now() : null;
          });
        }
      }
    });
  }

  Future<void> rechargeHearts() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.35:5000/recharge-hearts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {
        hearts = 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  void login(int id, String name) {
    setState(() {
      userId = id;
      username = name;
    });
  }

  void logout() {
    setState(() {
      userId = null;
      username = null;
    });
  }

  Future<void> fetchUserProgress() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.35:5000/get-user-progress/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gold = data['gold'];
        hearts = data['hearts'];
        username = data['username'];  // Récupérer le nom d'utilisateur
      });
    }
  }

  void updateProgress(int index, double score) {
    setState(() {
      if (score == 100.0) {
        progressLevels[index] += 0.25;
        attempts[index]++;
        if (progressLevels[index] > 1.0) {
          progressLevels[index] = 1.0;
        }
      } else {
        if (hearts > 0) {
          hearts--;
          lastLostHeartTime = DateTime.now();
        }
      }
    });
  }

  void onButtonPress(int index, bool pressed) {
    setState(() {
      isPressed[index] = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> lessons = [
      {'title': 'Leçon 1', 'difficulty': 'easy'},
      {'title': 'Leçon 2', 'difficulty': 'medium'},
      {'title': 'Leçon 3', 'difficulty': 'hard'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Pirate Quiz'),
        backgroundColor: Colors.blue,
        actions: [
          if (userId == null)
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                if (result != null) {
                  login(result['id'], result['username']);
                }
              },
            )
          else
            GestureDetector(
              onTap: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    MediaQuery.of(context).size.width,
                    AppBar().preferredSize.height,
                    0,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text(username ?? 'Utilisateur'),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Déconnexion'),
                        onTap: logout,
                      ),
                    ),
                  ],
                );
              },
              child: Row(
                children: [
                  Text(
                    username ?? 'Utilisateur',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            int questionCount = (attempts[index] == 1) ? 5 : 7;

            return GestureDetector(
              onTapDown: (_) => onButtonPress(index, true),
              onTapUp: (_) {
                Future.delayed(Duration(milliseconds: 300), () {
                  onButtonPress(index, false);
                  if (hearts > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          userId: userId!,
                          difficulty: lessons[index]['difficulty']!,
                          questionCount: questionCount,
                          lessonId: index + 1,
                        ),
                      ),
                    ).then((score) {
                      if (score != null) {
                        updateProgress(index, score);
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Vous n'avez plus de cœurs !"),
                      ),
                    );
                  }
                });
              },
              child: ListTile(
                title: Text(lessons[index]['title']!),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    heartRegenTimer?.cancel();
    super.dispose();
  }
}
