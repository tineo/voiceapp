import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReporteFragment extends StatefulWidget {

    var datos = '''[
      {
        "icon":"looks_one",
        "nombre":"Puerta",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 1",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 2",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 3",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 4",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 5",
        "estado" : "Apagado"
      },
      {
        "icon":"highlight",
        "nombre":"Foco 6",
        "estado" : "Apagado"
      }
      ]''';




    @override
    _MyAppState createState(){
      return new _MyAppState();
    }
}

class _MyAppState extends State<ReporteFragment> {

  var loading = false;
  List<Widget> listArray = [];

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  @override
  Widget build(BuildContext context) {
    int _act = 1;


    final title = 'Basic List';
    return MaterialApp(
      title: title,
      home: Scaffold(
        body: ListView(
          /*children: <Widget>[
            ListTile(
              leading: Icon(Icons.looks_one),
              title: Text('Puerta'),
            ),
            ListTile(
              leading: Icon(Icons.highlight),
              title: Text('Foco'),
            ),
            ListTile(
              leading: Icon(Icons.highlight),
              title: Text('Foco'),
              subtitle: _act != 2 ? const Text('Apagado') : null,
            ),
          ],*/
            children: loading?[]:listArray
        ),
      ),
    );
  }

  void getStatus()  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _host = await prefs.get("host");
    var uri =  _host + "/reporte";
    print(uri);
    await http.get(uri)
        .timeout(const Duration(milliseconds: 300))
        .then((response) {
          print(response.statusCode);
      if (response.statusCode == 200) {
          print(response.body);
      }else{
        print(response.body);
      }
    }).catchError((e) {
      print(e);
    });
  }


}