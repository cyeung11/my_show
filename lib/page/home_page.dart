import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/pageview_page/browse_page_widget.dart';
import 'package:my_show/pageview_page/page_manager/browse_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/saved_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/search_page_manager.dart';
import 'package:my_show/pageview_page/page_manager/trending_page_manager.dart';
import 'package:my_show/pageview_page/saved_page_widget.dart';
import 'package:my_show/pageview_page/search_page_widget.dart';
import 'package:my_show/pageview_page/setting_page_widget.dart';
import 'package:my_show/pageview_page/trending_page_widget.dart';

import '../show_storage_helper.dart';

class HomePage extends StatefulWidget{
  final ShowStorageHelper pref;

  HomePage({@required this.pref, Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {

  static const platform = const MethodChannel('com.jkjk.my_show');

  var _currentItem = 0;
  PageController _pageController;

  // State holders
  SearchPageManager _searchPageManager = SearchPageManager();
  SavedPageManager _savedPageManager;
  TrendingPageManager _trendingPageManager = TrendingPageManager();
  BrowsePageManager _browsePageManager = BrowsePageManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),);

    _pageController = PageController();
    _savedPageManager = SavedPageManager(widget.pref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _savedPageManager.saveToStorage();
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
        return TrendingPageWidget(widget.pref, _trendingPageManager);
      }
      case 1: {
        return BrowsePageWidget(widget.pref, _browsePageManager);
      }
      case 2: {
        return SearchPageWidget(widget.pref, _searchPageManager);
      }
      case 3: {
        return SavedPageWidget(widget.pref, _savedPageManager);
      }
      default: {
        return SettingPageWidget();
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
//          _pageController.animateToPage(currentItem, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
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

    if (Platform.isAndroid) {
      try {
        return await platform.invokeMethod('backToExit');
      } on PlatformException catch (e) {
        print(e);
      }
    }

    return Future.value(true);
  }
}