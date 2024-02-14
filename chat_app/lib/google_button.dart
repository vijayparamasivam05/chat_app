import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/first_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth mAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

bool authSignedIn;
String uid;
String name;
String photoUrl;
String deviceToken;

Future<String> signInWithGoogle() async {
  // Initialize Firebase
  await Firebase.initializeApp();


  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential userCredential = await mAuth.signInWithCredential(credential);
  final User user = userCredential.user;

  if (user != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', true);
    // Checking if email and name is null
    assert(user.uid != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);

    uid = user.uid;
    name = user.displayName;
    photoUrl = user.photoURL;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = mAuth.currentUser;
    assert(user.uid == currentUser.uid);
    final List < DocumentSnapshot > documents = (await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: user.uid).get()).docs;
    if (documents.length == 0) {
      // Update data to server if new user

      _firebaseMessaging.getToken().then((deviceToken)  {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            { 'nickname': user.displayName, 'id': user.uid,'chattingWith': null, 'photoUrl': user.photoURL, 'aboutMe': '', 'token':deviceToken });
      });
      await prefs.setString('id', currentUser.uid);
      await prefs.setString('nickname', currentUser.displayName);
      await prefs.setString('photoUrl', currentUser.photoURL);
      await prefs.setString('aboutMe', "");
    }
    else {
      // Write data to local
      _firebaseMessaging.getToken().then((deviceToken)  {
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'token': "$deviceToken"
        });
        print("Device token inside: $deviceToken");
      });

      await prefs.setString('id', documents[0].data()['id']);
      await prefs.setString('nickname', documents[0].data()['nickname']);
      await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
      await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
      await prefs.setString('token', documents[0].data()['token']);
    }

    print('Google sign in successful');
    return  user.uid;
  }

  return null;
}

class GoogleButton extends StatefulWidget {
  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey, width: 3),
        ),
        color: Colors.white,
      ),
      child: OutlineButton(
        highlightColor: Colors.blueGrey[100],
        splashColor: Colors.blueGrey[200],
        onPressed: () async {
          setState(() {
            _isProcessing = true;
          });
          await signInWithGoogle().then((result) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return FirstScreen(userId:result);
                },
              ),
            );//Navigator
          }).catchError((error) {
            print('Registration Error: $error');
          });
          setState(() {
            _isProcessing = false;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey, width: 3),
        ),
        highlightElevation: 0,
        // borderSide: BorderSide(color: Colors.blueGrey, width: 3),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: _isProcessing
              ? CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.blueGrey,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/google_logo.png"),
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blueGrey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}