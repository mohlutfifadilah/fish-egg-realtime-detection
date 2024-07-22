import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'InputPage.dart';
import 'RealTimePage.dart';

void main() {
  runApp(MaterialApp(
    title: 'Deteksi Telur Ikan',
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _controller,
        children: [
          HomePage(),
          InputPage(),
          RealTimePage(),
        ],
      ),
      bottomNavigationBar: TabBar(
        tabs: <Widget>[
          Tab(icon: Icon(Icons.home)),
          Tab(icon: Icon(Icons.image_sharp)),
          Tab(icon: Icon(Icons.slow_motion_video_sharp)),
        ],
        controller: _controller,
        labelColor: Colors.amber,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.amber,
      ),
    );
  }
}
