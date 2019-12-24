import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/cast.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/credit_response.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';
import 'crew_page.dart';
import 'gallery_page.dart';

class TvDetailPage extends StatefulWidget{
  final int id;

  final ShowStorageHelper pref;

  TvDetailPage({@required this.id, @required this.pref, Key key}): super(key: key);

  @override
  State createState() => _TvPageState();
}

class _TvPageState extends State<TvDetailPage>{

  Future<TvDetails> _details;

  CreditResponse _credit;
  List<Show> _similar;
  List<String> _images;

  @override
  void initState() {
    super.initState();
    if (_credit == null) {
      getCredit(true, widget.id).then((response){
        if (response?.cast?.isNotEmpty == true) {
          setState(() {
            _credit = response;
          });
        }
      });
    }
    if (_images == null) {
      getMedia(GET_TV_DETAIL + widget.id.toString() + IMAGE).then((response){
        if (response?.backdrops?.isNotEmpty == true) {
          setState(() {
            _images = response.backdrops?.map((bd) => bd.filePath ?? '')?.toList() ?? List();
          });
        }
      });
    }
    if (_similar == null) {
      getShows(GET_TV_DETAIL + widget.id.toString() + SIMILAR, null, null).then((response){
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
      body: FutureBuilder<TvDetails>(
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
              child:  Container(
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

  Widget _headerImage(TvDetails tv){
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
          Container(
            width: screenWidth,
            height: backdropHeight,
            child: GestureDetector(
              child: CachedNetworkImage(
                  imageUrl: BACKDROP_IMAGE_PREFIX_HD + (tv.backdropPath ?? ''),
                  fit: BoxFit.scaleDown,
                  placeholder: (context, _) => Image.asset(BACKDROP_PLACEHOLDER),
                  height: backdropHeight, width: screenWidth
              ),
              onTap: (){
                if (tv.backdropPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([tv.backdropPath]);
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
                imageUrl: IMAGE_PREFIX + (tv.posterPath ?? ''),
                fit: BoxFit.scaleDown,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: posterHeight, width: posterWidth,
              ),
              onTap: (){
                if (tv.posterPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([tv.posterPath]);
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
                      ? widget.pref.removeTv(widget.id)
                      : widget.pref.addTv(tv);
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

  Widget _buildDetails(TvDetails detail){
    var listChild = List<Widget>();
    listChild.add(_headerImage(detail));

    var titleWidget = Text(
      (detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '',
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    var timeSpanBuffer = StringBuffer();
    timeSpanBuffer.write(Details.parseDate(detail.firstAirDate)?.year?.toString() ?? '');
    if (detail.inProduction == true) {
      timeSpanBuffer.write(' - present');
    } else {
      timeSpanBuffer.write(' - ');
      timeSpanBuffer.write(Details.parseDate(detail.lastAirDate)?.year?.toString() ?? '');
    }
    var releaseWidget = Row(
      children: <Widget>[
        Text(timeSpanBuffer.toString(),
            style: TextStyle(
              fontSize: 16.0,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            )
        ),
        SizedBox(width: 15,),
        Text('${detail.noSeasons ?? 0} season(s)',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            )
        )
      ],
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
                children: <Widget>[titleWidget, SizedBox(height: 5,), releaseWidget, SizedBox(height: 5,), genreWidget,],
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
        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
        child: releaseWidget,
      ));
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
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

    if (_credit?.cast?.isNotEmpty == true) {

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

    if (detail.noEpisodes != null || detail.episodeRunTime?.isNotEmpty == true) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Text('Episodes',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));

      if (detail.noEpisodes != null) {
        listChild.add(Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text('Total Episode: ${detail.noEpisodes}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    )),
              ));
      }

      if (detail.episodeRunTime?.isNotEmpty == true) {
        listChild.add(Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text('Episode Runtime: ${detail.episodeRunTime.first}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    )),
              ));
      }
    }

    if (detail.seasons?.isNotEmpty == true) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Text('Seasons',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ));

      detail.seasons.forEach((s){
        if (s.seasonNo != 0) {
          listChild.add(Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(s.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                )),
          ));

          listChild.add(Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10),
            child: Text('First Air: ${s.airDate}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                )),
          ));
          listChild.add(Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10),
            child: Text('No. of Episode: ${s.episodeCount}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                )),
          ));
        }
      });
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
            child: Text(cast.character, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 11),),
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
              child: Text((show.name ?? show.originalTitle), style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis,),
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_){
              return TvDetailPage(id: show.id, pref: widget.pref,);
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
    _details = getTVDetail(widget.id).then((data) {
      if (data == null) {
        _showRetrySnackbar(context);
      }
      return data;
    });
  }

}