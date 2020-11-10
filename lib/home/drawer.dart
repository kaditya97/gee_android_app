import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../intro.dart';


class CustomDrawer extends StatelessWidget {

  Future<void> _launch(String url) async {
    if(await canLaunch(url)){
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key':'my_header_value'},
      );
    }
  }
  Future<void> _launchEmail(String url) async {
    if (await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not Launch $url';
    }
  }

  Future _showDialog(BuildContext context) async {
    // flutter defined function
    return await showDialog(
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

  Future _showSetting(BuildContext context) async {
    return await showDialog(
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Center(
                    child: Text(
                  "GEE",
                  style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                )),
              ),
              ListTile(
                leading: Icon(Icons.collections_bookmark,color: Colors.blue,),
                title: Text("Instructions", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => App()));},
              ),
              ListTile(
                leading: Icon(Icons.clear_all,color: Colors.blue),
                title: Text("About", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                 onTap: () async {
                   await _showDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings,color: Colors.blue),
                title: Text("Settings", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                onTap: () async {
                   await _showSetting(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.content_copy,color: Colors.blue),
                title: Text("Github", style:  TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                onTap: () => _launch("https://github.com/kaditya97/gee_android_app"),
                trailing: Icon(Icons.open_in_new,color: Colors.blue),
              ),
              ListTile(
                leading: Icon(Icons.email,
                color: Colors.blue),
                title: Text("Feedback", style:  TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                onTap: () => _launchEmail('mailto:kaditya9711@gmail.com?subject=GoogleEarthEngine%20app%20feedback&body=Suggestion'),
                trailing: Icon(Icons.open_in_new,
                color: Colors.blue),
              ),
            ],
          ),
    );
  }
}
