import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CounterBloc.dart';


class Message{
  final int id;
  final  String title;
  final String body;

  Message({this.id,this.title,this.body});


}



class NotificationScreen extends StatefulWidget{

  @override
  _NotificationScreenState createState() => _NotificationScreenState();

}

class _NotificationScreenState extends State<NotificationScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  List<Message> notificationMessage = new List<Message>();
  int notificationCounter = 0;
  @override
  void initState(){
    super.initState();
    initializing();
  }


  void initializing() async
  {
    androidInitializationSettings= AndroidInitializationSettings('@mipmap/ic_launcher');
    iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification );
    initializationSettings = InitializationSettings(androidInitializationSettings,iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification );
  }
  void _showNotifications() async{
    await notification();

  }

  Future<void> notification() async{
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'channel ID','channel title','channel body',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails,iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, 'Hello there', 'You have a notification', notificationDetails);
    notificationMessage.add(Message(title:'Hello There',body: 'You have a notification'));
    print(notificationMessage);
  }

  Future onSelectNotification(String payLoad)
  {
    /*if(payLoad!= null)
        {
          print(payLoad);
        }*/
    // navigator
    showDialog(context: context,
      builder: (_) => new AlertDialog(
        title: const Text("Here is payload"),
        content: new Text("Payload : $payLoad"),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title,String body, String payLoad ) async{
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('OK'),
        )
      ],
    );

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
    return Scaffold(
      body: Container(
        child:
        ListView.builder(
            itemCount: notificationMessage.length,
            itemBuilder: (context, index){
              return _tile(notificationMessage[index].title, notificationMessage[index].body, Icons.arrow_right);

            }
        ),

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          _showNotifications();
          counterBloc.increment();
          setState(() {

          });
        },

        backgroundColor: Colors.blue,
      ),
    );
  }

  ListTile _tile(String title, String subtitle, IconData icon) => ListTile(
    //contentPadding: EdgeInsets.all(10),
    title: Text(title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        )),
    subtitle: Text(subtitle),
    leading: Icon(
      icon,
      color: Colors.blue[500],
    ),
  );


}

