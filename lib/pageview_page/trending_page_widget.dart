import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';
import 'package:my_show/pageview_page/page_manager/trending_page_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../asset_path.dart';

class TrendingPageWidget extends StatefulWidget{

  final TrendingPageManager _pageManager;

  TrendingPageWidget(this._pageManager, {Key key}): super(key: key);

  @override
  State createState()  => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPageWidget> with TickerProviderStateMixin {

  MenuAnimator _animator;

  @override
  void initState() {
    super.initState();
    _animator = MenuAnimator(this);
  }

  @override
  Widget build(BuildContext context) {
    if (widget._pageManager.movies == null) {
      if (widget._pageManager.currentType == null) {
        widget._pageManager.currentType = widget._pageManager.isTv ? TrendingType.TvPopular : TrendingType.MoviePopular;
      }
      _reload(context, widget._pageManager.currentType);
    }
    return Scaffold(
      body: FutureBuilder<ShowListResponse>(
        future: widget._pageManager.movies,
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
            icon: Icon(widget._pageManager.isTv ? Icons.movie : Icons.live_tv, color: Colors.white, size: 24,),
            onPressed: (){
              setState(() {
                widget._pageManager.isTv = !widget._pageManager.isTv;
                widget._pageManager.currentType = widget._pageManager.isTv ? TrendingType.TvPopular : TrendingType.MoviePopular;
                widget._pageManager.movies = null;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 24,),
            onPressed: (){
              setState(() {
                widget._pageManager.isMenuOverlay = true;
              });
            },
          )
        ],
      ),
    ));
    if (widget._pageManager.isMenuOverlay) {
      bodies.add(_menuOverlay(context));
    }
    return bodies;
  }

  Widget _showDetail(AsyncSnapshot<ShowListResponse> snapshot) {
    var hasMovie = snapshot.connectionState == ConnectionState.done && snapshot?.data?.result?.isNotEmpty == true && ((snapshot?.data?.result?.length ?? -1) > widget._pageManager.currentCarouselPage);
    if (hasMovie) {
      var currentMovie = snapshot?.data?.result[widget._pageManager.currentCarouselPage];
      return Expanded(
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(BACKDROP_IMAGE_PREFIX + (currentMovie.backdrop ?? '')),
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
                                    Details.searchInYoutube(currentMovie.title ?? currentMovie.name);
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
                                      Details.searchInGoogle(currentMovie.title ?? currentMovie.name);
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
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext _) {
                          var item = snapshot.data?.result[index];
                          return item.isMovie() ? MovieDetailPage(item.id) : TvDetailPage(item.id);
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
          index: widget._pageManager.currentCarouselPage,
          onIndexChanged: ((index) {
            setState(() {
              widget._pageManager.currentCarouselPage = index;
            });
          }),
        );
      }
    }
    return CircularProgressIndicator();
  }

  _onMenuSelect(TrendingType newType){
    if (widget._pageManager.currentType != newType) {
      widget._pageManager.currentType = newType;
      widget._pageManager.movies = null;
    }
    setState(() {
      widget._pageManager.isMenuOverlay = false;
    });
  }

  Widget _menuOverlay(BuildContext context) {
    _animator.startAnimate();
    return GestureDetector(
      child: Container(
        color: Colors.black87,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SlideTransition(
              position: _animator.animation3,
              child: IconButton(
                icon: Icon(Icons.clear, size: 24, color: Colors.white,),
                onPressed: () => _onMenuSelect(widget._pageManager.currentType),
              ),
            ),
            SlideTransition(
              position: _animator.animation3,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(widget._pageManager.isTv ? TrendingType.TvPopular : TrendingType.MoviePopular),
                icon: Icon(Icons.star, size: 20, color: (widget._pageManager.currentType == TrendingType.TvPopular || widget._pageManager.currentType == TrendingType.MoviePopular) ? Colors.orangeAccent : Colors.white),
                label: Text('Popular',
                  style: TextStyle(color: (widget._pageManager.currentType == TrendingType.TvPopular || widget._pageManager.currentType == TrendingType.MoviePopular) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator.animation2,
              child: FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(widget._pageManager.isTv ? TrendingType.TvToday : TrendingType.MoviePlaying),
                icon: Icon(Icons.new_releases, size: 20, color: (widget._pageManager.currentType == TrendingType.TvToday || widget._pageManager.currentType == TrendingType.MoviePlaying) ? Colors.orangeAccent : Colors.white),
                label: Text(widget._pageManager.isTv ? 'Air Today' :'On Theatre',
                  style: TextStyle(color: (widget._pageManager.currentType == TrendingType.TvToday || widget._pageManager.currentType == TrendingType.MoviePlaying) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator.animation2,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(widget._pageManager.isTv ? TrendingType.TvTopRate : TrendingType.TvTopRate),
                icon: Icon(Icons.thumb_up, size: 20, color: (widget._pageManager.currentType == TrendingType.TvTopRate || widget._pageManager.currentType == TrendingType.MovieTopRate) ? Colors.orangeAccent : Colors.white),
                label: Text("Top Rated",
                  style: TextStyle(color: (widget._pageManager.currentType == TrendingType.TvTopRate || widget._pageManager.currentType == TrendingType.MovieTopRate) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
            SlideTransition(
              position: _animator.animation1,
              child:
              FlatButton.icon(
                padding: EdgeInsets.all(10),
                onPressed: () => _onMenuSelect(widget._pageManager.isTv ? TrendingType.TvOnAir : TrendingType.MovieUpcoming),
                icon: Icon(widget._pageManager.isTv ?Icons.play_arrow : Icons.calendar_today, size: 20,
                    color: (widget._pageManager.currentType == TrendingType.TvOnAir || widget._pageManager.currentType == TrendingType.MovieUpcoming) ? Colors.orangeAccent : Colors.white),
                label: Text(widget._pageManager.isTv ? 'On the Air' : 'Upcoming' ,
                  style: TextStyle(color: (widget._pageManager.currentType == TrendingType.TvOnAir || widget._pageManager.currentType == TrendingType.MovieUpcoming) ? Colors.orangeAccent : Colors.white, fontSize: 20,),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: (){
        _onMenuSelect(widget._pageManager.currentType);
      },
    );

  }

  _showRetrySnackbar(BuildContext context, TrendingType type) {
    final snackBar = SnackBar(content: Text('Fail to load :('),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () {
          setState(() {
            _reload(context, type);
          });
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _reload(BuildContext context, TrendingType type) {
    widget._pageManager.currentCarouselPage = 0;
    widget._pageManager.movies = getShows(getNetworkPath(type), null, 1).then((data) {
      if (data == null) {
        _showRetrySnackbar(context, type);
      }
      return data;
    });
  }

  String getNetworkPath(TrendingType type){
    switch (type){
      case TrendingType.TvToday: {
        return GET_TV_TODAY;
      }
      case TrendingType.TvTopRate: {
        return GET_TV_TOP_RATE;
      }
      case TrendingType.TvOnAir: {
        return GET_TV_ON_AIR;
      }
      case TrendingType.MoviePlaying: {
        return GET_MOVIE_PLAYING;
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