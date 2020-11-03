import 'package:flutter/material.dart';
import 'package:gee/test/test.dart';

import './home/home.dart';
import 'drawer/drawer.dart';
import './home/drawer.dart';

void main() => runApp(
      MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    Home(),
    HomePage(),
    Test()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      drawer: CustomDrawer(),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'NDVI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.outlined_flag),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Land',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}