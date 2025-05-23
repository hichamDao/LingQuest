import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'map_page.dart';
import 'quiz_page.dart';
import 'treasure_map_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<double> progressLevels = List.filled(12, 0.0);  // 12 leçons
  List<int> attempts = List.filled(12, 1);
  List<bool> isPressed = List.filled(12, false);
  int hearts = 5;
  int gold = 0;
  int userProgress = 0;
  int progress = 0; 
  Timer? heartRegenTimer;
  DateTime? lastLostHeartTime;
  Duration regenDuration = Duration(hours: 3);
  int? userId;
  String? username;
  bool isTreasureOpening = false;
  

  List<int> treasureMilestones = [3, 7, 12];  // Niveaux de coffres
  int treasureCount = 0;
  bool showTreasureMap = false;


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
      Uri.parse('https://192.168.1.35:5000/recharge-hearts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {
        gold -= 300;
        hearts = 5;
        lastLostHeartTime = null;
      });
      // **Enregistrer la nouvelle valeur de l'or après déduction**
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gold', gold);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

    // **Ouvrir le coffre et ajouter de l'or**
  Future<void> openTreasure() async {
    if (isTreasureOpening) return;

    setState(() {
      isTreasureOpening = true; // Démarre l'animation
    });

    // Récompense aléatoire entre 50 et 150 pièces d'or
    int reward = Random().nextInt(100) + 50;

    final response = await http.post(
      Uri.parse('https://192.168.1.35:5000/add-gold'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'gold': reward,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {
        gold += reward;
      });
      // **Enregistrement de l'or dans SharedPreferences**
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gold', gold);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez gagné $reward pièces d\'or !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ouverture du coffre.')),
      );
    }

    // Fin de l'animation après 1,5 secondes
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isTreasureOpening = false;
      });
    });
  }


  Future<void> loadGold() async {
  final prefs = await SharedPreferences.getInstance();
  int? savedGold = prefs.getInt('gold');

  if (savedGold != null) {
    setState(() {
      gold = savedGold;
    });
  }
}


  Future<void> fetchUserProgress() async {
  try {
    final response = await http.get(
      Uri.parse('https://192.168.1.35:5000/get-user-progress/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
          gold = data['gold'];
        hearts = data['hearts'];
        userProgress = data['progress'] ?? '0%';
      });
    } else {
      print('Failed to fetch user progress: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user progress: $e');
  }
}

 /* void rechargeHearts() {
    if (gold >= 300 && hearts < 5) {
      setState(() {
        gold -= 300;
        hearts = 5;
        lastLostHeartTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cœurs rechargés !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pas assez d'or ou cœurs pleins.")),
      );
    }
  }
  */

  Future<void> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt('userId');

  if (savedUserId != null) {
    setState(() {
      userId = savedUserId;
    });

    try {
      // Récupération des informations de l'utilisateur connecté
      final response = await http.get(
        Uri.parse('https://192.168.1.35:5000/get-user-info/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          username = data['username'] ?? 'Utilisateur';
        });

        // Récupérer les progrès de l'utilisateur
        await fetchUserProgress();
      } else {
        print('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }
}

void login(int id) async {
  // Sauvegarde l'identifiant utilisateur et met à jour l'état
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', id);

  setState(() {
    userId = id;
  });

  // Récupère les informations de l'utilisateur connecté
  await checkLoginStatus();
}


  void logout() async {
    setState(() {
      userId = null;
      username = null;
    });
    // Suppression de l'ID utilisateur de SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('gold');  // Supprimer l'or de la session
  }


  List<Map<String, String>> lessons = [
    {'title': 'Leçon 1', 'difficulty': 'easy'},
    {'title': 'Leçon 2', 'difficulty': 'easy'},
    {'title': 'Leçon 3', 'difficulty': 'medium'},
    {'title': 'Leçon 4', 'difficulty': 'medium'},
    {'title': 'Leçon 5', 'difficulty': 'hard'},
    {'title': 'Leçon 6', 'difficulty': 'hard'},
    {'title': 'Leçon 7', 'difficulty': 'easy'},
    {'title': 'Leçon 8', 'difficulty': 'medium'},
    {'title': 'Leçon 9', 'difficulty': 'hard'},
    {'title': 'Leçon 10', 'difficulty': 'easy'},
    {'title': 'Leçon 11', 'difficulty': 'medium'},
    {'title': 'Leçon 12', 'difficulty': 'hard'},
  ];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadProgress();
    loadGold();
    startHeartRegenTimer();
  }

  // Mise à jour de la progression et gestion des coffres
  void updateProgress(int index, double score) async {
    if (score == 100.0) {
      setState(() {
        progressLevels[index] += 0.25;
        attempts[index]++;
        if (progressLevels[index] > 1.0) {
          progressLevels[index] = 1.0;
        }
        progress++;

        // Débloquer les coffres après les milestones
        if (progress == treasureMilestones[treasureCount]) {
          treasureCount++;
          openTreasure();
        }

        // Afficher la carte après 12 leçons complétées
        if (progress >= 12) {
          showTreasureMap = true;
        }
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('progressLevels', jsonEncode(progressLevels));
      await prefs.setInt('treasureCount', treasureCount);
      await prefs.setBool('showTreasureMap', showTreasureMap);
    } else {
      if (hearts > 0) {
        setState(() {
          hearts--;
          lastLostHeartTime = DateTime.now();
        });
      }
    }
  }
  void loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  String? savedProgress = prefs.getString('progressLevels');
  int? savedTreasureCount = prefs.getInt('treasureCount');
  bool? savedTreasureMap = prefs.getBool('showTreasureMap');

  if (savedProgress != null) {
    List<dynamic> savedProgressList = jsonDecode(savedProgress);
    setState(() {
      progressLevels = savedProgressList.cast<double>();
      treasureCount = savedTreasureCount ?? 0;
      showTreasureMap = savedTreasureMap ?? false;
    });
  }
}


  void onButtonPress(int index, bool pressed) {
    setState(() {
      isPressed[index] = pressed;
    });
  }


  // Afficher le coffre après les milestones (3, 7, 12)
  Widget buildTreasureSection() {
    return Column(
      children: [
        if (treasureCount > 0)
          ...List.generate(treasureCount, (index) {
            return GestureDetector(
              onTap: openTreasure,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                width: isTreasureOpening ? 160 : 140,
                height: isTreasureOpening ? 160 : 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/treasure_closed.png'),
                  ),
                ),
              ),
            );
          }),
        SizedBox(height: 20),
        if (showTreasureMap)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/treasure_map.png'),
                ),
              ),
            ),
          ),
      ],
    );
  }


