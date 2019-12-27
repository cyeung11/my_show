import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/storage/database_helper.dart';
import 'package:my_show/model/watch_progress.dart';
import 'package:my_show/page/home_page.dart';
import 'package:my_show/storage/pref_helper.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    PrefHelper.init().then((pref){
      DatabaseHelper.initDb().then((_){
        runApp(MyApp());
      });
    });
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static const methodHost = const MethodChannel('com.jkjk.my_show');
  static const methodClient = const MethodChannel('com.jkjk.my_show.to_flutter');

  MyApp({Key key}): super(key: key){
    methodClient.setMethodCallHandler((call) async{
      if (call.method == 'progressIncrement' && call.arguments is int) {
        var tv = await TvDetails.getById(call.arguments);
        if (tv != null) {
          tv.progress.next(tv.seasons);
          await tv.insert();
          return true;
        }
      } else if (call.method == 'progressDecrement' && call.arguments is int) {
        var tv = await TvDetails.getById(call.arguments);
        if (tv != null) {
          tv.progress.previous(tv.seasons);
          await tv.insert();
          return true;
        }
      } else if (call.method == 'getSavedTv') {
        var tvs = await TvDetails.all();
        if (tvs != null) {
          return tvs.map((tv) => jsonEncode(tv.toDb())).toList().toString();
        }
      }
      return null;
    });
  }

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
