import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';
import 'package:tracking/OptionScreen.dart';
import 'requests/google_maps_services.dart';

void main()
{
  runApp(MaterialApp(home: OrderMap(),));
}

class OrderMap extends StatefulWidget {
  @override
  _OrderMapState createState() => _OrderMapState();
}

class _OrderMapState extends State<OrderMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Map(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  GoogleMapController MapController;

  GoogleMapsServices googleMapsServices = GoogleMapsServices();

  static LatLng initialPositin;

  LatLng lastPosition = initialPositin;
  LatLng customerPosition;

  final Set<Marker> marker = {};
  final Set<Marker> customerMarker = {};

  final Set<Polyline> polyLine = {};

  List locationUpdateList = [];
  var singleLocationUpdateList = {};

  bool endTrip = false , delivered = false;

  String iconMarker = 'icons/orangedot.png';

  int customerMarkIndex = null;

  DateTime tripNo = DateTime.now();


  LatLng customerMark = null;

  bool started = false;
  String btnText = 'START TRIP';

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context)
  {

    return initialPositin == null? Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ) : Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (LatLngTapped)
          {
            setState(() {

              if(customerMark == null)
                {
                  addMarkerCustomer(LatLng(LatLngTapped.latitude , LatLngTapped.longitude));

                  customerMark = LatLng(LatLngTapped.latitude , LatLngTapped.longitude);
                }

              else
                {
                  marker.remove(
                    Marker(markerId: MarkerId(customerMark.toString()),
                      position: customerMark,
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  );

                  addMarkerCustomer(LatLng(LatLngTapped.latitude , LatLngTapped.longitude));
                  customerMark = LatLng(LatLngTapped.latitude , LatLngTapped.longitude);

                }




            });
          },
          initialCameraPosition: CameraPosition(target: initialPositin, zoom: 10),
          onMapCreated: onCreated,
          myLocationEnabled: true,
          mapType: MapType.normal,
          markers: marker,
          compassEnabled: true,
          onCameraMove: onCameraMove,
          polylines: polyLine,
        ),

      Align(
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: RaisedButton(
                color: Colors.white30,
                child: Text('$btnText'),
                onPressed: () {

                  if(started == true)
                    {
                      setState(() async {

                        endTrip = true;
                        Toast.show('trip ended', context);

                        await Firestore.instance.collection('trips').document(tripNo.toString()).updateData({

                          'endTime' : DateTime.now(),

                        });

                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return OptionScreen();
                        }));

                      });
                    }
                  else
                    {
                      if(customerMark == null)
                      {
                        Toast.show('select customer location', context);
                      }
                      else
                      {
                        startTrip();

                        setState(() {
                          started = true;
                          btnText = 'END TRIP';
                        });
                      }
                    }
                },
              ),
            ),

            SizedBox(width: 50,),

            Container(
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: Visibility(
                visible: started,
                child: RaisedButton(
                  color: Colors.white30,
                  child: Text('DELIVERED'),
                  onPressed: () async{
                    Toast.show('order delivered', context);
                    iconMarker = 'icons/greendot.png';

                    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                    Firestore.instance.collection('trips').document(tripNo.toString()).updateData({

                      'deliveredTime' : DateTime.now(),
                      'deliveredLat':'${position.latitude.toString()}',
                      'deliveredLng':'${position.longitude.toString()}',

                    });

                  },
                ),
              ),
            ),
          ],
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

  void addMarkerCustomer(LatLng location) {

    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
    ),
    );

  }

  void startMarker(LatLng location) {
    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
    ),
    );
  }


  void line(LatLng location) {

    marker.add(Marker(markerId: MarkerId(location.toString()),
      position: location,
      icon: BitmapDescriptor.fromAsset('$iconMarker'),
    ),
    );
  }
  void lineDelivered(LatLng location2) {

    marker.add(Marker(markerId: MarkerId(location2.toString()),
      position: location2,
      icon: BitmapDescriptor.fromAsset('$iconMarker'),
    ),
    );
  }
  void createRoute(String encodedpoly)
  {
    setState(() {
      polyLine.add(Polyline(polylineId: PolylineId(lastPosition.toString()),
        width: 20,
        points: convertToLatLng(_decodePoly(encodedpoly)),
        color: Colors.red,),);
    });
  }


  List<LatLng> convertToLatLng (List points)
  {

    List<LatLng> result = <LatLng>[];

    for(int i = 0 ; i<points.length ; i++)
    {
      if(i % 2 != 0)
      {
        result.add(LatLng(points[i-1] , points[i]));
      }
    }

    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void getCurrentLocation() async{

    Toast.show('select location and start trip', context);

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    setState(() {

      initialPositin = LatLng(position.latitude , position.longitude);

      startMarker(LatLng(position.latitude , position.longitude));

    });


  }

  void startTrip() async
  {
    Toast.show('trip started , go to located mark', context);

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Firestore.instance.collection('trips').document(tripNo.toString()).setData({

      'customerLat':'${customerMark.latitude}',
      'customerLng':'${customerMark.longitude}',
      'startLat':'${position.latitude.toString()}',
      'startLng':'${position.longitude.toString()}',
      'deliveredLat':'',
      'deliveredLng':'',

      'endTime':DateTime.now(),
      'deliveredTime':DateTime.now(),

      'tripNo':tripNo,
      'tripID':tripNo.toString(),

      'points':[],

    });

    await Firestore.instance.collection('trips').document(tripNo.toString()).get().then((DocumentSnapshot ds){

      addMarkerCustomer(LatLng(double.parse('${ds['customerLat']}') , double.parse('${ds['customerLng']}')));

    });

    startTimer();
  }


  void sendRequestCustomer(LatLng deleviryLatLng) async{

    double latitude = deleviryLatLng.latitude;
    double longitude = deleviryLatLng.longitude;

    List<Placemark> whereToList = await Geolocator().placemarkFromCoordinates(latitude, longitude);


    LatLng distenation = LatLng(latitude , longitude);

    addMarkerCustomer(distenation);

    String route = await googleMapsServices.getRouteCoordinates(initialPositin, distenation);

    createRoute(route);
  }

  void startTimer()
  {

    Timer.periodic(Duration(seconds: 15), (timer) async{

      if(endTrip == false)
        {
          running();
        }
      else if(endTrip == true){
        timer.cancel();
      }

    });
  }


  void running() async {

    var points = {};
    List list = [];

    locationUpdateList.clear();
    singleLocationUpdateList = {};

    list = [];
    points = {};

    try
    {
      await Firestore.instance.collection('trips').document(tripNo.toString()).get().then((DocumentSnapshot ds){

        locationUpdateList = ds['points'];

      });
    }
    catch(e)
    {

    }


    Position position =  await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    singleLocationUpdateList['time'] = DateTime.now();
    singleLocationUpdateList['deliveryLat'] = position.latitude.toString();
    singleLocationUpdateList['deliveryLng'] = position.longitude.toString();

    locationUpdateList.add(singleLocationUpdateList);

    setState(() {
      line(LatLng(position.latitude , position.longitude));
    });

    await Firestore.instance.collection('trips').document(tripNo.toString()).updateData({
      'points':locationUpdateList,
    });

  }

}

