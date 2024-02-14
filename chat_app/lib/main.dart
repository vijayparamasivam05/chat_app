import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'SetupScreen.dart';
import 'login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString('id');
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: id == null? LoginPage():SetupScreen(userId: id)));
}

