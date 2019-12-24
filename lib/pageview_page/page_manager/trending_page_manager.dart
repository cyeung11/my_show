import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_show/network/response/movie_list_response.dart';

class TrendingPageManager{

  Future<ShowListResponse> movies;

  var currentCarouselPage = 0;
  var isMenuOverlay = false;
  var isTv = true;

  TrendingType currentType;
}

enum TrendingType{
  TvLatest, TvPopular, TvTopRate, TvOnAir, MovieLatest, MoviePopular, MovieTopRate, MovieUpcoming
}

class MenuAnimator{
  Animation<Offset> animation1, animation2, animation3;
  AnimationController _animationController1, _animationController2, _animationController3;

  MenuAnimator(TickerProviderStateMixin mixin){
    _animationController1 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 350));
    _animationController2 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 250));
    _animationController3 = AnimationController(vsync: mixin, duration: Duration(milliseconds: 200));
    animation1 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController1);
    animation2 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController2);
    animation3 = Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(_animationController3);
  }

  startAnimate() {
    stopAnimate();
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

  stopAnimate() {
    _animationController1.reset();
    _animationController2.reset();
    _animationController3.reset();
  }

}