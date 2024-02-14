import 'package:flutter/material.dart';
import 'NotificationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart';
import 'CounterBloc.dart';
import 'main.dart';
import 'ListViewApi.dart';
import 'package:provider/provider.dart';
class WelcomePage extends StatefulWidget {
  //final String name;
  //WelcomePage(this.name,{Key key }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  String name="";
  String photoUrl = "";
  String email = "";
  static int notificationCounter=0;
  @override
  void initState() {
    super.initState();
    getPreferenceName().then((value) {
      setState(() {
        name=value;
      });
    });

    getPreferenceURL().then((value) {
      setState(() {
        photoUrl = value;
      });
    });

    getPreferenceEmail().then((value) {
      setState(() {
        email = value;
      });
    });

    getPreferenceCount().then((value) {
      setState(() {
        notificationCounter = value;
      });
    });
  }

  Future<String> getPreferenceName() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String name =prefs.getString("user");
    // print(pass);
    return name;

  }
  Future<String> getPreferenceURL() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String _url =prefs.getString("url");
    // print(pass);
    return _url;

  }

  Future<String> getPreferenceEmail() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String _email =prefs.getString("email");
    // print(pass);
    return _email;

  }

  Future<void> savePreference(bool isLoggedIn) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('login',isLoggedIn);
  }

  Future<void> savePreferenceCount( ) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('counter',notificationCounter);
  }

  Future<int> getPreferenceCount() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int counter =prefs.getInt("counter");

    return counter;

  }

  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = Provider.of<CounterBloc>(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: (){
                savePreference(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'My App')),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_circle)),
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon:Badge(
                  shape: BadgeShape.circle,
                  badgeContent: Text(counterBloc.counter.toString()),
                  animationType: BadgeAnimationType.slide,
                  showBadge:(counterBloc.counter>0)?true: false,
                  child: Icon(Icons.notifications)),
              )

            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children:<Widget> [
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                          fontFamily:'OpenSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),


                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                     CircleAvatar(
                       backgroundColor: Colors.transparent,
                       backgroundImage: NetworkImage(photoUrl??"https://www.materialui.co/materialIcons/action/account_circle_black_192x192.png" ),
                       radius: 60,
                     ),
                        SizedBox(height: 20,),
                        Text(name,
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text(email,
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],

                    )

                ),



              ],

            ),


            ListViewApi(),
            NotificationScreen(),
          ],
        ),
      ),
    );


  }
}

