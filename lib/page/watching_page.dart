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
        appBar: buildAppBar(),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Expanded(
              child: buildSaveList(context),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(){
    return AppBar(
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
    );
  }

  Widget buildSaveList(BuildContext context){
    var watching = widget.pref.watchTv.asMap();

    return ListView(
        children: ListTile.divideTiles(
            color: Colors.white54,
            context: context,
            tiles: watching.keys.map((int index) {
              return buildMovieEntry(context, watching[index], index);
            })
        ).toList()
    );
  }

  Widget getPoster(TvDetails tv){
    return SizedBox(
      height: 162, width: 104,
      child: InkWell(
        child: tv.posterPath?.isNotEmpty == true
            ? CachedNetworkImage(
            imageUrl: (SMALL_IMAGE_PREFIX + tv.posterPath),
            fit: BoxFit.contain,
            height: 156, width: 104,
            placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER)
        )
            : Image(image: AssetImage(POSTER_PLACEHOLDER),
          fit: BoxFit.contain,
          height: 156, width: 104,),
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
    );
  }

  Widget nextEpisodeText(TvDetails tv){
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
    return Text(
        nextEpisode.toString(),
        style: TextStyle(
        color: Colors.grey,
        fontSize: 12.0,
    ));
  }

  Widget buildMovieEntry(BuildContext buildContext, TvDetails tv, int indexInList){
    List<Widget> widgetList = List<Widget>();
    widgetList.add(
        SizedBox(width: 12,)
    );
    widgetList.add(getPoster(tv));
    widgetList.add(
        SizedBox(width: 8,)
    );


    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tv.name,
                  style: TextStyle(color: Colors.white, fontSize: 16.0,),
                ),
                SizedBox(height: 5,),
                nextEpisodeText(tv),
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
        Container(
          height: 162,
          color: Colors.red,
          child: Center(
            child: IconButton(
              icon: Icon(Icons.delete, size: 20),
              color: Colors.white,
              onPressed: (){
                _showRemoveDialog(tv);
              },
            ),
          ),
        )
      );
    }

    if (_deleteMode) {
      return Row(
        children: widgetList,
      );
    }

    return Builder(
      builder: (BuildContext context){
        return Dismissible(
          // Show a red background as the item is swiped away.
          background: Container(
            color: Colors.red,
            child: Stack(
              fit: StackFit.expand, alignment: AlignmentDirectional.centerEnd,
              children: <Widget>[
                Positioned(
                  right: 10,
                  child: Icon(Icons.delete, size: 20, color: Colors.white,),
                )
              ],
            ),
          ),
          key: Key(tv.id.toString()), direction: DismissDirection.endToStart,
          onDismissed: (direction) {

            setState(() {
              widget.pref.removeTv(tv.id);
            });

            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Item removed'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: (){
                      setState(() {
                        widget.pref.addTv(tv, index: indexInList);
                      });
                    },
                  ),
                )
            );
          },

          child:Row(
              children: widgetList,
          ),
        );
      },
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
    var isLast = tv.lastEpisodeAir?.seasonNo == tv.progress?.seasonNo && tv.lastEpisodeAir?.episodeNo == tv.progress?.episodeNo;
    var isFirst = tv.progress?.seasonNo == 1 && tv.progress?.episodeNo == 1;
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
          return EpisodeSelectDialog.show(
            seasons: tv.seasons,
            currentProgress: tv.progress,
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