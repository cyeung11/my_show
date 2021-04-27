import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/credit_response.dart';
import 'package:my_show/page/detail_page.dart';

import '../asset_path.dart';
import '../storage/pref_helper.dart';

class MovieDetailPage extends StatefulWidget{
  final int id;

  MovieDetailPage(this.id, {Key key}): super(key: key);

  @override
  State createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends DetailPageState<MovieDetailPage>{

  Future<MovieDetails> _details;
  MovieDetails _cache;

  CreditResponse _credit;

  var _isFav;


  @override
  String getDetailPath() {
    return GET_MOVIE_DETAIL + widget.id.toString();
  }

  @override
  void initState() {
    super.initState();
    _isFav = PrefHelper.instance.isMovieSaved(widget.id);
    if (_credit == null) {
      getCredit(false, widget.id).then((response){
        if (response != null) {
          setState(() {
            _credit = response;
          });
        }
      });
    }
    getDetailMedia();
    getDetailSimilar();
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      loadData(context);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<MovieDetails>(
        future: _details,
        builder: (context, snapshot){
          if (snapshot.connectionState != ConnectionState.waiting && snapshot.data != null) {
            return _buildDetails(snapshot.data);
          } else if (_cache != null) {
            return _buildDetails(_cache);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoading();
          } else {
            return buildRetry(context);
          }
        },
      ),
    );
  }

  Widget _headerImage(MovieDetails detail){
    return buildHeaderImage(detail, IconButton(
      icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 24,),
      onPressed: (){
        var future = _isFav
            ? PrefHelper.instance.removeMovie(widget.id)
            : PrefHelper.instance.addMovie(detail);
        future.then((result){
          if (result) {
            setState(() {
              _isFav = !_isFav;
            });
          }
        });
      },
    ));
  }

  Widget _buildDetails(MovieDetails detail){
    var titleBuffer = StringBuffer();
    titleBuffer.write((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
    var release = Details.parseDate(detail.release);
    if (release != null) {
      titleBuffer.write(' (${release.year})');
    }

    var listChild = List<Widget>.empty(growable: true);
    listChild.add(_headerImage(detail));

    var titleWidget = Text(
      titleBuffer.toString(),
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    var genreWidget = buildGenre(detail);

    if ((detail.voteCount ?? 0) > 0) {

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
            buildVotePoint(detail)
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

    listChild.add(buildOverview(detail));

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
      listChild.addAll(buildCastSection(_credit.cast));
    }

    if (_credit?.crew?.isNotEmpty == true) {
      listChild.addAll(buildCrewSection(detail, _credit.crew));
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

    if (images?.isNotEmpty == true) {
      listChild.addAll(buildImageSection());
    }

    listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

    listChild.add(buildSearchWeb(detail));

    listChild.add(buildSearchYoutube(detail));

    if (detail.imdbId?.isNotEmpty == true) {
      listChild.add(InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              Image.asset(BTN_IMDB, width: 30, height: 30,),
              SizedBox(width: 10,),
              Text('View in IMDb',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
        onTap: (){
          Details.viewInImdb(detail.imdbId);
        },
      ));
    }

    if (similar?.isNotEmpty == true) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));
      listChild.addAll(buildSimilar());
    }

    return ListView(
      padding: EdgeInsets.only(bottom: 10),
      children: listChild,
    );
  }

  @override
  String getName(Show show) {
    return show.title ?? show.originalTitle;
  }

  @override
  StatefulWidget goToDetailPage(int showId) {
    return MovieDetailPage(showId);
  }

  @override
  loadData(BuildContext context){
    MovieDetails.getById(widget.id).then((m){
      setState(() {
        _cache = m;
      });
    });

    _details = getMovieDetail(widget.id).then((data) {
      if (data == null) {
        showRetrySnackbar(context);
      }
      return data;
    });
  }

}