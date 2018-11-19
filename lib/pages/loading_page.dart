
import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:get_ip/get_ip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:voiceapp/pages/home_page.dart';
import 'package:voiceapp/loader/loader1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';

class LoadingPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return new LoadingPageState();
  }
}

class LoadingPageState extends State<LoadingPage> {
  Timer timer;
  String _host;
  bool retry = false;
  double _opacity = 0.0;

  final myController = new TextEditingController();
  static AudioCache player = new AudioCache();
  @override
  void initState() {
    super.initState();
    //player.play('eyecatch.mp3');
    myController.addListener(_onChangeIP);
    readLan().then((res){
      print("res1:"+res.toString());
      retry = (res==null)?true:false;
      if(res==null){
        print("==================== OPACITY : 1 =====================\n");
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkDevices(context));
  }

  @override
  void dispose() {
    timer?.cancel();
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Builder(
        builder: (BuildContext context){
          return checkDevices(context);
        },
      ),
    );
  }


  Future<bool> checkIp(i) async{
    try{
      bool res = false;
      String ipAdress = await GetIp.ipAddress;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');
      print('Running on ${ipAdress}');

      List<String> aip = ipAdress.split(".");
      String __host = aip[0]+"."+aip[1]+"."+aip[2]+".";

      await http.get("http://"+__host + i.toString() + ":8888")
          .timeout(const Duration(milliseconds: 300))
          .then((response) {
            print("=======CODE $i=====: ${response.statusCode}");
        if (response.statusCode == 200) {
          saveHost("http://"+__host + i.toString() + ":8888");
          //print(__host + i.toString() + ":8888");
          _host = __host + i.toString() + ":8888";
          return !res;
        }else{
          print("error " + __host + i.toString() + ":8888");
        }
      }).catchError((e) {
        print("host "+__host + i.toString() + ":8888");
        return res;
      });

    } catch(_){
      print("inside catchError");

    }
  }

  Future<bool> readLan () async {
    retry = false;
    bool ress;
    for( var i = 2 ; i < 255; i++ ) {
      ress = await checkIp(i);
      //if(ress!=null){ return ress; }
      print("$i :  $_host");
      if(_host!=null) {break;}
    }

    if(_host!= null) {
      Navigator
          .of(context)
          .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }
    return ress;

  }

  checkDevices(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new Center(
        child: new Column(
          children: <Widget>[
            Divider(
              height: 200.0,
              color: Colors.white,
            ),
            ColorLoader3(
              radius: 20.0,
              dotRadius: 5.0,
            ),
            new Text("Buscando dispositvos..."),
            new Row (

              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    child: Opacity(opacity: _opacity,
                      child: new RaisedButton(
                        child: const Text('Conectar Manualmente'),
                        color: Theme.of(context).accentColor,
                        elevation: 4.0,
                        splashColor: Colors.white,

                        onPressed: () {
                          showDialog(context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: new Text("Agregar ip manual mente"),
                                  content: new TextField(
                                    //onChanged: _onChangeIP,
                                      autofocus: true,
                                      controller: myController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true)
                                  ),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: new Text('Agregar'),
                                        onPressed: () {

                                          String mip = myController.text;
                                          saveHost("http://"+ mip + ":8888");
                                          Navigator
                                              .of(context)
                                              .pushReplacement(new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomePage()));
                                        }
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    )
                )
              ],
            ),
            new Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(child: Opacity(opacity: _opacity,
                  child: new RaisedButton(
                    child: const Text('Reintentar Conexiòn'),
                    color: Theme.of(context).accentColor,
                    elevation: 4.0,
                    splashColor: Colors.white,
                    onPressed: () {
                      if(retry){
                        setState(() {
                          _opacity = .0;
                        });
                        readLan().then((res){
                          print("res1:"+res.toString());
                          retry = (res==null)?true:false;
                          if(res==null){
                            print("==================== OPACITY : 1 =====================\n");
                            setState(() {
                              _opacity = 1.0;
                            });
                          }
                        });
                      }
                    },
                  ),
                )
                )
              ],

            ),



          ],
        ),
      ),
    );

    //});
  }

  void saveHost(String uri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('host', uri);
  }


  void _onChangeIP() {
    print("New ip: ${myController.text}");
  }
}