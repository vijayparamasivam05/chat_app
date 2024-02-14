import 'package:flutter/material.dart';
class MyNotificationPage extends StatelessWidget {
  final String userId;
  MyNotificationPage({Key key, @required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: Text(
          userId,
            style: TextStyle(
            fontSize: 20,
            color: Colors.blue,
            ),//Style
        ),//Text
        ),//Body
      );
  }

  
}