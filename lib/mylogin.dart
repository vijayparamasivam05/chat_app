import 'package:flutter/material.dart';
import 'myhomepage.dart';
import 'signin.dart';
class MyLogin extends StatefulWidget{
    _MyLoginState createState() => _MyLoginState();
}
class _MyLoginState extends State<MyLogin>{
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    @override
    Widget build(BuildContext context){
        return Scaffold(
                body: SafeArea(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            child:Text(
                                'Login Page',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    ),//Style
                                ),//Text
                        ),//TEXTContainer
                        Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'User Name',
                                ),//Decoration
                            ),//TextField
                        ),//Username_Container
                        Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Password',
                                ),//Decoration
                            ),//TextField
                        ),//Password_Container
                        Container(
                            alignment: Alignment.center,
                            child: RaisedButton(
                                color: Colors.blue,
                                child: Text(
                                    'LOGIN',
                                    style: TextStyle(color: Colors.white),//Style
                                ),//Text
                                onPressed: (){
                                     _sendDataToHomePage(context);
                                },//onpressed function of login
                            ),//Button
                        ),//Login_button_Container
                        Container(
                         child: Row(
                         children: <Widget>[
                         Text('Does not have account?'),
                         FlatButton(
                         textColor: Colors.blue,
                         child: Text(
                          'Sign in',
                          style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                              );
                              }//onpressed
                          ) ],//Children
                    mainAxisAlignment: MainAxisAlignment.center,
                ))//SignIn Container                         
                    ],//Widget
                    ),//Column
                ),//body
        );//Scaffold
    }
// Void method to passing parameters from one screen to another
    void _sendDataToHomePage(BuildContext context) {
    String textToSend = usernameController.text;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(text: textToSend,),
        ));
  }
}