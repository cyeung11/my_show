import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';

import '../asset_path.dart';

class TvDetailPage extends StatefulWidget{
  final int id;

  TvDetailPage({@required this.id, Key key}): super(key: key);

  @override
  State createState() => _TvPageState();
}

class _TvPageState extends State<TvDetailPage>{

  Future<TvDetails> _details;

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      _details = getTVDetail(widget.id);
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body:  Stack(
          children: <Widget>[
            FutureBuilder<TvDetails>(
              future: _details,
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data == null) {
                  _showRetrySnackbar(context);
                  return Container();
                } else {
                  return _buildDetails(snapshot.data);
                }
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              child:
              BackButton(
                color: Colors.white,
              ),
            ),
          ],
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