import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

void main()
{
  runApp(MaterialApp(home: CustomerOrder(),));
}

class CustomerOrder extends StatefulWidget {
  @override
  _CustomerOrderState createState() => _CustomerOrderState();
}

class _CustomerOrderState extends State<CustomerOrder> {

  LatLng latLng;
  String itemName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              color: Colors.grey,
              child: TextField(
                onChanged: (value)
                {
                  itemName = value;
                },
                decoration: InputDecoration(
                  hintText: 'item name ...'
                ),
              ),
            ),

            SizedBox(height: 30,),

            RaisedButton(
              color: Colors.grey,
              child: Container(
                width: 130,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.location_on),
                    Text('get my location'),
                  ],
                ),
              ),
              onPressed: () async{
                Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                latLng = LatLng(position.latitude , position.longitude);

                Toast.show('location located', context , gravity: Toast.CENTER);

              },
            ),

            SizedBox(height: 30,),

            RaisedButton(
              color: Colors.grey,
              child: Text('submit'),
              onPressed: ()
              {
                if(itemName == null || itemName == '')
                  {
                    Toast.show('insert item name', context , gravity: Toast.CENTER);
                  }

                else if(latLng == null)
                  {
                    Toast.show('add your location', context , gravity: Toast.CENTER);
                  }

                else
                  {
                    Firestore.instance.collection('orders').document('orderDoc').setData({

                      'itemName' : itemName,
                      'customerLat' : latLng.latitude.toString(),
                      'customerLng' : latLng.longitude.toString(),
                      'points' : [],

                    });

                    Toast.show('item added successfully', context , gravity: Toast.CENTER);
                  }
              },
            ),

          ],
        ),
      ),
    );
  }
}
