import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';
import 'package:tracking/SignUp.dart';

import 'OptionScreen.dart';

void main()
{
  runApp(MaterialApp(home: Login(),));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String email = '' , password = '';

  final auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                ),
                onChanged: (value)
                {
                  email = value;
                },

              ),
            ),

            SizedBox(height: 20,),

            Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                onChanged: (value)
                {
                  password = value;
                },
              ),
            ),


            SizedBox(height: 20,),

            Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: RaisedButton(
                  child: Text('login'),
                  color: Colors.green,
                  onPressed: (){

                    if(email == '' || password == '')
                    {
                      Toast.show('check data!', context , gravity: Toast.CENTER);
                    }

                    else
                    {
                      final user = auth.signInWithEmailAndPassword(email: email, password: password);

                      if(user != null)
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context){

                          return OptionScreen();

                        }));
                      }
                    }

                  },
                )
            ),

            SizedBox(height: 20,),

            Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: RaisedButton(
                  child: Text('sign up'),
                  color: Colors.green,
                  onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context){

                      return SignUp();

                    }));

                  },
                )
            ),

          ],
        ),
      ),
    );
  }
}
