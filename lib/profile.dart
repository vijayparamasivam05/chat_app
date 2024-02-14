import 'package:flutter/material.dart';
class MyProfilePage extends StatefulWidget {
    final String text;
    MyProfilePage(this.text);
    @override
    _MyProfilePageState createState() => new _MyProfilePageState(text);
    }
class _MyProfilePageState extends State<MyProfilePage>{
    final String text;
    _MyProfilePageState(this.text);
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
                    )),//1st COntainer
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      CircleAvatar(
                       backgroundColor: Colors.transparent,
                       backgroundImage: NetworkImage("https://www.materialui.co/materialIcons/action/account_circle_black_192x192.png" ),
                       radius: 60,
                     ),
                        SizedBox(height: 20,),
                        Text(text,
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text("${text}@gmail.com",
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    )
                ),
              ],
    );//List view
}}