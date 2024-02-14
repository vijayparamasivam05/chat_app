import 'package:flutter/material.dart';

import 'google_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/agent_logo.png"),
                width: 200,
              ),
              SizedBox(height: 50),
              GoogleButton(),
            ],
          ),
        ),
      ),
    );
  }


}