// Afficher la popup avant de commencer le quiz
void showStartLessonPopup(BuildContext context, int lessonId, int questionCount) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Prêt pour l\'aventure ?'),
        content: Text('Gagne 10 XP pour chaque exercice. Terminer la leçon te donnera 20 XP !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la popup
              navigateToQuiz(context, lessonId, questionCount); // Lancer le quiz après la popup
            },
            child: Text('Commencer'),
          ),
        ],
      );
    },
  );
}
// Naviguer vers la page du quiz après avoir fermé la popup
void navigateToQuiz(BuildContext context, int lessonId, int questionCount) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizPage(
        userId: userId!,
        difficulty: lessons[lessonId - 1]['difficulty']!,
        questionCount: questionCount,
        lessonId: lessonId,
      ),
    ),
  ).then((score) {
    if (score != null) {
      updateProgress(lessonId - 1, score); // Mettre à jour la progression de la leçon
    }
  });
}
// Liste des images et des titres pour le thème Pirate
final List<Map<String, String>> pirateThemes = [
  {'image': 'assets/pirate1.png', 'title': 'Capitaine Barbe Noire'},
  {'image': 'assets/pirate2.png', 'title': 'Reine des Pirates'},
  {'image': 'assets/pirate3.png', 'title': 'Trésor Caché'},
  {'image': 'assets/pirate4.png', 'title': 'Chasseur de Perles'},
];
  @override
  Widget build(BuildContext context) {
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
        leading: Icon(Icons.show_chart),
        title: Text('Progrès : ${userProgress ?? 'Non disponible'}'),
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

            ],
            ),
          ],
        ),
    ],
  ),
      body: Column(
  children: [
    Expanded(
      child: SingleChildScrollView(
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(), // Désactiver le défilement interne de la grille
          shrinkWrap: true, // Adapter la taille de la grille au contenu
          padding: EdgeInsets.all(20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Une seule colonne (un bouton par ligne)
            mainAxisSpacing: 20.0, // Espace vertical entre les boutons
            childAspectRatio: 3, // Largeur pour inclure image + bouton
          ),
          itemCount: lessons.length, // Nombre total de boutons (leçons)
          itemBuilder: (context, index) {
            // Déterminer l'image à afficher (si applicable)
            String? imagePath;
            if (index == 0) {
              imagePath = 'assets/images/treasure_closed.png'; // Image pour leçon 1
            } else if (index == 3) {
              imagePath = 'assets/images/treasure_closed.png'; // Image pour leçon 4
            } else if (index == 7) {
              imagePath = 'assets/images/treasure_closed.png'; // Image pour leçon 8
            } else if (index == 11) {
              imagePath = 'assets/images/treasure_closed.png'; // Image pour leçon 12
            }

            // Déterminer l'alignement du bouton
            bool alignLeft = index % 2 == 0;
            double horizontalPadding = alignLeft ? 30.0 : 200.0;

            return Row(
              mainAxisAlignment:
                  alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (imagePath != null && alignLeft) ...[
                  // Si l'image est alignée à gauche
                  Image.asset(
                    imagePath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 20), // Espacement entre l'image et le bouton
                ],
                GestureDetector(
                  onTapDown: (_) => onButtonPress(index, true),
                  onTapUp: (_) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      onButtonPress(index, false);
                      if (userId != null && hearts > 0) {
                        showStartLessonPopup(context, index + 1, (attempts[index] == 1) ? 5 : 7); // Popup avant quiz
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Veuillez vous connecter ou attendre la régénération.",
                            ),
                          ),
                        );
                      }
                    });
                  },
                  onTapCancel: () => onButtonPress(index, false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cercle de progression
                          SizedBox(
                            width: 80,
                            height: 80,
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
                            width: isPressed[index] ? 65 : 70,
                            height: isPressed[index] ? 65 : 70,
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        lessons[index]['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (imagePath != null && !alignLeft) ...[
                  // Si l'image est alignée à droite
                  SizedBox(width: 20), // Espacement entre le bouton et l'image
                  Image.asset(
                    imagePath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    ),
  ],
)
);
}
}
