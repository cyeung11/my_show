import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/pagemanager/browse_page_manager.dart';
import 'package:my_show/pagemanager/saved_page_manager.dart';
import 'package:my_show/pagemanager/search_page_manager.dart';
import 'package:my_show/pagemanager/trending_page_manager.dart';

import '../show_storage_helper.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget{
  final ShowStorageHelper pref;

  HomePage({@required this.pref, Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver, TickerProviderStateMixin {

  static const platform = const MethodChannel('com.jkjk.my_show');

  var _currentItem = 0;
  PageController _pageController;
  SearchPageManager _searchPageManager;
  SavedPageManager _savedPageManager;
  TrendingPageManager _trendingPageManager;
  BrowsePageManager _browsePageManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    VoidCallback voidCallback = (){
      setState(() {
      });
    };
    _pageController = PageController();
    _searchPageManager = SearchPageManager(voidCallback, widget.pref);
    _savedPageManager = SavedPageManager(voidCallback, widget.pref);
    _trendingPageManager = TrendingPageManager(voidCallback, MenuAnimator(this), widget.pref);
    _browsePageManager = BrowsePageManager(voidCallback, widget.pref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchPageManager.onDispose();
    _browsePageManager.onDispose();
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
        return _trendingPageManager.build(context);
      }
      case 1: {
        return _browsePageManager.build(context);
      }
      case 2: {
        return _searchPageManager.build(context);
      }
      case 3: {
        return _savedPageManager.build(context);
      }
      default: {
        return _settingPage();
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

  Widget _settingPage(){
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            InkWell(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Privacy',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, color: Colors.white)
                    ],
                  ),
                ),
              ),
              onTap: (){
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext _) {
                          return InfoPage();
                        }
                    )
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Text('MyShow by C H Yeung\n\nThis APP uses the TMDb API but is not endorsed or certified by TMDb.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}