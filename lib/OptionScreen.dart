import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracking/CustomerOrder.dart';
import 'package:tracking/OrderMap.dart';
import 'package:tracking/ViewTrips.dart';
import 'package:tracking/main.dart';

void main()
{
  runApp(MaterialApp(home: OptionScreen(),));
}

class OptionScreen extends StatefulWidget {
  @override
  _OptionScreenState createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            RaisedButton(
//              child: Text('create order' , style: TextStyle(fontSize: 40),),
//              color: Colors.grey,
//              onPressed: ()
//              {
//                Navigator.push(context, MaterialPageRoute(builder: (context){
//                  return CustomerOrder();
//                }));
//              },
//            ),
//            SizedBox(height: 40,),

            RaisedButton(
              child: Text('start trip' , style: TextStyle(fontSize: 40),),
              color: Colors.green,
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return OrderMap();
                }));
              },
            ),

            SizedBox(height: 40,),

            RaisedButton(
              child: Text('view trips' , style: TextStyle(fontSize: 40),),
              color: Colors.green,
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ViewTrips();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
