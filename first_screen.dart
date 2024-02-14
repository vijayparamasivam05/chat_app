import 'package:chat_app/profile.dart';
import 'package:chat_app/user_api_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GoogleButton.dart';
import 'notifications.dart';

void signOutGoogle() async {
  await googleSignIn.signOut();
  await mAuth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);
  print("User signed out of Google account");
}
class FirstScreen extends StatelessWidget {
  final String userId;
  FirstScreen({Key key, @required this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new HomePage(userId),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userId;
  HomePage(this.userId);
  @override
  _HomePageState createState() => _HomePageState(userId);
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  final String userId;
  _HomePageState(this.userId);
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat App"),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.amber,
          tabs: [
            new Tab(icon: new Icon(Icons.home)),
            new Tab(icon: new Icon(Icons.notifications)),
            new Tab(icon: new Icon(Icons.account_circle)),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,),
        bottomOpacity: 1,
      ),//App Bar
      body: TabBarView(
        children: [
          new MyApiPage(userId: userId),
          new MyNotificationPage(userId: userId),
          new MyProfilePage(userId: userId),
        ],//children
        controller: _tabController,),//Body
    );//return scaffold
  }
}