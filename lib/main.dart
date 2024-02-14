import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'SignUp.dart';
import 'WelcomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'CounterBloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CounterBloc>.value(
      value: CounterBloc(),
      child: MaterialApp(
        title: 'My First App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'My App'),

      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  TextEditingController username = TextEditingController(); // username input
  TextEditingController password = TextEditingController(); //password input
  String name;
  String password1;
  bool validateUsername= false, validatePass=false, isLoggedIn=false;
  Map userProfile;

  FirebaseAuth _auth = FirebaseAuth.instance;// create firebase auth instance
  final _facebookLogin =  FacebookLogin();
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  User _user;

  @override
  void initState() {
    super.initState();
    _ifLoggedIn();
  }

  // check if the user is already logged in. If yes navigate to the WelcomePage
  void _ifLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = (prefs.getBool('login') ?? true);

    if (isLoggedIn == true) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => WelcomePage()));
    }
  }
  @override
  void dispose() {

    username.dispose();
    password.dispose();
    super.dispose();
  }

  //Returns the saved password
  Future<String> getPreference() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String pass =prefs.getString(username.text);
    return pass;

  }

  // Saves the username and the log in status
  Future<void> savePreference(bool isLoggedIn, String user ) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user",user );
    prefs.setBool('login',isLoggedIn);
  }

  Future<void> savePreferenceURL( String url) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", url );

  }

  Future<void> savePreferenceEmail( String email) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email );

  }




// code for facebook login
  _loginWithFacebook() async{

    if(isLoggedIn==true) // Check if the user is already logged in and if yes logout from facebook
        {
      _facebookLogin.logOut();
      setState(() {
        isLoggedIn = false;
      });
    }

    final result = await _facebookLogin.logIn(['email','public_profile']);// return login status

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:// if status is loggedIn get the user profile data
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),email&access_token=$token'); // Fetching the name, image and email address
        final profile = json.decode(graphResponse.body);  // profile variable will contain name, image and email address
        // print(profile);
        // Set isLoggedIn as true and save the username in shared preference
        setState(() {
          userProfile = profile;
          isLoggedIn = true;
          savePreference(isLoggedIn, userProfile["name"]);
          savePreferenceURL(userProfile["picture"]["data"]["url"]);
          savePreferenceEmail(userProfile["email"]);

          //print(profile);

        });
        Center(child: CircularProgressIndicator());
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomePage()),
        );
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => isLoggedIn = false );
        break;
      case FacebookLoginStatus.error:
        setState(() => isLoggedIn = false );
        break;
    }

  }

  // Sign in using google
  Future<void> _loginWithGoogle() async {
    _googleSignOut();
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(

        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result = (await _auth.signInWithCredential(credential));
    _user = result.user;

    setState(() {
      isLoggedIn = true;
      savePreference(isLoggedIn, _user.displayName);
      savePreferenceURL(_user.photoURL );
      savePreferenceEmail(_user.email);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WelcomePage()),
    );
  }

  Future<void> _googleSignOut() async {
    await _auth.signOut().then((onValue) {
      _googleSignIn.signOut();
      setState(() {
        isLoggedIn = false;
      });
      // savePreference(isLoggedIn);
    });
  }

  Widget _socialButton(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
        body:
        Padding(
            padding: EdgeInsets.all(0),
            child: ListView(
              children:<Widget> [
                Container(
                  padding: EdgeInsets.fromLTRB(50,30,50,20),
                  child: Center(
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.blueAccent,
                      size: 100.0,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'OpenSans',
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )),


                Container(
                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                    ],
                    controller: username,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: 'User Name',
                      prefixIcon: Icon(Icons.account_circle),
                      errorText: validateUsername?'Value cannot be empty':null,
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextField(
                    obscureText: true,
                    controller: password,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      errorText: validatePass ?'Value cannot be empty':null,

                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                  //width: double.infinity,
                  child: RaisedButton(
                    elevation: 0,
                    onPressed: () {
                      setState(() {
                        username.text.isEmpty? validateUsername=true: validateUsername=false;

                        password.text.isEmpty ? validatePass = true : validatePass =
                        false;

                      });

                      getPreference().then((value)
                      {
                        if(password.text==value) //Check if the password entered is correct and then save the Username and set the login status as true
                            {
                          savePreference(true, username.text);
                          savePreferenceURL(null);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomePage()),
                          );
                          //}
                          //);
                        }
                        else if(password.text!=value){
                          Toast.show(
                              "Username or Password Incorrect",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity:  Toast.BOTTOM,
                              textColor: Colors.red);

                        }
                      });


                    },
                    padding: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.blue,
                    child: Text(
                      'LOGIN',
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


                Container(

                  child: Column(
                    children: <Widget>[
                      Text(
                        '- OR -',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                            fontFamily:'OpenSans'
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Sign in with',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),



                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _socialButton(
                              () => _loginWithFacebook(),
                          AssetImage(
                            'assets/facebook.jpg',
                          ),
                        ),
                        _socialButton(
                              () =>  _loginWithGoogle(),
                          AssetImage(
                            'assets/google.jpg',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Does not have account?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),),
                        FlatButton(
                          textColor: Colors.blue,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            //signup
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),
              ],


            )));


  }
}

