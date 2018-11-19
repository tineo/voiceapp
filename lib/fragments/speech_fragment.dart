import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpeechFragment extends StatelessWidget {
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
          /*Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
          ),*/

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
          //print("fake");
          //print(snapshots.hasData);
          //print(snapshots.data.documents.length);
          //print(snapshots.data.documents[0]);
          //print(snapshots.data.documents[0].documentID);
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

}