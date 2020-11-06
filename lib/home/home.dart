import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';

import 'layer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _title = 'Open Street Map';
  String dropdownValue = 'lulc';
  File filedata;
  String _basename;
  final double _initFabHeight = 120.0;
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = 95.0;
  PanelController _pc = new PanelController();

  @override
  void initState() {
    osmLayer();
    super.initState();

    _fabHeight = _initFabHeight;
  }

  final osm = new TileLayerOptions(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c']);

  List<Layer> listModel = [];
  List<LayerOptions> listLayer = [];
  List<SpeedDialChild> popupmenu = [];

  void osmLayer() {
    listLayer.add(osm);
  }

  Future handleRequest(String name, File file) async {
    _pc.close();
    setState(() {
      _loading = true;
    });

    if (file != null) {
      var uri = Uri.parse('https://gee-flask.herokuapp.com/');
      var request = http.MultipartRequest('POST', uri)
        ..fields['indicator'] = name
        ..files.add(await http.MultipartFile.fromPath('roi', file.path));
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      mapLayer(responseData, name);
    } else {
      final responseData = await http.post(
          "https://gee-flask.herokuapp.com/world",
          body: {"indicat": name});
      mapLayer(responseData, name);
    }
  }

  void mapLayer(var responseData, var name) {
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        _title = name;
        listLayer = [];
        listModel = [];
        popupmenu = [];
        for (Map i in data["records"]) {
          listModel.add(Layer.fromJson(i));
        }
        _loading = false;
      });
      for (int i = 1; i < listModel.length; i++) {
        listLayer.add(
          new TileLayerOptions(
              urlTemplate: listModel[i].url,
              backgroundColor: Colors.transparent),
        );
        popupmenu.add(
          SpeedDialChild(
            child: Icon(Icons.map_sharp, color: Colors.white),
            backgroundColor: Colors.green,
            onTap: () {
              setState(() {
                _title = listModel[i].name;
                listLayer = [];
                listLayer.add(osm);
                listLayer.add(
                  new TileLayerOptions(
                      urlTemplate: listModel[i].url,
                      backgroundColor: Colors.transparent),
                );
              });
            },
            label: listModel[i].name,
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
        );
      }
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      marginBottom: _fabHeight,
      animatedIconTheme: IconThemeData(size: 22.0),
      child: Icon(Icons.layers),
      visible: true,
      curve: Curves.bounceIn,
      children: popupmenu,
    );
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Scaffold(
      floatingActionButton: buildSpeedDial(),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            controller: _pc,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _loading
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : _body(),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          Positioned(
              top: 0,
              child: ClipRRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).padding.top,
                        color: Colors.transparent,
                      )))),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: _form(), // Form for data submition
            ),
          ],
        ));
  }

  Widget _body() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(28.3949, 84.1240),
        zoom: 3,
        maxZoom: 15,
      ),
      layers: listLayer,
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down_outlined),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text("Land Cover"),
                  value: 'lulc',
                ),
                DropdownMenuItem(
                  child: Text("DEM"),
                  value: 'dem',
                ),
                DropdownMenuItem(
                  child: Text("NDVI"),
                  value: 'ndvi',
                ),
                DropdownMenuItem(
                  child: Text("NDBI"),
                  value: 'ndbi',
                ),
                DropdownMenuItem(
                  child: Text("NDWI"),
                  value: 'ndwi',
                ),
                DropdownMenuItem(
                  child: Text("Hillshade"),
                  value: 'hillshade',
                ),
                DropdownMenuItem(
                  child: Text("Slope"),
                  value: 'slope',
                ),
                DropdownMenuItem(
                  child: Text("Aspect"),
                  value: 'aspect',
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        filedata = File(result.files.single.path);
                        setState(() {
                          _basename = filedata.path.split('/').last;
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: Text('Select Geojson File'),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.45,
                    child: Text(_basename != null ? _basename : ''),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                void sendData(String name, File file) async {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                  final data = await handleRequest(name, file);
                  print(data);
                }

                final String name = dropdownValue;
                if (filedata == null && dropdownValue == 'dem' ||
                    filedata == null && dropdownValue == 'lulc') {
                  final File file = null;
                  sendData(name, file);
                } else if (filedata == null) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Please Select a geojsonfile')));
                }
                if (filedata != null) {
                  final File file = filedata;
                  sendData(name, file);
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
