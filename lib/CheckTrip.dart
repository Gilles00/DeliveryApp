import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tracking/Static.dart';
import 'package:tracking/requests/google_maps_services.dart';

void main()
{
runApp(MaterialApp(home: CheckTrip(),));
}

class CheckTrip extends StatefulWidget {
  @override
  _CheckTripState createState() => _CheckTripState();
}

class _CheckTripState extends State<CheckTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OldMap(),
    );
  }
}


class OldMap extends StatefulWidget {
  @override
  _OldMapState createState() => _OldMapState();
}

class _OldMapState extends State<OldMap> {

  GoogleMapController MapController;

  GoogleMapsServices googleMapsServices = GoogleMapsServices();

  static LatLng initialPositin;

  LatLng lastPosition = initialPositin;
  LatLng customerPosition;

  final Set<Marker> marker = {};
  final Set<Marker> customerMarker = {};

  final Set<Polyline> polyLine = {};

  List pointsList = [];
  var pointsMap = {};

  bool reportVis = false;

  DateTime startTime , endTime , deliveredTime;
  String startTime2 = '' , endTime2 = '' , deliveredTime2 = '';

  DateTime deliveredTimePoint = DateTime.now();

  @override
  void initState() {
    super.initState();

    getPoints();
  }


  @override
  Widget build(BuildContext context) {

    return initialPositin == null? Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ) : Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPositin, zoom: 10),
          onMapCreated: onCreated,
          myLocationEnabled: true,
          mapType: MapType.normal,
          markers: marker,
          compassEnabled: true,
          onCameraMove: onCameraMove,
          polylines: polyLine,
        ),

        Padding(
          padding: const EdgeInsets.only(top: 30 , left: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text('REPORT'),
                      color: Colors.white30,
                      onPressed: () async{
                        
//                        MapController.showMarkerInfoWindow(MarkerId(LatLng(30.0275928,31.4940404).toString()));
//
//                        MapController.showMarkerInfoWindow(MarkerId(LatLng(30.0557914,30.9430822).toString()));

                        setState(() {
                          reportVis = !reportVis;
                        });
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: reportVis,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 200,
                        height: 120,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 15 , left: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(15) , bottomLeft: Radius.circular(15) , bottomRight: Radius.circular(15)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('start time :' , style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('$startTime2'),
                                  ],
                                ),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('delivered time :' , style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('$deliveredTime2'),
                                  ],
                                ),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('end time :' , style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('$endTime2'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  void onCreated(GoogleMapController controller) {

    setState(() {
      MapController = controller;
    });

  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      lastPosition = position.target;
    });
  }

  void customerLocation(LatLng location) {

    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
          title: 'customer location'
      ),
    ),
    );
  }

  void startLocation(LatLng location) {
    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: 'start location'
      ),
    ),
    );
  }


  void line(LatLng location , String pointTime , String dotIcon) {

    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.fromAsset('icons/$dotIcon'),
      infoWindow: InfoWindow(
        title: '$pointTime',
      ),
    ),
    );
  }

  void getPoints() async{

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      initialPositin = LatLng(position.latitude , position.longitude);
    });

    pointsList = [];

    await Firestore.instance.collection('trips').document(Static.tripID).get().then((DocumentSnapshot ds){

      pointsList = ds['points'];

    });

    await Firestore.instance.collection('trips').document(Static.tripID).get().then((DocumentSnapshot ds){

      startLocation(LatLng(double.parse('${ds['startLat']}') , double.parse('${ds['startLng']}')));
    });

    await Firestore.instance.collection('trips').document(Static.tripID).get().then((DocumentSnapshot ds){

      customerLocation(LatLng(double.parse('${ds['customerLat']}') , double.parse('${ds['customerLng']}')));

    });

    await Firestore.instance.collection('trips').document(Static.tripID).get().then((DocumentSnapshot ds){

      deliveredTimePoint = ds['deliveredTime'].toDate();

    });

    try{
      await Firestore.instance.collection('trips').document(Static.tripID).get().then((DocumentSnapshot ds){

        setState(() {

          startTime = ds['tripNo'].toDate();
          endTime = ds['endTime'].toDate();
          deliveredTime = ds['deliveredTime'].toDate();


          DateTime time;
          String formattedDate;

          time = startTime;
          formattedDate = DateFormat('yyyy-MM-dd – hh:mm:ss').format(time);
          startTime2 = formattedDate;

          time = endTime;
          formattedDate = DateFormat('yyyy-MM-dd – hh:mm:ss').format(time);
          endTime2 = formattedDate;

          time = deliveredTime;
          formattedDate = DateFormat('yyyy-MM-dd – hh:mm:ss').format(time);
          deliveredTime2 = formattedDate;
        });

      });
    }
    catch(e)
    {

    }

    setPoints();

  }


  void setPoints() async {

    String iconDot = 'orangedot.png';

    DateTime pointTime;

    DateTime time;
    String formattedDate;

    for(int i = 0 ; i < pointsList.length ; i++)
      {
       pointsMap = pointsList[i];

       pointTime = pointsMap['time'].toDate();

       time = pointTime;
       formattedDate = DateFormat('hh:mm:ss').format(time);

       setState(() {

         if(pointTime.isAfter(deliveredTimePoint))
           {
             iconDot = 'greendot.png';

             line(LatLng(double.parse('${pointsMap['deliveryLat']}') , double.parse('${pointsMap['deliveryLng']}')) , '$formattedDate' , '$iconDot');
           }
         else
           {
             line(LatLng(double.parse('${pointsMap['deliveryLat']}') , double.parse('${pointsMap['deliveryLng']}')) , '$formattedDate' , '$iconDot');
           }

       });


      }
  }

}

