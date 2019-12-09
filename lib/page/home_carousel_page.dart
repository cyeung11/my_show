import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_show/asset_path.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/info_page.dart';
import 'package:my_show/page/saved_page.dart';
import 'package:my_show/page/search_page.dart';
import 'package:my_show/show_storage_helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/network_call.dart';
import '../network/response/movie_list_response.dart';
import 'movie_details_page.dart';

class CarouselPage extends StatefulWidget {

  final ShowStorageHelper pref;

  CarouselPage({@required this.pref, Key key}): super(key: key);

  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> with TickerProviderStateMixin{

  Future<MovieListResponse> movies;

  var _currentPage = 0;

  var _isMenuOverlay = false;

  String _dropdownValue = 'UPCOMING';

  Animation<Offset> _animation1, _animation2, _animation3;
  AnimationController _animationController1, _animationController2, _animationController3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black54, //or set color with: Color(0xFF0000FF)
      statusBarIconBrightness: Brightness.light,
    ));

    _animationController1 = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _animationController2 = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animationController3 = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation1 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController1);
    _animation2 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController2);
    _animation3 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController3);
  }

  @override
  Widget build(BuildContext context) {
    if (movies == null) {
      _reload(context);
    }

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
                children: buildBody(context, snapshot),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildBody(BuildContext context, AsyncSnapshot<MovieListResponse> snapshot){
    var bodies = List<Widget>();
    bodies.add(
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
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
              child: buildCarousel(snapshot),
            ), // the movie poster carousel
            buildDetails(snapshot),
            buildActionMenuBar(context),
          ],
        ));

    if (_isMenuOverlay) {
      bodies.add(buildMenuOverlay());
    }
    return bodies;
  }

  Widget buildActionMenuBar(BuildContext context){
    return Container(
      color: Colors.black,
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
                    _reload(context);
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
    );
  }

  Widget buildMenuOverlay(){
    if (_isMenuOverlay) {
      _startAnimate();
      return Container(
        color: Colors.black87,
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            SlideTransition(
              position: _animation3,
              child:   FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext _) {
                            return SearchPage(pref: widget.pref,);
                          }
                      )
                  );
                },
                icon: Icon(Icons.search, size: 24, color: Colors.white),
                label:  Text("Search",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animation2,
              child:  FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext _) {
                            return SavedPage(pref: widget.pref,);
                          }
                      )
                  );
                },
                label:  Text("Saved",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
                icon: Icon(Icons.favorite_border, size: 24, color: Colors.white),
              ),
            ),
            SlideTransition(
              position: _animation1,
              child:  FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext _) {
                            return InfoPage();
                          }
                      )
                  );
                },
                icon: Icon(Icons.info_outline, size: 24, color: Colors.white),
                label:  Text("About",
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear, size: 30, color: Colors.white,),
              onPressed: (){
                setState(() {
                  _isMenuOverlay = false;
                });
              },
            ),
          ],
        ),
      );
    }
  }

  _startAnimate(){
    _stopAnimate();
    if (_animationController1.status == AnimationStatus.dismissed) {
      _animationController1.forward();
    }
    if (_animationController2.status == AnimationStatus.dismissed) {
      _animationController2.forward();
    }
    if (_animationController3.status == AnimationStatus.dismissed) {
      _animationController3.forward();
    }
  }

  _stopAnimate(){
    _animationController1.reset();
    _animationController2.reset();
    _animationController3.reset();
  }

  Widget buildDetails(AsyncSnapshot<MovieListResponse> snapshot){
    var hasMovie = snapshot.connectionState == ConnectionState.done && snapshot?.data?.result?.isNotEmpty == true && (snapshot?.data?.result.length > _currentPage);
    if (hasMovie) {
      var currentMovie = snapshot?.data?.result[_currentPage];
      return Expanded(
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(IMAGE_PREFIX + snapshot?.data?.result[_currentPage].backdrop),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                  child: ListView(
                    padding: EdgeInsets.all(12),
                    children: <Widget>[
                      buildTitle(currentMovie),
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
                                child:  IconButton(icon: Image.asset(BTN_YOUTUBE),
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
                                  child:  IconButton(icon: Image.asset(BTN_GOOGLE),
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
      return Expanded(
        child: Container(
          color: Colors.black,
        ),
      );
    }
  }

  Widget buildTitle(Show currentMovie){
    var titleText = Text(
      currentMovie.title,
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    if ((currentMovie.voteCount ?? 0) > 0) {
      MaterialColor color;
      if (currentMovie.votePoint >= 6.5)
        color = Colors.green;
      else if (currentMovie.votePoint >= 4)
        color = Colors.yellow;
      else
        color = Colors.red;

      return Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: titleText,
          ),
          SizedBox(
            width: 5,
          ),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 4.0,
            percent: currentMovie.votePoint / 10,
            center: new Text(
              currentMovie.votePoint.toString(),
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.grey,
            progressColor: color,
          )
        ],
      );
    } else {
      return titleText;
    }
  }

  Widget buildCarousel(AsyncSnapshot<MovieListResponse> snapshot){
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.data?.result?.isNotEmpty == true) {
        return Swiper(
          itemBuilder: (context, index){
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext _) {
                          return MovieDetailPage(id: snapshot.data?.result[index].id);
                        }
                    )
                );
              },
              child: CachedNetworkImage(
                  imageUrl: IMAGE_PREFIX + snapshot.data?.result[index].poster,
                  fit: BoxFit.scaleDown,
                  placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                  height: 400, width: 267),
            );
          },
          itemCount: snapshot.data?.result.length,
          viewportFraction: 0.65,
          scale: 0.7,
          onIndexChanged: ((index) {
            setState(() {
              _currentPage = index;
            });
          }),
        );
      }
    }
  }

  _showRetrySnackbar(BuildContext context){
    final snackBar = SnackBar(content: Text('Fail to load :('),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: (){
          setState(() {
            _reload(context);
          });
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _reload(BuildContext context){
    if (_dropdownValue == "UPCOMING") {
      movies = getShows(GET_UPCOMING, null, 1).then((data) {
        if (data == null) {
          _showRetrySnackbar(context);
        }
        return data;
      });
    } else {
      movies = getShows(GET_POPULAR, null, 1).then((data) {
        if (data == null) {
          _showRetrySnackbar(context);
        }
        return data;
      });
    }
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