import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Halaman Input'),
      backgroundColor: Colors.amber,
      ),
      body: Center(
      child: Text(
        'Halaman Home',
        style: TextStyle(fontSize: 24),
      ),
    )
    );
  }
}
