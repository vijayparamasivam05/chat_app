import 'first_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'chat_page.dart';
import 'model/my_message.dart';

class SetupScreen extends StatelessWidget {

  final String userId;
  SetupScreen({Key key, @required this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new SetupScreenPage(userId),
    );
  }
}

class SetupScreenPage extends StatefulWidget {

  final String userId;
  SetupScreenPage(this.userId);
  @override
  _SetupScreenPageState createState() => _SetupScreenPageState(userId);
}

class _SetupScreenPageState extends State<SetupScreenPage> with SingleTickerProviderStateMixin {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];

  String id;

  _SetupScreenPageState(this.id);

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
  }

  handleNotification(String notificationId,context) async {
    await Firebase.initializeApp();
    final List < DocumentSnapshot > documents = (await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: notificationId).get()).docs;
    Navigator.push(context, MaterialPageRoute(builder:
        (context)=>Chat(peerId: documents[0].data()['id'],
      peerAvatar: documents[0].data()['photoUrl'],
      peerName: documents[0].data()['nickname'],
      peerAboutMe: documents[0].data()['aboutMe'],
      peerDeviceToken: documents[0].data()['token'])));
  }

  _configureFirebaseMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        final data = message['data'];
        print("Id inside onMessage: $data['id']");
        setState(() {
          messages.add(Message(title:notification['title'],body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        final notification = message['notification'];
        final data = message['data'];
        print("Id inside onLaunch: $data['id']");
        setState(() {
          messages.add(Message(title:notification['title'],body: notification['body']));
        });
        if(message != null){handleNotification(data['id'], context);}
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final notification = message['notification'];
        final data = message['data'];
        print("Id inside onResume: $data['id']");
        setState(() {
          messages.add(Message(title:notification['title'],body: notification['body']));
        });
        if(message != null){handleNotification(data['id'], context);}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FirstScreen(userId:id);
  }

  @override
  void dispose() {
    super.dispose();
  }
}