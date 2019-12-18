import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class SearchPageManager{

  String _query;

  bool _isLoading = false;
  int _currentPage = 1;

  bool _isTv = true;

  final VoidCallback _onUpdate;

  final ShowStorageHelper _pref;
  final ScrollController _scrollController = ScrollController();

  final List<Show> _shows = List<Show>();
  int _totalPage;

  SearchPageManager(this._onUpdate, this._pref){
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _query?.isNotEmpty == true) {
      if (_currentPage + 1 <= _totalPage) {
        _currentPage++;
        _isLoading = true;

        _onUpdate();

        getShows(_isTv ? SEARCH_TV : SEARCH_MOVIE, _query, _currentPage).then((data){
          onDataReturn(data);
        });
      }
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
            child: Column(
              children: <Widget>[
                _searchTextBox(_isTv),
                buildResultList(context)
              ],
            )
        ),
      ),
    );
  }

  Widget _searchTextBox(bool isTv){
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 2, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: (query){
                        _query = query.trim();
                      },
                      maxLines: 1,
                      onSubmitted: (query){
                        if (query?.isNotEmpty == true) {
                          _query = query.trim();
                          _currentPage = 1;
                          _shows.clear();
                          _isLoading = true;
                          _onUpdate();

                          getShows(!isTv ? SEARCH_MOVIE : SEARCH_TV, _query, _currentPage).then((data){
                            onDataReturn(data);
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          icon: Icon( !isTv ? Icons.live_tv : Icons.movie, color: Colors.white,),
          onPressed: (){
            if (_query?.isNotEmpty == true) {
              _currentPage = 1;
              _shows.clear();
              _isLoading = true;
              _isTv = !_isTv;
              _onUpdate();

              getShows(isTv ? SEARCH_MOVIE : SEARCH_TV, _query, _currentPage).then((data){
                onDataReturn(data);
              });
            } else {
              _isTv = !_isTv;
              _onUpdate();
            }
          },
        ),
        SizedBox(width: 12,)
      ],
    );
  }

  Widget buildResultList(BuildContext context){
    if (_shows.isEmpty) {
      if (_isLoading) {
        return Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator());
      } else {
        return Container();
      }
    }

    var entries = ListTile.divideTiles(
        color: Colors.white30,
        context: context,
        tiles: _shows.map((Show currentMovie){
          return _movieEntry(context, currentMovie);
        }
        )
    ).toList();

    if (_isLoading) {
      entries.add(SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }

    return Expanded(
      child: ListView(
          controller: _scrollController,
          children: entries
      ),
    );
  }

  Widget _posterImage(String path){
    if (path?.isNotEmpty == true) {
      return CachedNetworkImage(
          imageUrl: (SMALL_IMAGE_PREFIX + path),
          fit: BoxFit.contain,
          height: 156, width: 104,
          placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER)
      );
    } else {
      return Image(image: AssetImage(POSTER_PLACEHOLDER),
        fit: BoxFit.contain,
        height: 156, width: 104,);
    }
  }

  Widget _movieEntry(BuildContext context, Show movie){
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 156, width: 104,
              child:  _posterImage(movie.poster),
            ),
            SizedBox(width: 8,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (movie.title ?? movie.name),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      ((movie.release ?? movie.firstAir) ?? ''),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
            ),
            SizedBox(width: 5,),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext _) {
                  return movie.isMovie() ? MovieDetailPage(id: movie.id, pref: _pref,) : TvDetailPage(id: movie.id, pref: _pref,);
                }
            )
        );
      },
    );
  }

  onDataReturn(ShowListResponse response){
    if (response != null) {
      _totalPage = response.totalPage ?? 0;
      if (response.result != null) {
        _shows.addAll(response.result);
      }
      _isLoading = false;
    }
    _onUpdate();
  }

  onDispose(){
    _scrollController.dispose();
  }
}