import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Halaman Input'),
      backgroundColor: Colors.amber,
      ),
      body: const Center(
      child: Text(
        'Halaman Home',
        style: TextStyle(fontSize: 24),
      ),
    )
    );
  }
}
