import 'package:flutter/material.dart';


class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte au trésor')),
      body: Center(
        child: Image.asset('assets/images/full_treasure_map.png'),
      ),
    );
  }
}
