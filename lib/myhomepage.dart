import 'package:flutter/material.dart';
import 'notifications.dart';
import 'user_api_list.dart';
import 'profile.dart';
class MyHomePage extends StatelessWidget {
  final String text;
  MyHomePage({Key key, @required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new HomePage(text),
    );
  }
}

class HomePage extends StatefulWidget {
final String text;
HomePage(this.text);
  @override
  _HomePageState createState() => _HomePageState(text);
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  String text;
  //_HomePageState(this.text);
  _HomePageState(String text) {
    this.text = text;
  }
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Flutter"),
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
        new MyApiPage(),
        new MyNotificationPage(text),
        new MyProfilePage(text),
      ],//children
      controller: _tabController,),//Body
      );//return scaffold
  }
}