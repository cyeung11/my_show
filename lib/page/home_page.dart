import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_show/drive/auth_manager.dart';
import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/pageview_page/browse_page_widget.dart';
import 'package:my_show/pageview_page/page_manager/browse_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/saved_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/search_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/trending_page_manager.dart';
import 'package:my_show/pageview_page/saved_page_widget.dart';
import 'package:my_show/pageview_page/search_page_widget.dart';
import 'package:my_show/pageview_page/setting_page_widget.dart';
import 'package:my_show/pageview_page/trending_page_widget.dart';

import '../main.dart';
import '../storage/pref_helper.dart';

class HomePage extends StatefulWidget{

  final _authMan = AuthManager();

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {

  var _currentItem = 0;
  PageController _pageController;

  // State holders
  SearchPageManager _searchPageManager = SearchPageManager();
  SavedPageManager _savedPageManager = SavedPageManager();
  TrendingPageManager _trendingPageManager = TrendingPageManager();
  BrowsePageManager _browsePageManager = BrowsePageManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark));

    _pageController = PageController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (PrefHelper.instance.getString(PREF_DRIVE_USER_NAME)?.isNotEmpty == true
          && (DateTime.now().millisecondsSinceEpoch - PrefHelper.instance.getInt(PREF_DRIVE_BACKUP_TIME, defaultValue: 0)) > (6 * Duration.millisecondsPerHour)) {
        // Auto back if last back up is more than 6 hours old
        widget._authMan.getAccount(silently: true).then((acc) {
          if (acc != null) {
            ShowBackupHelper.backup(acc);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: Scaffold(
        bottomNavigationBar: _bottomBar(),
        body: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
          onPageChanged: (index){
            setState(() {
              _currentItem = index;
            });
          },
          itemBuilder: (context, index) => _page(context, index),
        ),
      ),
    );
  }

  Widget _page(BuildContext context, int index){
    switch (index) {
      case 0: {
        return TrendingPageWidget(_trendingPageManager);
      }
      case 1: {
        return BrowsePageWidget(_browsePageManager);
      }
      case 2: {
        return SearchPageWidget(_searchPageManager);
      }
      case 3: {
        return SavedPageWidget(_savedPageManager);
      }
      default: {
        return SettingPageWidget(_restore, widget._authMan);
      }
    }
  }

  Widget _bottomBar() {
    return BottomNavyBar(
      selectedIndex: _currentItem,
      backgroundColor: Colors.black,
      showElevation: true, // use this to remove appBar's elevation
      onItemSelected: (index) {
        setState(() {
          _currentItem = index;
          _pageController.jumpToPage(_currentItem);
        });
      },
      items: [
        BottomNavyBarItem(
            icon: Icon(Icons.trending_up),
            title: Text('Trending'),
            activeColor: Colors.orangeAccent,
            inactiveColor: Colors.grey
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.explore),
            title: Text('Browse'),
            activeColor: Colors.blue,
            inactiveColor: Colors.grey
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
            activeColor: Colors.green,
            inactiveColor: Colors.grey
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Saved'),
            activeColor: Colors.redAccent,
            inactiveColor: Colors.grey
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
            activeColor: Colors.white,
            inactiveColor: Colors.grey
        ),
      ],
    );
  }

  /// return false to intercept the back press action
  Future<bool> onBackPress() async {
    if (Platform.isAndroid) {

      if (_currentItem == 0) {
        if (_trendingPageManager.isMenuOverlay) {
          setState(() {
            _trendingPageManager.isMenuOverlay = false;
          });
          return Future.value(false);
        }
      } else if (_currentItem == 3) {
        if (_savedPageManager.deleteMode) {
          setState(() {
            _savedPageManager.deleteMode = false;
          });
          return Future.value(false);
        }
      }

      try {
        return await MyApp.methodHost.invokeMethod('backToExit');
      } on PlatformException catch (e) {
        print(e);
      }
    }

    return Future.value(true);
  }

  _restore(GoogleSignInAccount acc){
    ShowBackupHelper.restore(acc).then((backup){
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text('Backup Found!',),
          content: Text('Do you want to restore from your backup?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK',
                style: TextStyle(color: Colors.blueGrey),),
              onPressed: (){
                PrefHelper.instance.restore(backup);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    });
  }
}