import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_show/model/cast.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/credit_response.dart';
import 'package:my_show/page/crew_page.dart';
import 'package:my_show/page/gallery_page.dart';
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

  CreditResponse _credit;
  List<Show> _similar;
  List<String> _images;

  @override
  void initState() {
    super.initState();
    if (_credit == null) {
      getCredit(false, widget.id).then((response){
        if (response != null) {
          setState(() {
            _credit = response;
          });
        }
      });
    }
    if (_images == null) {
      getMedia(GET_MOVIE_DETAIL + widget.id.toString() + IMAGE).then((response){
        if (response?.backdrops?.isNotEmpty == true) {
          setState(() {
            _images = response.backdrops?.map((bd) => bd.filePath ?? '')?.toList() ?? List();
          });
        }
      });
    }

    if (_similar == null) {
      getShows(GET_MOVIE_DETAIL + widget.id.toString() + SIMILAR, null, null).then((response){
        if (response?.result != null) {
          setState(() {
            _similar = response.result;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      _loadData(context);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body:
      FutureBuilder<MovieDetails>(
        future: _details,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SafeArea(
               child: Container(
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
              ),
            );
          } else if (snapshot.data == null) {
            return SafeArea(
                child: Container(
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
              ),
            );
          } else {
            return _buildDetails(snapshot.data);
          }
        },
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
          Container(
            width: screenWidth,
            height: backdropHeight,
            child: GestureDetector(
              child: CachedNetworkImage(
                  imageUrl: BACKDROP_IMAGE_PREFIX_HD + (detail.backdropPath ?? ''),
                  fit: BoxFit.scaleDown,
                  placeholder: (context, _) => Image.asset(BACKDROP_PLACEHOLDER),
                  height: backdropHeight, width: screenWidth
              ),
              onTap: (){
                if (detail.backdropPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([detail.backdropPath]);
                      }
                  ));
                }
              },
            ),
          ),
          Container(
            width: screenWidth,
            height: backdropHeight,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.4],
                    colors: [Colors.black54, Colors.transparent]
                )
            ),
          ),
          Positioned(
            top: posterTopSpace,
            height: posterHeight, width: posterWidth,
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl: IMAGE_PREFIX + (detail.posterPath ?? ''),
                fit: BoxFit.scaleDown,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: posterHeight, width: posterWidth,
              ),
              onTap: (){
                if (detail.posterPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([detail.posterPath]);
                      }
                  ));
                }
              },
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: SafeArea(
            child: BackButton(
              color: Colors.white,
            ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: SafeArea(
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
          ),
        ],
      ),
    );

  }

  Widget _buildDetails(MovieDetails detail){
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

    var genreWidget = Text(detail.genres.map((genre) => genre.name).join(', '),
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
                children: <Widget>[titleWidget, SizedBox(height: 5,), genreWidget,],
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

    if ((detail.runtime ?? 0) != 0) {
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
        child: Text("${detail.runtime} min",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            )
        ),
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

    if (detail.release != null) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Text('Release',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Text(detail.release,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            )),
      ));

      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));
    }

    if (_credit?.cast?.isNotEmpty == true) {

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Text('Cast',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));
      listChild.add(Container(
        height: 250,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _credit.cast.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              var person = _credit.cast[index];
              return _castBox(context, person);
            }
        ),
      ));
    }

    if (_credit?.crew?.isNotEmpty == true) {
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Crew',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            InkWell(
              child: Text('see all',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  )),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_){
                    return CrewPage(crews: _credit.crew, name: (detail.name ?? detail.originalName));
                  }
                ));
              },
            )
          ],
        )
      ));

      var directors = _credit.crew.where((person) => person.job?.trim()?.toLowerCase() == 'director').toList();
      if (directors.isNotEmpty) {
        listChild.add(Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Text('Director: ${directors.map((person) => person.name).join(', ')}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              )),
        ));
      }
    }

    if ((detail.budget ?? 0) != 0 || (detail.revenue ?? 0) != 0) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      var numFormat = NumberFormat("#,##0", "en_US");

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Text('Box Office',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));

      if ((detail.budget ?? 0) != 0) {
        listChild.add(Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text('Budget: \$${numFormat.format(detail.budget)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    )),
              ));
      }

      if ((detail.revenue ?? 0) != 0) {
        listChild.add(Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text('Revenue: \$${numFormat.format(detail.revenue)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    )),
              ));
      }
    }

    if (_images?.isNotEmpty == true) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      listChild.add(Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Photos',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              InkWell(
                child: Text('more',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.blueGrey,
                    )),
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_){
                        return GalleryPage(_images);
                      }
                  ));
                },
              )
            ],
          )
      ));

      listChild.add(Container(
        height: 150,
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: min(5, _images.length),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              return _photoBox(context, index);
            }
        ),
      ));
    }

    listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

    listChild.add(InkWell(
      child: Row(
        children: <Widget>[
          SizedBox(width: 16,),
          Image.asset(BTN_GOOGLE, width: 30, height: 30,),
          SizedBox(width: 10,),
          Text('Search in Web',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              )),
        ],
      ),
      onTap: (){
        Details.searchInGoogle((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
      },
    ));

    listChild.add(SizedBox(height: 15,));

    listChild.add(InkWell(
      child: Row(
        children: <Widget>[
          SizedBox(width: 16,),
          Image.asset(BTN_YOUTUBE, width: 30, height: 30,),
          SizedBox(width: 10,),
          Text('Search in YouTube',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              )),
        ],
      ),
      onTap: (){
        Details.searchInYoutube((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
      },
    ));

    if (detail.imdbId?.isNotEmpty == true) {
      listChild.add(SizedBox(height: 15,));
      listChild.add(InkWell(
        child: Row(
          children: <Widget>[
            SizedBox(width: 16,),
            Image.asset(BTN_IMDB, width: 30, height: 30,),
            SizedBox(width: 10,),
            Text('View in IMDb',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                )),
          ],
        ),
        onTap: (){
          Details.viewInImdb(detail.imdbId);
        },
      ));
    }

    listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

    if (_similar?.isNotEmpty == true) {
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Text('Similar Items',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));
      listChild.add(Container(
        height: 230,
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _similar.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              var show = _similar[index];
              return _similarBox(context, show);
            }
        ),
      ));
    }

    return ListView(
      padding: EdgeInsets.only(bottom: 10),
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
          CachedNetworkImage(imageUrl: PROFILE_IMAGE_PREFIX + (cast.profilePath ?? ''),
              fit: BoxFit.cover,
              placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
              height: 165, width: 110),
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

  _photoBox(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      width: 200, height: 150,
      child: GestureDetector(
        child: CachedNetworkImage(imageUrl: BACKDROP_IMAGE_PREFIX + (_images[index]),
            fit: BoxFit.cover,
            placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
            height: 150, width: 200),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) {
                return GalleryPage(_images, initialIndex: index,);
              }
          ));
        },
      ),
    );
  }

  _similarBox(BuildContext context, Show show) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        color: Color.fromARGB(255, 40, 40, 40),
        width: 110, height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(imageUrl: LOW_IMAGE_PREFIX + (show.poster ?? ''),
                fit: BoxFit.cover,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: 165, width: 110),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              child: Text((show.title ?? show.originalTitle), style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis,),
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_){
              return MovieDetailPage(id: show.id, pref: widget.pref,);
            }
        ));
      },
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