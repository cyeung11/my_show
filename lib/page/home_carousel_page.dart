import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_show/model/movie.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/network_call.dart';
import '../network/response/movie_list_response.dart';

class CarouselPage extends StatefulWidget {

  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage>  with TickerProviderStateMixin{

  Future<MovieListResponse> movies;

  var _currentPage = 0;

  var _isMenuOverlay = false;

  String _dropdownValue = 'UPCOMING';

  Animation<Offset> animation1, animation2, animation3;
  AnimationController animationController1, animationController2, animationController3;

  @override
  void initState() {
    super.initState();
    movies = getUpcoming(1);
    animationController1 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animationController2 = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    animationController3 = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    animation1 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(animationController1);
    animation2 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(animationController2);
    animation3 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(animationController3);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black54, //or set color with: Color(0xFF0000FF)
      statusBarIconBrightness: Brightness.light,
    ));
    return WillPopScope(
      onWillPop: () async {
        if (_isMenuOverlay){
          setState(() {
            _isMenuOverlay = false;
          });
          return Future.value(false);
        } else return Future.value(true);
      },
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<MovieListResponse>(
            future: movies,
            builder: (context, snapshot){
              return Stack(
                children: buildBody(snapshot),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildBody(AsyncSnapshot<MovieListResponse> snapshot){
    var bodies = List<Widget>();
    bodies.add(
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              color: Colors.black54,
              child:  Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: _dropdownValue,
                        underline: SizedBox(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            if (_dropdownValue != newValue) {
                              _dropdownValue = newValue;
                              if (newValue == "UPCOMING") {
                                movies = getUpcoming(1);
                              } else {
                                movies = getPopular(1);
                              }
                            }
                          });
                        },
                        items: <String>['UPCOMING', 'POPULAR']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  Spacer(
                    flex: 1,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: (){
                      setState(() {
                        _isMenuOverlay = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 0.9],
                      colors: [
                        Colors.black54,
                        Colors.black
                      ]
                  )
              ),
              padding: EdgeInsets.only(bottom: 5),
              height: 380,
              alignment: Alignment.center,
              child: buildCarousel(snapshot.data?.result),
            ),
            buildDetails(snapshot?.data?.result)
          ],
        ));

    if (_isMenuOverlay) {
      bodies.add(buildMenu());
    }
    return bodies;
  }

  Widget buildMenu(){
    if (_isMenuOverlay) {
      _startAnimate();
      return Container(
        color: Colors.black87,
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.clear, size: 30, color: Colors.white,),
              onPressed: (){
                setState(() {
                  _isMenuOverlay = false;
                });
              },
            ),
            SlideTransition(
              position: animation3,
              child:   FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){

                },
                icon: Icon(Icons.search, size: 24, color: Colors.white),
                label:  Text("Search",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: animation2,
              child:  FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){

                },
                label:  Text("Saved",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
                icon: Icon(Icons.favorite_border, size: 24, color: Colors.white),
              ),
            ),
            SlideTransition(
              position: animation1,
              child:  FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){

                },
                icon: Icon(Icons.info_outline, size: 24, color: Colors.white),
                label:  Text("About",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  _startAnimate(){
    _stopAnimate();
    if (animationController1.status == AnimationStatus.dismissed) {
      animationController1.forward();
    }
    if (animationController2.status == AnimationStatus.dismissed) {
      animationController2.forward();
    }
    if (animationController3.status == AnimationStatus.dismissed) {
      animationController3.forward();
    }
  }

  _stopAnimate(){
    animationController1.reset();
    animationController2.reset();
    animationController3.reset();
  }

  Widget buildDetails(List<Movie> data) {
    var hasMovie =  data?.isNotEmpty == true && (data.length > _currentPage);
    if (hasMovie) {
      var currentMovie = data[_currentPage];
      return Expanded(
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(IMAGE_PREFIX + data[_currentPage].backdrop),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: ListView(
                    padding: EdgeInsets.all(12),
                    children: <Widget>[
                      Text(
                        currentMovie.title,
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child:  Text(
                          currentMovie.release,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child:  Text(
                          currentMovie.overview,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 35,
                                width: 35,
                                child:  IconButton(icon: Image.asset("images/btn_youtube.png"),
                                  padding: EdgeInsets.all(5),
                                  onPressed: (){
                                    searchInYoutube(currentMovie.title);
                                  },),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 6),
                                child:  SizedBox(
                                  height: 35,
                                  width: 35,
                                  child:  IconButton(icon: Image.asset("images/btn_google.png"),
                                    padding: EdgeInsets.all(5),
                                    onPressed: (){
                                      searchInGoogle(currentMovie.title);
                                    },),
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
      );
    } else {
      return Container(
        color: Colors.black,
      );
    }
  }

  Widget buildCarousel(List<Movie> data){
    if (data?.isNotEmpty == true) {
      return Swiper(
        itemBuilder: (context, index){
          return Image.network(IMAGE_PREFIX + data[index].poster, fit: BoxFit.scaleDown, height: 400, width: 267);
        },
        itemCount: data.length,
        viewportFraction: 0.65,
        scale: 0.7,
        onIndexChanged: ((index) {
          setState(() {
            _currentPage = index;
          });
        }),
      );
    }
    return CircularProgressIndicator();
  }

  searchInYoutube(String query) async {
    query = query.replaceAll(" ", "+");
    if (Platform.isIOS && await canLaunch(SEARCH_YOUTUBE_IOS_APP_PREFIX + query)) {
      await launch(SEARCH_YOUTUBE_IOS_APP_PREFIX + query);
    } else if (await canLaunch(SEARCH_YOUTUBE_WEB_PREFIX + query)) {
      await launch(SEARCH_YOUTUBE_WEB_PREFIX + query);
    }
  }

  searchInGoogle(String query) async {
    query = query.replaceAll(" ", "+");
    if (await canLaunch(SEARCH_GOOGLE_PREFIX + query)) {
      await launch(SEARCH_GOOGLE_PREFIX + query);
    }
  }
}