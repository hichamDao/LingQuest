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
  String? username;
  
  @override
void initState() {
  super.initState();
  startHeartRegenTimer();
  
  // Vérifie si l'utilisateur est connecté et récupère sa progression
  if (userId != null) {
    fetchUserProgress();
  }
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

  void login(int id) async {
    setState(() {
      userId = id;
    });

    // Simule la récupération du nom de l'utilisateur après connexion
    final response = await http.get(
      Uri.parse('http://192.168.1.35:5000/get-user-info/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        username = data['username'];  // Met à jour le nom d'utilisateur
      });
    }
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
    backgroundColor: Colors.blue, // Couleur de l'AppBar
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
              login(result);
            }
          },
        )
      else
        Row(
          children: [
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
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow),
                  Text(' $gold'),
                ],
              ),
            ),
            PopupMenuButton<String>(
                icon: Icon(Icons.favorite, color: Colors.red),
                onSelected: (value) async {
                  if (value == 'recharge') {
                    rechargeHearts();
                  } else if (value == 'logout' && userId != null) {
                    logout();
                  } else if (value == 'logout' && userId == null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    if (result != null) {
                      login(result);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'hearts',
                    child: Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < hearts ? Icons.favorite : Icons.favorite_border,
                          color: index < hearts ? Colors.red : Colors.grey,
                        );
                      }),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'recharge',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recharger (300 or)'),
                        Icon(Icons.add_circle, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text(userId != null ? 'Déconnexion' : 'Connexion'),
                      ],
                    ),
                  ),
                  
            ],
            ),
          ],
        ),
    ],
  ),
  
   body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTapDown: (_) => onButtonPress(index, true),
              onTapUp: (_) {
                Future.delayed(Duration(milliseconds: 300), () {
                  onButtonPress(index, false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        difficulty: lessons[index]['difficulty']!,
                        questionCount: 5,
                        userId: userId!,
                        lessonId: index + 1,
                      ),
                    ),
                  ).then((score) {
                    if (score != null) {
                      updateProgress(index, score);
                    }
                  });
                });
              },
              onTapCancel: () => onButtonPress(index, false),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cercle de progression
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progressLevels[index],
                          strokeWidth: 8,
                          color: Colors.blue,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      // Bouton circulaire
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: isPressed[index] ? 70 : 75,
                        height: isPressed[index] ? 70 : 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          boxShadow: isPressed[index]
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    spreadRadius: 3,
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    lessons[index]['title']!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
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
