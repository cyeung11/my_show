import 'package:flutter/material.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/model/sort.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/pageview_page/page_manager/browse_page_manager.dart';
import 'package:my_show/pageview_page/show_widget_builder.dart';
import 'package:my_show/widget/select_dialog.dart';
import 'package:numberpicker/numberpicker.dart';

import '../storage/pref_helper.dart';

class BrowsePageWidget extends StatefulWidget{

  final BrowsePageManager _pageManager;

  BrowsePageWidget(this._pageManager, {Key key}): super(key: key);

  @override
  State createState()  => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePageWidget> {

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    resetScrollController();

    if (widget._pageManager.shows.isEmpty && !widget._pageManager.isLoading) {
      widget._pageManager.isLoading = true;
      discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
        onDataReturn(data);
      });
    }
  }

  resetScrollController(){
    _scrollController = ScrollController(initialScrollOffset: widget._pageManager.scrollOffsetToRestore);
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: <Widget>[
                _topRow(context),
                _buildResultList(context)
              ],
            )
        ),
      ),
    );
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (widget._pageManager.shows.isNotEmpty) {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (widget._pageManager.currentPage + 1 <= widget._pageManager.totalPage) {
          setState(() {
            widget._pageManager.currentPage++;
            widget._pageManager.isLoading = true;

            discover(widget._pageManager.isTv, widget._pageManager.year,
                widget._pageManager.vote, widget._pageManager.genre,
                widget._pageManager.sort, widget._pageManager.currentPage).then((
                data) {
              onDataReturn(data);
            });
          });
        }
      }
    }
  }

  Widget _buildResultList(BuildContext context){
    if (widget._pageManager.shows.isEmpty) {
      return Padding(padding: EdgeInsets.all(10),
          child: widget._pageManager.isLoading
              ? CircularProgressIndicator()
              : IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 50,),
            onPressed: (){
              widget._pageManager.isLoading = true;
              discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
                onDataReturn(data);
              });
            },
          )
      );
    }

    var entries = ListTile.divideTiles(
        color: Colors.white30,
        context: context,
        tiles: widget._pageManager.shows.map((Show currentMovie){
          return ShowWidgetBuilder.buildShowEntry(context ,currentMovie);
        }
        )
    ).toList();

    if (widget._pageManager.isLoading) {
      entries.add(SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }

    return Expanded(
      child: NotificationListener(
        child: ListView(
            controller: _scrollController,
            children: entries
        ),
        onNotification: (notification){
          if (notification is ScrollNotification) {
            widget._pageManager.scrollOffsetToRestore = notification.metrics.pixels;
          }
          return false;
        },
      ),
    );
  }

  Widget _topRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
              height: 30,
              child: _filterBox(context),
            )
        ),
        SizedBox(width: 5,),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          icon: Icon(!widget._pageManager.isTv ? Icons.live_tv : Icons.movie, color: Colors.white,),
          onPressed: (){
            setState(() {
              widget._pageManager.resetLoad();
              resetScrollController();
              widget._pageManager.isTv = !widget._pageManager.isTv;
              widget._pageManager.year = null;
              widget._pageManager.sort = SortType.popularityDesc();
              widget._pageManager.genre = null;
              widget._pageManager.vote = null;
            });

            discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
              onDataReturn(data);
            });
          },
        )
      ],
    );
  }

  Widget _filterBox(BuildContext context){
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        SizedBox(width: 12,),
        _filterGenreBox(context),
        SizedBox(width: 5,),
        _filterYearBox(context),
        SizedBox(width: 5,),
        _filterScoreBox(context),
        SizedBox(width: 5,),
        _sortBox(context),
      ],
    );
  }

  Widget _filterYearBox(BuildContext context) {
    var text = InkWell(
      child: Center(child: Padding(
        padding: EdgeInsets.only(left: 10, top: 7.5, bottom: 7.5, right: widget._pageManager.year == null ? 10 : 2.5),
        child: Text(widget._pageManager.year != null ? 'Year: ${widget._pageManager.year?.toString()}+' : 'Year: All'),
      ),),
      onTap: (){
        showDialog<int>(context: context,builder: (context){
          return  NumberPickerDialog.integer(
            minValue: 1970,
            maxValue:  DateTime.now().year,
            initialIntegerValue: widget._pageManager.year ??  DateTime.now().year,
            confirmWidget: Text('OK', style: TextStyle(color: Colors.blue),),
          );
        }).then((year){
          if (year != null && year != widget._pageManager.year) {
            setState(() {
              widget._pageManager.year = year;
              widget._pageManager.resetLoad();
              resetScrollController();
            });

            discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
              onDataReturn(data);
            });
          }
        });
      },
    );

    Widget containerChild;
    if (widget._pageManager.year == null) {
      containerChild = text;
    } else {
      containerChild = Row(children: <Widget>[
        text,
        SizedBox(width: 30, height: 30,
          child:
          IconButton(icon: Icon(Icons.clear, size: 15,),
            onPressed: (){
              if (widget._pageManager.year != null) {
                setState(() {
                  widget._pageManager.year = null;
                  widget._pageManager.resetLoad();
                  resetScrollController();
                });

                discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
                  onDataReturn(data);
                });
              }
            },
          ),
        ),
      ]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: containerChild,
    );
  }

  Widget _filterScoreBox(BuildContext context) {
    var text = InkWell(
      child: Center(child: Padding(
        padding: EdgeInsets.only(left: 10, top: 7.5, bottom: 7.5, right: widget._pageManager.vote == null ? 10 : 2.5),
        child: Text('Score: ${widget._pageManager.vote != null ? widget._pageManager.vote.toString() + '+' : 'All'}'),
      ),),
      onTap: (){
        showDialog<double>(context: context,builder: (context){
          return  NumberPickerDialog.decimal(
            minValue: 0,
            maxValue:  10,
            initialDoubleValue: widget._pageManager.vote ?? 5.0,
            confirmWidget: Text('OK', style: TextStyle(color: Colors.blue),),
          );
        }).then((vote){
          if (vote != null && vote != widget._pageManager.vote) {
            setState(() {
              widget._pageManager.vote = vote;
              widget._pageManager.resetLoad();
              resetScrollController();
            });

            discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
              onDataReturn(data);
            });
          }
        });
      },
    );

    Widget containerChild;
    if (widget._pageManager.vote == null) {
      containerChild = text;
    } else {
      containerChild = Row(children: <Widget>[
        text,
        SizedBox(width: 30, height: 30,
          child:
          IconButton(icon: Icon(Icons.clear, size: 15,),
            onPressed: (){
              if (widget._pageManager.vote != null) {
                setState(() {
                  widget._pageManager.vote = null;
                  widget._pageManager.resetLoad();
                  resetScrollController();
                });

                discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
                  onDataReturn(data);
                });
              }
            },
          ),
        )
      ]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: containerChild,
    );
  }

  Widget _filterGenreBox(BuildContext context) {
    var text = InkWell(
      child: Center(child: Padding(
          padding: EdgeInsets.only(left: 10, top: 7.5, bottom: 7.5, right: widget._pageManager.genre == null ? 10 : 2.5),
          child: Text('Genre: ${widget._pageManager.genre?.name ?? 'All'}')
      ),),
      onTap: (){
        showDialog<Genre>(context: context,
            barrierDismissible: true,
            builder: (context){
              return SelectDialog<Genre>(
                selectables: widget._pageManager.isTv ? PrefHelper.instance.tvGenres : PrefHelper.instance.movieGenres,
                currentSelect: widget._pageManager.genre,
              );
            }
        ).then((genre){
          if (genre != null && genre != widget._pageManager.genre) {
            setState(() {
              widget._pageManager.genre = genre;
              widget._pageManager.resetLoad();
              resetScrollController();
            });

            discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
              onDataReturn(data);
            });
          }
        });
      },
    );

    Widget containerChild;
    if (widget._pageManager.genre == null) {
      containerChild = text;
    } else {
      containerChild = Row(children: <Widget>[
        text,
        SizedBox(width: 30, height: 30,
          child:
          IconButton(icon: Icon(Icons.clear, size: 15,),
            onPressed: (){
              if (widget._pageManager.genre != null) {
                setState(() {
                  widget._pageManager.genre = null;
                  widget._pageManager.resetLoad();
                  resetScrollController();
                });

                discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
                  onDataReturn(data);
                });
              }
            },
          ),
        ),
      ]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: containerChild,
    );
  }

  Widget _sortBox(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: InkWell(
          child:  Center(
            child: Text('Sort: ${widget._pageManager.sort.getString()}'),
          ),
          onTap: (){
            showDialog<SortType>(context: context,
                barrierDismissible: true,
                builder: (context){
                  return SelectDialog<SortType>(
                    selectables: widget._pageManager.isTv ? SortType.allTv() : SortType.allMovie(),
                    currentSelect: widget._pageManager.sort,
                  );
                }
            ).then((sort){
              if (sort != null && sort != widget._pageManager.sort) {
                setState(() {
                  widget._pageManager.sort = sort;
                  widget._pageManager.resetLoad();
                  resetScrollController();
                });

                discover(widget._pageManager.isTv, widget._pageManager.year, widget._pageManager.vote, widget._pageManager.genre, widget._pageManager.sort, widget._pageManager.currentPage).then((data){
                  onDataReturn(data);
                });
              }
            });
          },
        )
    );
  }

  onDataReturn(ShowListResponse response){
    if (response != null) {
      widget._pageManager.totalPage = response.totalPage ?? 0;
      if (response.result != null) {
        widget._pageManager.shows.addAll(response.result);
      }
    }
    setState(() {
      widget._pageManager.isLoading = false;
    });
  }
}