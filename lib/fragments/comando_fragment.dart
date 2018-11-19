import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_recognition/speech_recognition.dart';

import "dart:isolate";
import "dart:async";
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComandoFragment extends StatefulWidget {
  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return ListTile(

      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              document['comando'],
              style: Theme.of(context).textTheme.headline,
            ),
          ),
        ],

      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('comandos').snapshots(),
        builder: (context, snapshots){
          if(!snapshots.hasData) return const Text('Loading ... ');

          return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshots.data.documents.length,
              itemBuilder: (context,index) =>
                  _buildListItem(context, snapshots.data.documents[index])
          );
        },
      ),

    );
  }

    @override
    _MyAppState  createState(){
      return new _MyAppState();
    }

}

class _MyAppState extends State<ComandoFragment> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _isSending = false;

  String transcription = '';

  String _currentLocale = 'es_PE';

  String _host;

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();

    getHost();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    //_speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body:
        new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Center(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  new Expanded(
                      child: new Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey.shade200,
                          child: new Text(transcription))),
                  _buildButton(
                    onPressed: _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : null,
                    label: _isListening
                        ? 'Escuchando...'
                        : 'Escuchar ($_currentLocale)',
                  ),
                  _buildButton(
                    onPressed: _isListening ? () => cancel() : null,
                    label: 'Cancelar',
                  ),
                  _buildButton(
                    onPressed: _isListening ? () => stop() : null,
                    label: 'Detener',
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return ListTile(

      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              document['comando'],
              style: Theme.of(context).textTheme.headline,
            ),
          ),

        ],

      ),

    );
  }

  Widget _buildButton({String label, VoidCallback onPressed}) => new Padding(
      padding: new EdgeInsets.all(12.0),
      child: new RaisedButton(
        color: Colors.amber,
        onPressed: onPressed,
        child: new Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ));

  void start() => _speech
      .listen(locale: "es_ES")
      .then((result) => print('_MyAppState.start => result ${result}'));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() =>
      _speech.stop().then((result) => setState(() => _isListening = result));

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) =>
      setState(() => _currentLocale = "es_PE");

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => transcription = text);

  void onRecognitionComplete() {
    setState(() => _isListening = false);
    if(!_isSending) sendCommand();
  }

  void sendCommand() async {
    _isSending = true;
    print(_host+"/action?comando="+transcription);
    await http.get(_host+"/action?comando="+transcription)
        .then((response) {
      print("===========CODE==========!\n${response.statusCode}");
      if (response.statusCode == 200) {
        print("res:"+response.body);
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Se recibio: "+response.body),
        ));
      }else if(response.statusCode == 404){
        print("404 pe");
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("No se reconoce este comando"),
        ));
      }
      _isSending = false;
    });
  }

  void getHost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('host');
  }
}