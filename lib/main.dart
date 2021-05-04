import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/state/genre_state_model.dart';
import 'package:my_show/state/movie_state_model.dart';
import 'package:my_show/state/tv_state_model.dart';
import 'package:provider/provider.dart';
import 'package:my_show/page/home_page.dart';
import 'package:my_show/storage/database_helper.dart';
import 'package:my_show/storage/pref_helper.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runZonedGuarded(() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
      PrefHelper.init().then((pref){
        DatabaseHelper.initDb().then((_){
          runApp(
              MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => GenreStateModel()),
                ChangeNotifierProvider(create: (_) => MovieStateModel()),
                ChangeNotifierProvider(create: (_) => TvStateModel())
              ],
                child: MyApp(),
              )
          );
        });
      });
    });
  }, FirebaseCrashlytics.instance.recordError);
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
        unselectedWidgetColor: Colors.grey,
      ),
      home: HomePage(),
    );
  }
}
