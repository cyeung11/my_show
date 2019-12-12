import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/episode_select_dialog.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/tv_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class WatchingPage extends StatefulWidget{

  final ShowStorageHelper pref;

  WatchingPage({@required this.pref, Key key}): super(key: key);

  @override
  State createState() => _WatchingPageState();
}

class _WatchingPageState extends State<WatchingPage> with WidgetsBindingObserver{

  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.pref.saveTv();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_deleteMode){
          setState(() {
            _deleteMode = false;
          });
          return Future.value(false);
        } else {
          widget.pref.saveTv();
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          title: Text(
            'Watching',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
          leading: BackButton(
            color: Colors.white,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(_deleteMode ? Icons.done : Icons.edit),
              color: Colors.white,
              onPressed: (){
                setState(() {
                  _deleteMode = !_deleteMode;
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Expanded(
              child: buildSaveList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSaveList(){
    var list = widget.pref.watchTv;
    return ListView(
        children: ListTile.divideTiles(
            color: Colors.white30,
            context: context,
            tiles: list.map((TvDetails currentTv){
              return buildMovieEntry(currentTv);
            }
            )
        ).toList()
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

  Widget buildMovieEntry(TvDetails tv){
    List<Widget> widgetList = List<Widget>();
    widgetList.add(SizedBox(
      height: 156, width: 104,
      child: InkWell(
        child: getPoster(tv.posterPath),
        onTap: () {
          if (!_deleteMode) {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext _) {
                      return TvDetailPage(id: tv.id,);
                    }
                )
            );
          }
        },
      ),
    ));

    widgetList.add(
        SizedBox(width: 8,)
    );

    var nextEpisode = StringBuffer(tv?.inProduction == true ? 'Latest: ' : 'Ended');
    if (tv?.inProduction == true) {
      if (tv.lastEpisodeAir?.seasonNo != null) {
        nextEpisode.write("S");
        nextEpisode.write(tv.lastEpisodeAir?.seasonNo);
        nextEpisode.write(' ');
      }
      if (tv.lastEpisodeAir?.episodeNo != null) {
        nextEpisode.write("E");
        nextEpisode.write(tv.lastEpisodeAir?.episodeNo);
      }
    }

    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (tv.name ?? tv.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  nextEpisode.toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                buildWatched(tv)
              ],
            )
        )
    );
    widgetList.add(
        SizedBox(width: 5,)
    );
    if (_deleteMode) {
      widgetList.add(
          IconButton(
            icon: Icon(Icons.delete, size: 20),
            color: Colors.white,
            onPressed: (){
              _showRemoveDialog(tv);
            },
          )
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: widgetList,
      ),
    );
  }

  _showRemoveDialog(TvDetails movie){
    showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Remove',),
            content: Text('Do you want to remove this item?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Remove',
                  style: TextStyle(color: Colors.red),),
                onPressed: (){
                  Navigator.of(context).pop();
                  setState(() {
                    widget.pref.removeTv(movie.id);
                  });
                },
              ),
            ],
          );
        }
    );
  }

  Widget buildWatched(TvDetails tv){
    var isLast = tv.lastEpisodeAir?.seasonNo == tv.progress.seasonNo && tv.lastEpisodeAir?.episodeNo == tv.progress.episodeNo;
    var isFirst = tv.progress.seasonNo == 1 && tv.progress.episodeNo == 1;
    List<Widget> widgetList = List<Widget>();
    if (!_deleteMode) {
      widgetList.add(IconButton(
        icon: Icon(Icons.add),
        color: Colors.white,
        disabledColor: Colors.grey,
        onPressed: isLast
            ? null
            : (){
          setState(() {
            tv.progress = tv.progress.next(tv.seasons);
          });
        },
      ));
    }
    widgetList.add(Text(
      tv.progress.userReadable(),
      style: TextStyle(
        color: Colors.white,
      ),
    ));
    if (_deleteMode) {
      widgetList.add(
          IconButton(
            icon: Icon(Icons.edit, size: 14),
            color: Colors.white,
            onPressed: () {
              _selectEpisode(tv);
            },
          )
      );
    } else {
      widgetList.add(
          IconButton(
            icon: Icon(Icons.remove),
            color: Colors.white,
            disabledColor: Colors.grey,
            onPressed: isFirst
                ? null
                : (){
              setState(() {
                tv.progress = tv.progress.previous(tv.seasons);
              });
            },
          )
      );
    }

    return Row(children: widgetList);
  }

  _selectEpisode(TvDetails tv){
    showDialog(context: context,
        barrierDismissible: true,
        builder: (context){
          return EpisodeSelectDialog(
            seasons: tv.seasons,
            onEpisodeSelected: (episode){
              setState(() {
                tv.progress = episode;
              });
            },
          );
        }
    );
  }

//  Widget buildDropbox(TvDetails tv) {
//    var episodeList = List<String>.generate(tv.noEpisodes, (i) => i.toString());
//    episodeList.removeAt(0);
//
//    return DropdownButton<String>(
//      value: tv.lastWatchEpisode?.toString() ?? episodeList.last,
//      underline: SizedBox(),
//      style: TextStyle(
//          color: Colors.white,
//          fontSize: 16
//      ),
//      onChanged: (String newValue) {
//        var lastWatch =  int.tryParse(newValue);
//        if (lastWatch != null) {
//          setState(() {
//            tv.lastWatchEpisode = lastWatch;
//          });
//        }
//      },
//      items: episodeList
//          .map<DropdownMenuItem<String>>((String value) {
//        return DropdownMenuItem<String>(
//          value: value,
//          child: Text(value,
////                      style: TextStyle(
////                        color: Colors.black,
////                      ),
//          ),
//        );
//      }).toList(),
//    );
//  }
}