import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'main.dart';

void main()
{
  runApp(MaterialApp(home: SignUp(),));
}


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  String email = '' , password = '' , confirmPassword = '';

  final auth = FirebaseAuth.instance;
  final fireStore = Firestore.instance;

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
              width: MediaQuery.of(context).size.width*0.8,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Confirm password'
                ),

                onChanged: (value)
                {
                  confirmPassword = value;
                },
              ),
            ),

            SizedBox(height: 20,),

            Container(
              width: MediaQuery.of(context).size.width*0.6,
              child: RaisedButton(
                child: Text('sign up'),
                color: Colors.green,
                onPressed: () async {

                  if(email == '' || password == '' || confirmPassword == '')
                    {
                      Toast.show('check data!', context , gravity: Toast.CENTER);
                    }

                  else
                    {
                      if(password == confirmPassword)
                        {
                          if(password.length>6)
                            {
                              final user  = auth.createUserWithEmailAndPassword(email: email, password: password);

                              if(user != null)
                              {
                                Toast.show('signed up, please wait!', context , gravity: Toast.CENTER);

                                await fireStore.collection('users').document(email).setData({

                                  'email':email,
                                  'password':password,

                                });

                                Navigator.push(context, MaterialPageRoute(builder: (context){

                                  return Login();

                                }));

                              }
                            }
                          else
                            {
                              Toast.show('password is short', context , gravity: Toast.CENTER);
                            }
                        }
                      else
                        {
                          Toast.show('retype password!', context , gravity: Toast.CENTER);
                        }
                    }

                },
              )
            ),


          ],
        ),
      ),
    );
  }
}
