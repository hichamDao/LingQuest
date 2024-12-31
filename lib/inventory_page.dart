import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  final String userId;

  InventoryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> inventory = [
      {'item': 'Gold Coin', 'quantity': 3},
      {'item': 'Pirate Hat', 'quantity': 1},
      {'item': 'Sword', 'quantity': 2},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventaire de $userId'),
      ),
      body: ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text(inventory[index]['item']),
            trailing: Text('x${inventory[index]['quantity']}'),
          );
        },
      ),
    );
  }
}
