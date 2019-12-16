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
  Future<MovieListResponse> _movies;

  final VoidCallback onUpdate;
  final VoidCallback onTypeToggle;

  final ShowStorageHelper pref;

  SearchPageManager(this.onUpdate, this.onTypeToggle, this.pref);

  Widget build(BuildContext context, bool isTv){
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
            color: Colors.black,
            child: Column(
              children: <Widget>[
                _searchTextBox(isTv),
                FutureBuilder<MovieListResponse>(
                  future: _movies,
                  builder: (context, snapshot){
                    return buildResultList(context, snapshot);
                  },
                )
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
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
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
                      onSubmitted: (query){
                        if (query != null) {
                          _query = query.trim();
                          _movies = getShows(!isTv ? SEARCH_MOVIE : SEARCH_TV, _query, 1);
                          onUpdate();
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
              _movies = getShows(isTv ? SEARCH_MOVIE : SEARCH_TV, _query, 1);
            }
            onTypeToggle();
          },
        ),
        SizedBox(width: 12,)
      ],
    );
  }

  Widget buildResultList(BuildContext context, AsyncSnapshot<MovieListResponse> snapshot){
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator());
    }

    var list = snapshot?.data?.result ?? List<Show>();
    if (list.isEmpty) {
      return Container();
    }

    return Expanded(
      child: ListView(
          children: ListTile.divideTiles(
              color: Colors.white30,
              context: context,
              tiles: list.map((Show currentMovie){
                return _movieEntry(context, currentMovie);
              }
              )
          ).toList()
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
                  return movie.isMovie() ? MovieDetailPage(id: movie.id, pref: pref,) : TvDetailPage(id: movie.id, pref: pref,);
                }
            )
        );
      },
    );
  }
}