import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'network/MyHomePage.dart';

void main(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
      runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Show',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UpcomingPage(),
    );
  }
}
