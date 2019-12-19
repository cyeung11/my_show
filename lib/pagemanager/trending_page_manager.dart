import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class TrendingPageManager{

  final MenuAnimator _animator;
  final ShowStorageHelper _pref;

  Future<ShowListResponse> _movies;

  var _currentCarouselPage = 0;
  var isMenuOverlay = false;
  var _isTv = true;

  TrendingType _currentType;

  final VoidCallback _onUpdate;

  TrendingPageManager(this._onUpdate, this._animator, this._pref);

  Widget build(BuildContext context){
    if (_movies == null) {
      if (_currentType == null) {
        _currentType = _isTv ? TrendingType.TvPopular : TrendingType.MoviePopular;
      }
      _reload(context, _currentType);
    }
    return Scaffold(
      body: FutureBuilder<ShowListResponse>(
        future: _movies,
        builder: (context, snapshot) {
          return Container(
            color: Color.fromARGB(255, 80, 80, 80),
            child: Stack(
              children: _body(context, snapshot),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _body(BuildContext context, AsyncSnapshot<ShowListResponse> snapshot) {
    var bodies = List<Widget>();
    bodies.add(
      SafeArea(
          child:  Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.2, 0.9],
                        colors: [Color.fromARGB(255, 80, 80, 80), Colors.black]
                    )
                ),
                padding: EdgeInsets.only(bottom: 5),
                height: 380,
                alignment: Alignment.center,
                child: _carousel(snapshot),
              ), // the movie poster carousel
              _showDetail(snapshot),
            ],
          )),
    );
    bodies.add(Positioned(
      top: MediaQuery.of(context).padding.top, right: 0,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(_isTv ? Icons.movie : Icons.live_tv, color: Colors.white, size: 24,),
            onPressed: (){
              _isTv = !_isTv;
              _currentType = _isTv ? TrendingType.TvPopular : TrendingType.MoviePopular;
              _movies = null;
              _onUpdate();
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 24,),
            onPressed: (){
              isMenuOverlay = true;
              _onUpdate();
            },
          )
        ],
      ),
    ));
    if (isMenuOverlay) {
      bodies.add(_menuOverlay(context));
    }
    return bodies;
  }

  Widget _showDetail(AsyncSnapshot<ShowListResponse> snapshot) {
    var hasMovie = snapshot.connectionState == ConnectionState.done && snapshot?.data?.result?.isNotEmpty == true && ((snapshot?.data?.result?.length ?? -1) > _currentCarouselPage);
    if (hasMovie) {
      var currentMovie = snapshot?.data?.result[_currentCarouselPage];
      return Expanded(
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(IMAGE_PREFIX + (currentMovie.backdrop ?? '')),
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
                      _title(currentMovie),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          currentMovie.release ?? currentMovie.firstAir,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey,),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          currentMovie.overview,
                          style: TextStyle(fontSize: 16.0, color: Colors.white,),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              SizedBox(height: 35, width: 35,
                                child: IconButton(
                                  icon: Image.asset(BTN_YOUTUBE),
                                  padding: EdgeInsets.all(5),
                                  onPressed: () {
                                    searchInYoutube(currentMovie.title ?? currentMovie.name);
                                  },),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: IconButton(
                                    icon: Image.asset(BTN_GOOGLE),
                                    padding: EdgeInsets.all(5),
                                    onPressed: () {
                                      searchInGoogle(currentMovie.title ?? currentMovie.name);
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

  Widget _title(Show currentShow) {
    var titleText = Text(
      currentShow.title ?? currentShow.name,
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    if ((currentShow.voteCount ?? 0) > 0) {
      MaterialColor color;
      if (currentShow.votePoint >= 6.5)
        color = Colors.green;
      else if (currentShow.votePoint >= 4)
        color = Colors.yellow;
      else
        color = Colors.red;

      return Row(
        children: <Widget>[
          Flexible(flex: 1, fit: FlexFit.tight, child: titleText,),
          SizedBox(width: 5,),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 4.0,
            percent: currentShow.votePoint / 10,
            center: new Text(currentShow.votePoint.toString(),
              style: TextStyle(fontSize: 12.0, color: Colors.white,),
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

  Widget _carousel(AsyncSnapshot<ShowListResponse> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.data?.result?.isNotEmpty == true) {
        return Swiper(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext _) {
                          var item = snapshot.data?.result[index];
                          return item.isMovie() ? MovieDetailPage(id: item.id, pref: _pref,) : TvDetailPage(id: item.id, pref: _pref,);
                        }
                    )
                );
              },
              child: CachedNetworkImage(
                  imageUrl: IMAGE_PREFIX + (snapshot.data?.result[index].poster ?? ''),
                  fit: BoxFit.scaleDown,
                  placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                  height: 400,
                  width: 267),
            );
          },
          itemCount: snapshot.data?.result?.length ?? 0,
          viewportFraction: 0.65,
          scale: 0.7,
          index: _currentCarouselPage,
          onIndexChanged: ((index) {
            _currentCarouselPage = index;
            _onUpdate();
          }),
        );
      }
    }
    return CircularProgressIndicator();
  }

  _onMenuSelect(TrendingType newType){
    if (_currentType != newType) {
      _currentType = newType;
      _movies = null;
    }
    isMenuOverlay = false;
    _onUpdate();
  }

  Widget _menuOverlay(BuildContext context) {
    _animator._startAnimate();
    return InkWell(
      child: Container(
        color: Colors.black87,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SlideTransition(
              position: _animator._animation3,
              child: IconButton(
                icon: Icon(Icons.clear, size: 24, color: Colors.white,),
                onPressed: () => _onMenuSelect(_currentType),
              ),
            ),
            SlideTransition(
              position: _animator._animation3,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(_isTv ? TrendingType.TvPopular : TrendingType.MoviePopular),
                icon: Icon(Icons.star, size: 20, color: (_currentType == TrendingType.TvPopular || _currentType == TrendingType.MoviePopular) ? Colors.orangeAccent : Colors.white),
                label: Text("Popular",
                  style: TextStyle(color: (_currentType == TrendingType.TvPopular || _currentType == TrendingType.MoviePopular) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator._animation2,
              child: FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(_isTv ? TrendingType.TvLatest : TrendingType.MovieLatest),
                icon: Icon(Icons.new_releases, size: 20, color: (_currentType == TrendingType.TvLatest || _currentType == TrendingType.MovieLatest) ? Colors.orangeAccent : Colors.white),
                label: Text("Latest",
                  style: TextStyle(color: (_currentType == TrendingType.TvLatest || _currentType == TrendingType.MovieLatest) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator._animation2,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(_isTv ? TrendingType.TvTopRate : TrendingType.TvTopRate),
                icon: Icon(Icons.thumb_up, size: 20, color: (_currentType == TrendingType.TvTopRate || _currentType == TrendingType.MovieTopRate) ? Colors.orangeAccent : Colors.white),
                label: Text("Top Rated",
                  style: TextStyle(color: (_currentType == TrendingType.TvTopRate || _currentType == TrendingType.MovieTopRate) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator._animation1,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(_isTv ? TrendingType.TvOnAir : TrendingType.MovieUpcoming),
                icon: Icon(_isTv ?Icons.play_arrow : Icons.calendar_today, size: 20,
                    color: (_currentType == TrendingType.TvOnAir || _currentType == TrendingType.MovieUpcoming) ? Colors.orangeAccent : Colors.white),
                label: Text(_isTv ? 'On the Air' : 'Upcoming' ,
                  style: TextStyle(color: (_currentType == TrendingType.TvOnAir || _currentType == TrendingType.MovieUpcoming) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: (){
        _onMenuSelect(_currentType);
      },
    );

  }

  _showRetrySnackbar(BuildContext context, TrendingType type) {
    final snackBar = SnackBar(content: Text('Fail to load :('),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () {
          _reload(context, type);
          _onUpdate();
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _reload(BuildContext context, TrendingType type) {
    _currentCarouselPage = 0;
    _movies = getShows(getNetworkPath(type), null, 1).then((data) {
      if (data == null) {
        _showRetrySnackbar(context, type);
      }
      return data;
    });
  }

  String getNetworkPath(TrendingType type){
    switch (type){
      case TrendingType.TvLatest: {
        return GET_TV_LATEST;
      }
      case TrendingType.TvTopRate: {
        return GET_TV_TOP_RATE;
      }
      case TrendingType.TvOnAir: {
        return GET_TV_ON_AIR;
      }
      case TrendingType.MovieLatest: {
        return GET_MOVIE_LATEST;
      }
      case TrendingType.MovieTopRate: {
        return GET_MOVIE_TOP_RATE;
      }
      case TrendingType.MovieUpcoming: {
        return GET_MOVIE_UPCOMING;
      }
      case TrendingType.MoviePopular: {
        return GET_MOVIE_POPULAR;
      }
      default: {
        return GET_TV_POPULAR;
      }
    }
  }
}

searchInYoutube(String query) async {
  query = query.replaceAll(" ", "+");
  if (Platform.isIOS &&
      await canLaunch(SEARCH_YOUTUBE_IOS_APP_PREFIX + query)) {
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

enum TrendingType{
  TvLatest, TvPopular, TvTopRate, TvOnAir, MovieLatest, MoviePopular, MovieTopRate, MovieUpcoming
}

class MenuAnimator{
  Animation<Offset> _animation1, _animation2, _animation3;
  AnimationController _animationController1, _animationController2, _animationController3;

  MenuAnimator(TickerProviderStateMixin mixin){
    _animationController1 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 350));
    _animationController2 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 250));
    _animationController3 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 200));
    _animation1 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController1);
    _animation2 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController2);
    _animation3 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController3);
  }

  _startAnimate() {
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

  _stopAnimate() {
    _animationController1.reset();
    _animationController2.reset();
    _animationController3.reset();
  }

}