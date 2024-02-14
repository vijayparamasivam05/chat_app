import 'package:flutter/material.dart';
import 'GoogleButton.dart';
import 'Login.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
          RaisedButton(
              child: Text("Sign out"),
              onPressed: (){
                    Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
                      },
                    ),
                  );
                }
              )]
      ))
    ]));
  }
}