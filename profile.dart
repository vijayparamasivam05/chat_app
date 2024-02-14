import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GoogleButton.dart';
import 'login_page.dart';

void signOutGoogle() async {
  await googleSignIn.signOut();
  await mAuth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);
  print("User signed out of Google account");
}

class MyProfilePage extends StatefulWidget {
    final String userId;
    MyProfilePage({Key key, @required this.userId}) : super(key: key);
    @override
    _MyProfilePageState createState() => new _MyProfilePageState(userId);
    }
class _MyProfilePageState extends State<MyProfilePage>{
    final String userId;
    _MyProfilePageState(this.userId);

@override
  Widget build(BuildContext context) {

      return  ListView(
              children:<Widget> [
              Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                          fontFamily:'OpenSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),//1st Container
              Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      CircleAvatar(
                       backgroundColor: Colors.transparent,
                       backgroundImage: NetworkImage("https://images.app.goo.gl/WG451hnC8tnd3tQj7"),
                       radius: 60,
                     ),
                        SizedBox(height: 20,),
                        Text( userId,
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        SizedBox(height: 20,),
                      ],
                    ),
                ),
              Container(
                    child: RaisedButton(
                        child: Text("Sign out"),
                        onPressed: (){
                          signOutGoogle();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginPage();
                              },
                            ),
                          );
                        }
                    ))
              ],
    );//List view
}}