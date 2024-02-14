import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google_button.dart';
import 'const.dart';
import 'first_screen.dart';
import 'login_page.dart';
import 'mysettings.dart';

void signOutGoogle() async {
  await googleSignIn.signOut();
  await mAuth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);
  prefs.setString('id', null);
  prefs.setString('nickname', null);
  prefs.setString('photoUrl', null);
  prefs.setString('token', null);
  print("User signed out of Google account");
}

class MyProfilePage extends StatefulWidget {
  final String userId;
  final String title;
  MyProfilePage({Key key, @required this.userId,@required this.title}) : super(key: key);
     @override
    _MyProfilePageState createState() => new _MyProfilePageState(userId,title);
    }
class _MyProfilePageState extends State<MyProfilePage>{
  final String userId;
  final String title;
  _MyProfilePageState(this.userId,this.title);
  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String photoUrl = '';
  String aboutMe = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    readLocal();
    BackButtonInterceptor.add(myInterceptor);
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';

    // Force refresh input
    setState(() {});
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FirstScreen(userId:id);
        },
      ),
    );
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
        body: buildItem(context)
    );
  }


  @override
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
                            imageUrl: photoUrl,
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
                                    Text( nickname,
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
                                    aboutMe==""? Text(
                                      "About me",
                                    ):
                                    Text( aboutMe,
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
                Container(
                    child: Row(
                      children: <Widget>[
                        FlatButton(
                            textColor: Colors.blue,
                            child: Text(
                              'Update',
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MySettings()),
                              );
                            }//onpressed
                        ),
                        FlatButton(
                            textColor: Colors.blue,
                            child: Text(
                              'Sign Out',
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              signOutGoogle();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            }//onpressed
                        ) ],//Children
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),
                Center(
                  child:Text(
                      "version: 0.0.2"
                  )
                )
              ],
    );//List view
}
}