import 'package:flutter/material.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/credit_response.dart';
import 'package:my_show/page/detail_page.dart';
import 'package:my_show/state/tv_state_model.dart';
import 'package:provider/provider.dart';

class TvDetailPage extends StatefulWidget{
  final int id;


  TvDetailPage( this.id, {Key key}): super(key: key);

  @override
  State createState() => _TvPageState();
}

class _TvPageState extends DetailPageState<TvDetailPage>{

  Future<TvDetails> _details;
  TvDetails _cache;

  CreditResponse _credit;

  @override
  String getDetailPath() {
    return GET_TV_DETAIL + widget.id.toString();
  }

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
      body: FutureBuilder<TvDetails>(
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

  Widget _headerImage(TvDetails tv){
    return buildHeaderImage(
      tv,
      Consumer<TvStateModel>(builder: (context, value, _){
        bool isFav = value.isTvSaved(widget.id);
        return IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 24,),
            onPressed: () {
              isFav
                  ? value.removeTv(widget.id)
                  : value.addTv(tv);
            }
        );
      })
    );
  }

  Widget _buildDetails(TvDetails detail){
    var listChild = List<Widget>.empty(growable: true);
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
    var first = Details.parseDate(detail.firstAirDate);
    if (first != null) {
      timeSpanBuffer.write(first?.year?.toString() ?? '');
      if (detail.inProduction == true) {
        timeSpanBuffer.write(' - present');
      } else {
        var last = Details.parseDate(detail.lastAirDate);
        if (last != null && last.year != first.year) {
          timeSpanBuffer.write(' - ');
          timeSpanBuffer.write(last?.year?.toString() ?? '');
        }
      }
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

    var genreWidget = buildGenre(detail);

    if ((detail.voteCount ?? 0) > 0) {

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
        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
        child: releaseWidget,
      ));
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
        child: genreWidget,
      ));
    }

    listChild.add(buildOverview(detail));

    if (_credit?.cast?.isNotEmpty == true) {
      listChild.addAll(buildCastSection(_credit.cast));
    }

    if (_credit?.crew?.isNotEmpty == true) {
      listChild.addAll(buildCrewSection(detail, _credit.crew));
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
          child: Text('Episode Runtime: ${detail.episodeRunTime.first} mins',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              )),
        ));
      }
    }

    if (detail.nextEpisodeAir?.airDate?.isNotEmpty == true) {
      listChild.add(Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Text('Next Episode in: ${detail.nextEpisodeAir.airDate}',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            )),
      ));
    }

    if (detail.seasons?.isNotEmpty == true) {
      listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

      var episodeList = List<Widget>.empty(growable: true);

      detail.seasons.forEach((s){
        if (s.seasonNo != 0) {
          if (episodeList.isNotEmpty) {
            episodeList.add(SizedBox(height: 15));
          }

          episodeList.add(Text(s.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                )),
          );

          episodeList.add(SizedBox(height: 7.5));

          episodeList.add(Text('First Air: ${s.airDate ?? 'TDC'}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                )),
          );
          if ((s.episodeCount ?? 0) > 0) {
            episodeList.add(SizedBox(height: 7.5));
            episodeList.add(Text('No. of Episode: ${s.episodeCount}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  )),
            );
          }
        }
      });

      listChild.add(
        ExpansionTile(
          title: Text('Seasons',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          children: episodeList,
        ),
      );
    }

    if (images?.isNotEmpty == true) {
      listChild.addAll(buildImageSection());
    }

    listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

    listChild.add(buildSearchWeb(detail));

    listChild.add(buildSearchYoutube(detail));

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
    return show.name ?? show.originalTitle;
  }

  @override
  StatefulWidget goToDetailPage(int showId) {
    return TvDetailPage(showId);
  }

  @override
  loadData(BuildContext context){
    TvDetails.getById(widget.id).then((tv){
      setState(() {
        _cache = tv;
      });
    });

    _details = getTVDetail(widget.id).then((data) {
      if (data == null) {
        showRetrySnackbar(context);
      }
      return data;
    });
  }

}