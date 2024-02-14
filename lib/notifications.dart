import 'package:flutter/material.dart';
class MyNotificationPage extends StatelessWidget {
  final String text;
  MyNotificationPage(this.text);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: Text(
          text,
            style: TextStyle(
            fontSize: 20,
            color: Colors.blue,
            ),//Style
        ),//Text
        ),//Body
      );
  }

  
}