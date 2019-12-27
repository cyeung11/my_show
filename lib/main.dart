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

  MyApp({@required this.pref, Key key}): super(key: key);

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
