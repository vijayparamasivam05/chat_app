import 'package:flutter/material.dart';
import 'FirstScreen.dart';
import 'Login.dart';

bool authSignedIn;
String uid;
String userEmail;

class SignUp extends StatefulWidget {
  @override
  Page createState() => Page();
}
class Page extends State<SignUp>{
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
                  'SignUp Page',
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
                controller: passwordController,
                decoration: InputDecoration(
                    labelText: 'Password'
                ),//Input Decoration
              ),
              RaisedButton(
                child: Text("SignUp"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return FirstScreen();
                      },
                    ),
                  );
                }),
              Container(
                  child: Row(
                    children: <Widget>[
                      Text('Already have an account?'),
                      FlatButton(
                          textColor: Colors.blue,
                          child: Text(
                            'Login in',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          }//onpressed
                      ) ],//Children
                    mainAxisAlignment: MainAxisAlignment.center,
                  ))
            ],
          ),
        )
    );

  }
}