import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceapp/fragments/acerca_fragment.dart';
import 'package:voiceapp/fragments/comando_fragment.dart';
import 'package:voiceapp/fragments/reportes_fragment.dart';
import 'package:voiceapp/fragments/speech_fragment.dart';
import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    new DrawerItem("Hablar", Icons.mic),
    new DrawerItem("Comandos", Icons.headset_mic),
    new DrawerItem("Reportes", Icons.assignment),
    new DrawerItem("Acerca de ", Icons.public)
  ];

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  String _host = "http://0.0.0.0:8888";

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new ComandoFragment();
      case 1:
        return new SpeechFragment();
      case 2:
        return new ReporteFragment();
      case 3:
        return new AcercaFragment();

      default:
        return new Text("Error");
    }
  }

  void initState() {
    super.initState();
    setHost();
  }


  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
          new ListTile(
            leading: new Icon(d.icon),
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () => _onSelectItem(i),
          )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(_host, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),),
              accountEmail: null,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage("assets/images/home.jpg"),
                    fit: BoxFit.cover,
                  ),
                )),
            new Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  Future<String> setHost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //print(Uri.parse(prefs.get('host')));
    String _aux = prefs.get('host');
    if(_aux.length > 5) {
      _aux = _aux.substring(7, (_aux.length - 5));
      _host = _aux;
    }
  }
}