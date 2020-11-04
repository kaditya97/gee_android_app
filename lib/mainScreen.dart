import 'package:flutter/material.dart';
import 'package:gee/home/home.dart';
import 'package:gee/home/drawer.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      drawer: CustomDrawer(),
      body: Home(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}