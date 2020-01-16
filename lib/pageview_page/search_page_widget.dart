import 'package:flutter/material.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/pageview_page/page_manager/search_page_manager.dart';
import 'package:my_show/pageview_page/show_widget_builder.dart';

class SearchPageWidget extends StatefulWidget{

  final SearchPageManager _pageManager;

  SearchPageWidget(this._pageManager, {Key key}): super(key: key);

  @override
  State createState()  => _SearchPageState();
}

class _SearchPageState extends State<SearchPageWidget> {

  ScrollController _scrollController;
  TextEditingController _textEditingController;
  FocusNode _focus;

  @override
  void initState() {
    super.initState();
    resetScrollController();
    _textEditingController = TextEditingController();
    _focus = FocusNode();
    _focus.addListener(() =>
      setState(() {})
    );
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
            child: Column(
              children: <Widget>[
                _searchTextBox(widget._pageManager.isTv),
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
    _textEditingController.dispose();
    _focus.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && widget._pageManager.query?.isNotEmpty == true) {
      if (widget._pageManager.currentPage + 1 <= widget._pageManager.totalPage) {
        setState(() {
          widget._pageManager.currentPage++;
          widget._pageManager.isLoading = true;

          getShows(widget._pageManager.isTv ? SEARCH_TV : SEARCH_MOVIE, widget._pageManager.query, widget._pageManager.currentPage, searchingMovie: !widget._pageManager.isTv).then((data){
            onDataReturn(data);
          });
        });
      }
    }
  }


  Widget _searchTextBox(bool isTv){
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 2, top: 5, bottom: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 3),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search, size: 20, color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: _focus,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search ${widget._pageManager.isTv ? 'TV' : 'Movie'}',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: (query){
                        final wasEmpty = widget._pageManager.query?.isEmpty != false;
                        widget._pageManager.query = query.trim();
                        final isEmpty = widget._pageManager.query?.isEmpty != false;
                        if (wasEmpty != isEmpty) {
                          setState(() {});
                        }
                      },
                      maxLines: 1,
                      onSubmitted: (query){
                        if (query?.isNotEmpty == true) {
                          setState(() {
                            widget._pageManager.query = query.trim();
                            widget._pageManager.resetLoad();
                            resetScrollController();
                          });
                          getShows(!isTv ? SEARCH_MOVIE : SEARCH_TV, widget._pageManager.query, widget._pageManager.currentPage, searchingMovie: !isTv).then((data){
                            onDataReturn(data);
                          });
                        }
                        _focus.unfocus();
                      },
                    ),
                  ),
                  if (_focus.hasFocus && widget._pageManager.query?.isNotEmpty == true)
                    IconButton(icon: Icon(
                      Icons.cancel, size: 16, color: Colors.grey,
                    ), onPressed: (){
                      setState(() {
                        _textEditingController.text = '';
                        widget._pageManager.query = '';
                      });
                    }),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          icon: Icon( !isTv ? Icons.live_tv : Icons.movie, color: Colors.white,),
          onPressed: (){
            if (widget._pageManager.query?.isNotEmpty == true) {
              setState(() {
                widget._pageManager.resetLoad();
                resetScrollController();
                widget._pageManager.isTv = !widget._pageManager.isTv;
              });

              getShows(isTv ? SEARCH_MOVIE : SEARCH_TV, widget._pageManager.query, widget._pageManager.currentPage, searchingMovie: !isTv).then((data){
                onDataReturn(data);
              });
            } else {
              setState(() {
                widget._pageManager.isTv = !widget._pageManager.isTv;
              });
            }
          },
        ),
        SizedBox(width: 12,)
      ],
    );
  }

  Widget _buildResultList(BuildContext context){
    if (widget._pageManager.shows.isEmpty) {
      if (widget._pageManager.isLoading) {
        return Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator());
      } else {
        return Container();
      }
    }

    var entries = ListTile.divideTiles(
        color: Colors.white30,
        context: context,
        tiles: widget._pageManager.shows.map((Show currentMovie){
          return ShowWidgetBuilder.buildShowEntry(context, currentMovie);
        })
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

  onDataReturn(ShowListResponse response){
    setState(() {
      if (response != null) {
        widget._pageManager.totalPage = response.totalPage ?? 0;
        if (response.result != null) {
          widget._pageManager.shows.addAll(response.result);
        }
        widget._pageManager.isLoading = false;
      }
    });
  }

}