import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/cast.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class MovieDetailPage extends StatefulWidget{
  final int id;

  final ShowStorageHelper pref;

  MovieDetailPage({@required this.id,  @required this.pref, Key key}): super(key: key);

  @override
  State createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage>{

  Future<MovieDetails> _details;

  List<Cast> _casts;

  @override
  void initState() {
    super.initState();
    getCredit(false, widget.id).then((response){
      if (response?.cast?.isNotEmpty == true) {
        setState(() {
          _casts = response.cast;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      _loadData(context);
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body:
        FutureBuilder<MovieDetails>(
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

  Widget _headerImage(MovieDetails detail){
    var screenWidth = MediaQuery.of(context).size.width;
    var posterWidth = screenWidth *0.4;
    var posterHeight = posterWidth * 1.5;
    var backdropHeight = screenWidth / 1.78;
    var posterTopSpace = backdropHeight * 0.5;
    var headerHeight = posterTopSpace + posterHeight;

    var isFav = widget.pref.isMovieSaved(widget.id);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            width: screenWidth,
            height: backdropHeight,
            child: CachedNetworkImage(
                imageUrl: IMAGE_PREFIX + (detail.backdropPath ?? ''),
                fit: BoxFit.scaleDown,
                placeholder: (context, _) => Image.asset(BACKDROP_PLACEHOLDER),
                height: backdropHeight, width: screenWidth
            ),
          ),
          Positioned(
            top: posterTopSpace,
            height: posterHeight, width: posterWidth,
            child: CachedNetworkImage(
              imageUrl: IMAGE_PREFIX + (detail.posterPath ?? ''),
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
                var future = isFav
                    ? widget.pref.removeMovie(widget.id)
                    : widget.pref.addMovie(detail);
                future.whenComplete((){
                  setState(() {});
                });
              },
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildDetails(MovieDetails detail){
    var genreBuffer = StringBuffer();
    detail.genres.forEach((genre){
      if (genreBuffer.isNotEmpty) {
        genreBuffer.write(', ');
      }
      genreBuffer.write(genre.name);
    });

    var titleBuffer = StringBuffer();
    titleBuffer.write((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
    var release = Details.parseDate(detail.release);
    if (release != null) {
      titleBuffer.write(' (${release.year})');
    }

    var listChild = List<Widget>();
    listChild.add(_headerImage(detail));

    var titleWidget = Text(
      titleBuffer.toString(),
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    var genreWidget = Text(genreBuffer.toString(),
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
        )
    );

    if ((detail.voteCount ?? 0) > 0) {
      MaterialColor color;
      if (detail.voteAverage >= 6.5)
        color = Colors.green;
      else if (detail.voteAverage >= 4)
        color = Colors.yellow;
      else
        color = Colors.red;

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[titleWidget, genreWidget,],
              ),
            ),
            SizedBox(width: 5,),
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 4.0,
              percent: detail.voteAverage / 10,
              center: new Text(detail.voteAverage.toString(),
                style: TextStyle(fontSize: 12.0, color: Colors.white,),
              ),
              backgroundColor: Colors.grey,
              progressColor: color,
            )
          ],
        ),
      ));

    } else {
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: titleWidget,
      ));
      listChild.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: genreWidget,
      ));
    }

    listChild.add(Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text(detail.overview ?? "",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          )
      ),
    ));

    if (_casts?.isNotEmpty == true) {

      listChild.add(Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text('Cast',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          )
      );
      listChild.add(Container(
        height: 250,
        child: ListView.builder(
            itemCount: _casts.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              var person = _casts[index];
              return _castBox(context, person);
            }
        ),
      ));
    }

    return ListView(
      children: listChild,
    );
  }

  _castBox(BuildContext context, Cast cast) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      color: Color.fromARGB(255, 40, 40, 40),
      width: 110, height: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CachedNetworkImage(imageUrl: MID_IMAGE_PREFIX + (cast.profilePath ?? ''),
              fit: BoxFit.cover,
              placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
              height: 160, width: 110),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, top: 5),
            child: Text(cast.name, style: TextStyle(color: Colors.white, fontSize: 12),),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Text(cast.character, style: TextStyle(color: Colors.grey, fontSize: 11),),
          )
        ],
      ),
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
    _details = getMovieDetail(widget.id).then((data) {
      if (data == null) {
        _showRetrySnackbar(context);
      }
      return data;
    });
  }

}