import 'package:flutter/material.dart';
import 'FirstScreen.dart';
import 'GoogleButton.dart';
import 'SignUp.dart';


bool authSignedIn;
String uid;
String userEmail;

class Login extends StatefulWidget {
  @override
  Page createState() => Page();
}
class Page extends State<Login>{
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();


  @override
  Widget build(BuildContext context, ) {
    // TODO: implement build
    return Scaffold(
        body: Container(
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
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: 'Email'
                ),//Input Decoration
              ),
              TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                    labelText: 'Password'
                ),//Input Decoration
              ),
              RaisedButton(
                child: Text("Login"),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return FirstScreen();
                        },
                      ),
                    );
                  }//onPressed
                ),
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
                  )),
              GoogleButton(),
            ],
          ),
        )
    );
  }

}