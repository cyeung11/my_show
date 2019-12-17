import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';
import 'package:my_show/widget/genre_select_dialog.dart';
import 'package:my_show/widget/sort_select_dialog.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class BrowsePageManager{

  bool _isLoading = false;
  int _currentPage = 1;

  bool _isTv = true;

  int _year;
  double _vote;
  Genre _genre;
  SortType _sort = SortType.PopularityDesc;

  final VoidCallback onUpdate;

  final ShowStorageHelper pref;
  final ScrollController _scrollController = ScrollController();

  final List<Show> _shows = List<Show>();
  int _totalPage;

  BrowsePageManager(this.onUpdate, this.pref){
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage + 1 <= _totalPage) {
        _currentPage++;
        _isLoading = true;

        onUpdate();

        discover(_isTv, _year, _vote, _genre, _sort, _currentPage).then((data){
          onDataReturn(data);
        });
      }
    }
  }

  Widget build(BuildContext context){
    if (_shows.isEmpty && !_isLoading) {
      _isLoading = true;
      discover(_isTv, _year, _vote, _genre, _sort, _currentPage).then((data){
        onDataReturn(data);
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: <Widget>[
                _topRow(context),
                buildResultList(context)
              ],
            )
        ),
      ),
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
          icon: Icon(!_isTv ? Icons.live_tv : Icons.movie, color: Colors.white,),
          onPressed: (){
            _currentPage = 1;
            _shows.clear();
            _isLoading = true;
            _isTv = !_isTv;
            _year = null;
            _sort = SortType.PopularityDesc;
            _genre = null;
            _vote = null;
            onUpdate();

            discover(_isTv, _year, _vote, _genre, _sort, _currentPage).then((data){
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
        Container(
          padding: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: InkWell(
            child: Center(
              child: Text('Genre: ${_genre != null ? _genre.name : 'All'}'),
            ),
            onTap: (){
              showDialog(context: context,
                  barrierDismissible: true,
                  builder: (context){
                    return GenreSelectDialog(
                      selectable: _isTv ? pref.tvGenres : pref.movieGenres,
                      onGenreSelected: (genre){
                        _genre = genre;
                        _currentPage = 1;
                        _shows.clear();
                        _isLoading = true;
                        onUpdate();

                        discover(_isTv, _year, _vote, _genre, _sort, _currentPage).then((data){
                          onDataReturn(data);
                        });
                      },
                    );
                  }
              );
            },
          ),
        ),
        SizedBox(width: 5,),
        Container(
          padding: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text('Year: ${_year != null ? _year.toString() : 'All'}'),
          ),
        ),
        SizedBox(width: 5,),
        Container(
          padding: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text('Vote: ${_vote != null ? _vote.toString() : 'All'}'),
          ),
        ),
        SizedBox(width: 5,),
        Container(
            padding: EdgeInsets.all(7.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: InkWell(
              child:  Center(
                child: Text('Sort: ${sortString(_sort)}'),
              ),
              onTap: (){
                showDialog(context: context,
                    barrierDismissible: true,
                    builder: (context){
                      return SortSelectDialog(
                        selectable: SortType.values,
                        onSortSelected: (sort){
                          _sort = sort;
                          _currentPage = 1;
                          _shows.clear();
                          _isLoading = true;
                          onUpdate();

                          discover(_isTv, _year, _vote, _genre, _sort, _currentPage).then((data){
                            onDataReturn(data);
                          });
                        },
                      );
                    }
                );
              },
            )
        ),
      ],
    );
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
                  return movie.isMovie() ? MovieDetailPage(id: movie.id, pref: pref,) : TvDetailPage(id: movie.id, pref: pref,);
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
    }
    _isLoading = false;
    onUpdate();
  }

  onDispose(){
    _scrollController.dispose();
  }
}

enum SortType{
  VoteDesc, VoteAsc, PopularityDesc, PopularityAsc, ReleaseAsc, ReleaseDesc
}

String sortString(SortType sortType) {
  if (sortType == SortType.VoteDesc)
    return 'Score Highest';
  else if (sortType == SortType.VoteAsc)
    return 'Score Lowest';
  else if (sortType == SortType.PopularityDesc)
    return 'Popularity Highest';
  else if (sortType == SortType.PopularityAsc)
    return 'Popularity Lowest';
  else if (sortType == SortType.ReleaseAsc)
    return 'Oldest';
  else
    return 'Latest';
}

