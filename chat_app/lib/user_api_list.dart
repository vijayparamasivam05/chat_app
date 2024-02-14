import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'first_screen.dart';

class MyApiPage extends StatefulWidget {
  final String userId;
  final String title;

  MyApiPage({Key key, @required this.userId,@required this.title}) : super(key: key);
  @override
   _MyApiPageState createState() => new _MyApiPageState(userId,title);
    }
class _MyApiPageState extends State<MyApiPage> {
  final String userId;
  final String title;

  _MyApiPageState(this.userId,this.title);

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FirstScreen(userId:userId);
        },
      ),
    );// Do some stuff.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
          title: new Text(
            title,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),)),
          body: Container(
            child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
                } //if
              else {
              final list = snapshot.data.docs;
                return ListView.builder(
                //padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => buildItem(context, list[index]),
                itemCount: list.length,
              );
           }
         }, //builder
        ),
    ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document.data()['id'] == userId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document.data()['photoUrl'] != null
                    ? CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: document.data()['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.account_circle,
                  size: 50.0,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),//Avatar
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          document.data()['nickname'],
                          style: TextStyle(color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                      peerId: document.id,
                      peerAvatar: document.data()['photoUrl'],
                      peerName: document.data()['nickname'],
                      peerAboutMe: document.data()['aboutMe'],
                      peerDeviceToken: document.data()['token']
                    )));
          },
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          //shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 5.0, left: 0.0, right: 0.0),
      );
    }
  }
}