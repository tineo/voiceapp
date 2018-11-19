import 'package:voiceapp/pages/loading_page.dart';
import 'package:voiceapp/pages/home_page.dart';
import 'package:voiceapp/pages/loading_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'VoiceAdmin Demo',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new LoadingPage(),
    );
  }
}