import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracking/CheckTrip.dart';
import 'package:tracking/Static.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(home: ViewTrips()));
}

class ViewTrips extends StatefulWidget {
  @override
  _ViewTripsState createState() => _ViewTripsState();
}

class _ViewTripsState extends State<ViewTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RetrieveTrips(),
    );
  }
}

class RetrieveTrips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('trips').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {

                    DateTime time = document['tripNo'].toDate();
                    String formattedDate = DateFormat('yyyy-MM-dd – hh:mm:ss').format(time);

                return new Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: FlatButton(
                    child: Text('trip no.   $formattedDate'),
                    onPressed: () {

                      Static.tripID = document['tripID'].toString();

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CheckTrip();
                      }));
                    },
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
