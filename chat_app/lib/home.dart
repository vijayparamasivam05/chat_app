import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'first_screen.dart';

class MyHomePage extends StatefulWidget {
  final String userId;
  final String title;

  MyHomePage({Key key, @required this.userId,@required this.title}) : super(key: key);
  @override
  MyHomePageState createState() => new MyHomePageState(userId,title);
}
class MyHomePageState extends State<MyHomePage> {
  final String userId;
  final String title;
  String latest;
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  MyHomePageState(this.userId,this.title);

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
                  itemBuilder: (context, index) => buildItem(context, list[index]),
                  itemCount: list.length,
                );
              }
            }, //builder
          ),
        ));
  }

  Widget buildUser(BuildContext context, DocumentSnapshot document, String latest,String latestTime){
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
                    Row(
                      children: [
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
                        new Spacer(),
                        Container(
                          child: Text(
                              latestTime,
                            style: TextStyle(color: Colors.black,
                                fontSize: 15),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    Container(
                          child:Text(
                              latest,
                            style: TextStyle(color: Colors.black,
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
                    peerDeviceToken: document.data()['token'],
                  )));
        },
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        //shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 5.0, left: 0.0, right: 0.0),
    );
  }

  Widget buildItem(BuildContext contextUser, DocumentSnapshot documentUser)  {
    if (documentUser.data()['id'] == userId) {
      return Container();
    } else {
      String chatId = getGroupChatId(documentUser.data()['id'], userId);
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection(chatId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            int itemLength = snapshot.data.documents.length-1;
            if(itemLength>=0){
            latest=snapshot.data.documents[itemLength].data()['content'];
            int type = snapshot.data.documents[itemLength].data()['type'];
            String latestTime =  DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot.data.documents[itemLength].data()['timestamp'])));
            if(latest == null ){
              return Container();
            }
            else{
              return type==0 ?
              Container(
                  child:buildUser(contextUser, documentUser, latest, latestTime)) :
              Container(
                  child:buildUser(contextUser, documentUser, "Image", latestTime));
            }
          }
          else{
            return Container();
          }}
        },
      );
    }
  }

  String getGroupChatId(peerId, String id) {
    if (id.hashCode <= peerId.hashCode) {
      return '$id-$peerId';
    } else {
      return '$peerId-$id';
    }
  }
}