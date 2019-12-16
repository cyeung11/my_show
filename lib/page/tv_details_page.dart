import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class TvDetailPage extends StatefulWidget{
  final int id;

  final ShowStorageHelper pref;

  TvDetailPage({@required this.id, @required this.pref, Key key}): super(key: key);

  @override
  State createState() => _TvPageState();
}

class _TvPageState extends State<TvDetailPage>{

  Future<TvDetails> _details;

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      _loadData(context);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<TvDetails>(
          future: _details,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                constraints: BoxConstraints.expand(),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 5, left: 5,
                      child: BackButton(color: Colors.white,),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
            } else if (snapshot.data == null) {
              return Container(
                constraints: BoxConstraints.expand(),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 5, left: 5,
                      child: BackButton(color: Colors.white,),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white, size: 50,),
                      onPressed: (){
                        setState(() {
                          _loadData(context);
                        });
                      },
                    )
                  ],
                ),
              );
            } else {
              return _buildDetails(snapshot.data);
            }
          },
        ),
      ),
    );
  }

  Widget _headerImage(String poster, String backdrop){
    var screenWidth = MediaQuery.of(context).size.width;
    var posterWidth = screenWidth *0.4;
    var posterHeight = posterWidth * 1.5;
    var backdropHeight = screenWidth / 1.78;
    var posterTopSpace = backdropHeight * 0.5;
    var headerHeight = posterTopSpace + posterHeight;

    var isFav = widget.pref.isTvSaved(widget.id);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            width: screenWidth,
            height: backdropHeight,
            child: CachedNetworkImage(
                imageUrl: IMAGE_MID_PREFIX + backdrop,
                fit: BoxFit.scaleDown,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: backdropHeight, width: screenWidth
            ),
          ),
          Positioned(
            top: posterTopSpace,
            height: posterHeight, width: posterWidth,
            child: CachedNetworkImage(
              imageUrl: IMAGE_PREFIX + poster,
              fit: BoxFit.scaleDown,
              placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
              height: posterHeight, width: posterWidth,
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: BackButton(
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child:  IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 24,),
              onPressed: (){
                setState(() {
                  if (isFav) {
                    widget.pref.removeTv(widget.id);
                  } else {
                    getTVDetail(widget.id).then((tv){
                      widget.pref.addTv(tv);
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(TvDetails detail){
    var genreBuffer = StringBuffer();
    detail.genres.forEach((genre){
      if (genreBuffer.isNotEmpty) {
        genreBuffer.write(', ');
      }
      genreBuffer.write(genre.name);
    });

    return ListView(
      children: <Widget>[
        _headerImage(detail.posterPath, detail.backdropPath),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Text(
            detail.name,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(detail.getFirstAirDate().year.toString(),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  )
              ),
              SizedBox(
                width: 10,
              ),
              Text(genreBuffer.toString(),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  )
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Text(detail.overview ?? "",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              )
          ),
        )
      ],
    );
  }

  _showRetrySnackbar(BuildContext context){
    final snackBar = SnackBar(content: Text('Fail to load :('),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: (){
          setState(() {
            _loadData(context);
          });
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _loadData(BuildContext context){
    _details = getTVDetail(widget.id).then((data) {
      if (data == null) {
        _showRetrySnackbar(context);
      }
      return data;
    });
  }

}