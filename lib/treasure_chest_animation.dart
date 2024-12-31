import 'package:flutter/material.dart';

class TreasureChestAnimation extends StatefulWidget {
  final Function onAnimationComplete;
  TreasureChestAnimation({required this.onAnimationComplete});

  @override
  _TreasureChestAnimationState createState() =>
      _TreasureChestAnimationState();
}

class _TreasureChestAnimationState extends State<TreasureChestAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value * 1.5, // Animation d'ouverture du coffre
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/chest.png', width: 150),
              SizedBox(height: 20),
              Text(
                'Félicitations ! Vous avez trouvé un trésor !',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onAnimationComplete();
                },
                child: Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
