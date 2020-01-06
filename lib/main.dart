import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/page/home_page.dart';
import 'package:my_show/storage/database_helper.dart';
import 'package:my_show/storage/pref_helper.dart';


void main(){

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
      PrefHelper.init().then((pref){
        DatabaseHelper.initDb().then((_){
          runApp(MyApp());
        });
      });
    });
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Show',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        accentColor: Colors.grey,
        primaryColor: Colors.white,
        canvasColor: Colors.grey,
      ),
      home: HomePage(),
    );
  }
}
