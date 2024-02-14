import 'package:chat_app/profile.dart';
import 'package:chat_app/user_api_list.dart';
import 'package:flutter/material.dart';
import 'home.dart';

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
  PageController _pageController;
  int _page = 0;

  String id;

  _HomePageState(this.id);

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 10), curve: Curves.linear);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new PageView(
        children: [
          new MyHomePage(userId: id,title:"Home"),
          new MyApiPage(userId: id,title:"Contacts"),
          new MyProfilePage(userId: id,title:"Profile"),
        ],
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.white,
        ), // sets the inactive color of the `BottomNavigationBar`
        child: new BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.blueAccent,
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.home,
              ),
              title: new Text(
                "Home",
              ),
            ),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.contacts,
                ),
                title: new Text(
                  "Contacts",
                )),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.account_circle,
                ),
                title: new Text(
                  "Profile",
                )),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }
}