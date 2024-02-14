import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'const.dart';

class OtherUserProfile extends StatefulWidget {
  final String peerAvatar;
  final String peerName;
  final String peerAboutMe;
  OtherUserProfile({Key key, @required this.peerName,@required this.peerAvatar,@required this.peerAboutMe}) : super(key: key);
  @override
  _OtherUserProfileState createState() => new _OtherUserProfileState(peerName,peerAvatar,peerAboutMe);
}
class _OtherUserProfileState extends State<OtherUserProfile>{
  String peerAboutMe;
  String peerAvatar;
  String peerName;
  String name;
  String About;
  String Avatar;
  _OtherUserProfileState(this.peerName,this.peerAvatar,this.peerAboutMe);

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
    Navigator.of(context).pop();// Do some stuff.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
            title: new Text(
              peerName,
              style: new TextStyle(color: const Color(0xFFFFFFFF)),)),
        body: buildItem(context)
    );
  }
  Widget buildItem(BuildContext context) {
    return  ListView(
      children:<Widget> [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                          themeColor),
                    ),
                    width: 170.0,
                    height: 170.0,
                    padding: EdgeInsets.all(20.0),
                  ),
                  imageUrl: peerAvatar,
                  width: 170.0,
                  height: 170.0,
                  fit: BoxFit.cover,
                ),
                borderRadius:
                BorderRadius.all(Radius.circular(100.0)),
                clipBehavior: Clip.hardEdge,
              ),
              SizedBox(height: 20,),
              Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.account_circle),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text( peerName,
                            style:TextStyle(
                              fontSize: 20,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top:40,left: 40.0),
              ),
              SizedBox(height: 20,),
              Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline),
                    Container(
                      child: Column(
                        children: <Widget>[
                          peerAboutMe==""? Text(
                            "Nothing to show",
                          ):
                          Text( peerAboutMe,
                            style:TextStyle(
                              fontSize: 20,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top:40,left: 40.0),
              ),
            ],
          ),
        ),
      ],
    );//List view
  }
}
