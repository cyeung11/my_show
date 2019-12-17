import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/page/home_page.dart';
import 'package:my_show/show_storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    SharedPreferences.getInstance().then((pref){
      var storageHelper = ShowStorageHelper(pref);
      runApp(MyApp(pref: storageHelper,));
    });
  });
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final ShowStorageHelper pref;

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
      home: HomePage(pref: pref,),
    );
  }
}
