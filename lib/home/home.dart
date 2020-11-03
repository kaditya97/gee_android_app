import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;

import 'Constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  final String url = "http://192.168.1.93/twp/api/event/read.php";
  String cases;
  String deaths;
  int recovered;
  int active;

  @override
  void initState() {
    super.initState();
    // _loading = true;
    this.getJsonData();
  }

  Future<String> getJsonData() async {
    var response = await http.get(
        //Encodeing url
        Uri.encodeFull(url),
        //only accept json response
        headers: {"Accept": "application/json"});
    setState(() {
      var data = json.decode(response.body);
      cases = data['records'][0]['id'];
      deaths = data["deaths"];
      recovered = data["recovered"];
      active = data["active"];
      _loading = false;
    });

    return "success";
  }


  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Developer"),
          content: new Text("Aditya Kushwaha"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSetting(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Setting"),
          content: new Text("Coming Soon...."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.About) {
      _showDialog();
    } else if (choice == Constants.Settings) {
      _showSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Earth Engine'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: (){
            Scaffold.of(context).openDrawer();
          }
          ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : new FlutterMap(
                options: new MapOptions(
                  center: LatLng(27.3949, 84.1240),
                  zoom: 6.0,
                ),
                layers: [
                  new TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']
                  ),
                  new TileLayerOptions(
                    urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                    subdomains: ['a','b','c']
                  ),
                ],
              ),
    );
  }
}
