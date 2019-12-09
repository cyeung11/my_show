import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/movie_list_response.dart';
import 'package:my_show/page/movie_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class SearchPage extends StatefulWidget{

  final ShowStorageHelper pref;

  SearchPage({@required this.pref, Key key}): super(key: key);

  @override
  State createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{

  Future<MovieListResponse> _movies;

  String _query;

  bool _searchMovie = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            buildSearchTextBox(),
            FutureBuilder<MovieListResponse>(
              future: _movies,
              builder: (context, snapshot){
                return buildResultList(snapshot);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearchTextBox(){
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
                          setState(() {
                            _query = query.trim();
                            _movies = getShows(_searchMovie ? SEARCH_MOVIE : SEARCH_TV, _query, 1);
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
          icon: Icon( _searchMovie ? Icons.tv : Icons.movie, color: Colors.white,),
          onPressed: (){
            setState(() {
              _searchMovie = !_searchMovie;
              if (_query?.isNotEmpty == true) {
                _movies = getShows(_searchMovie ? SEARCH_MOVIE : SEARCH_TV, _query, 1);
              }
            });
          },
        ),
        SizedBox(width: 12,)
      ],
    );
  }

  Widget buildResultList(AsyncSnapshot<MovieListResponse> snapshot){
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
                return buildMovieEntry(currentMovie);
              }
              )
          ).toList()
      ),
    );
  }

  Widget getPoster(String path){
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

  Widget buildMovieEntry(Show movie){
    bool isFav = widget.pref.isShowSaved(movie);
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 156, width: 104,
              child:  getPoster(movie.poster),
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
            IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 30,),
              onPressed: (){
                setState(() {
                  if (isFav) {
                    widget.pref.removeShow(movie);
                  } else {
                    widget.pref.addShow(movie);
                  }
                });
              },
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext _) {
                  return MovieDetailPage(id: movie.id);
                }
            )
        );
      },
    );
  }
}