import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:email_validator/email_validator.dart';
class SignUp extends StatefulWidget {



  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  bool validateUsername= false, validateEmail=false, validatePassword = false;

// save the username, email and password in shared preference
  _saveData( ) {
    String _username = username.text;
    String _email = email.text;
    String _password = password.text;
    print(_username);
    print(_password);
    print(_email);
    savePreference(_username, _email, _password);
    //navigate to the homepage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'My App')),
    );
  }


  Future<void> savePreference(String name, String email, String password) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(name,password );
    prefs.setString("email", email);
    //prefs.setString("name", name);

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('My App'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),

            child: ListView(
              children:<Widget> [
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'SignUp',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                          fontSize: 30),
                    )),

                // Take the username as input
                Container(
                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                  child: TextField(
                    // onChanged:  ,
                    controller: username,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: ' Username',
                      prefixIcon: Icon(Icons.account_circle),
                      hintText: 'eg:Harry',
                      errorText: validateUsername?'Please enter a username':null, // check if the text field is empty

                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: ' Email Id',
                      prefixIcon: Icon(Icons.email),
                      hintText: 'eg:abc@gmail.com',
                      errorText: validateEmail ?'Please enter an email':null, // Check if the text field is empty
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    controller: password,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      errorText: validatePassword ?'Please enter a password':null, // Check if the text field is empty
                    ),
                  ),
                ),


                Container(
                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                  //width: double.infinity,
                  child: RaisedButton(
                    elevation: 0,
                    // On pressing the button validate if the fields are empty and if not then save the data
                    onPressed: () {
                      setState(() {
                        username.text.isEmpty? validateUsername=true: validateUsername=false;

                        password.text.isEmpty ? validatePassword = true : validatePassword =
                        false;
                        email.text.isEmpty? validateEmail= true : validateEmail = false;

                      });
                      if(validateEmail==false && validatePassword==false && validateUsername==false)
                      {
                        _saveData();
                      }


                    },
                    padding: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.blue,
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ),

              ],


            )));


  }
}
