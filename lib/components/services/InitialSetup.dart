import '../screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../screens/onboarding.dart';
import '../../main.dart';
import '../NoteObject.dart';
import 'dart:convert';

// Checks if there are any notes stored.
void InitialSetup() async{
  // Gets stored data from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? decodedObjects = prefs.getStringList("notes");

  if(decodedObjects == null){
    NoteObjectList = [];
  } else {
    NoteObjectList = decodedObjects.map((res)=>NoteObject.fromJson(json.decode(res))).toList();
  }
  // Checks if app was initialized before and sets firstBoot accordingly.
  double? firstBoot = prefs.getDouble("firstBoot");
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (firstBoot == null){
    prefs.setDouble("firstBoot", 2);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(const CupertinoApp(
      home: OnboardingPage(),
      title: 'Audionote',
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
    ),));
  } else {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(CupertinoApp(
      home: Home(),
      title: 'Audionote',
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
    ),));
  }
}