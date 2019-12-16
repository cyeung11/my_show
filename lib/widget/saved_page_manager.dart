import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';
import 'episode_select_dialog.dart';

class SavedPageManager{

  bool deleteMode = false;

  final VoidCallback onUpdate;
  final VoidCallback onTypeToggle;

  final ShowStorageHelper pref;

  SavedPageManager(this.onUpdate, this.onTypeToggle, this.pref);

  saveToStorage(){
    pref.saveTv();
  }

  Widget build(BuildContext context, bool isTv){
    return Scaffold(
      appBar: _appBar(isTv),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: _saveList(context, isTv),
          )
        ],
      ),
    );
  }

  Widget _appBar(bool isTv){
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      title: Text(
        isTv ? 'TV' : 'Movies',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(isTv ? Icons.movie : Icons.live_tv),
          color: Colors.white,
          onPressed: (){
            onTypeToggle();
          },
        ),
        IconButton(
          icon: Icon(deleteMode ? Icons.done : Icons.edit),
          color: Colors.white,
          onPressed: (){
            deleteMode = !deleteMode;
            onUpdate();
          },
        ),
      ],
    );
  }

  Widget _saveList(BuildContext context, bool isTv){
    if (isTv) {
      var watching = pref.watchTv.asMap();
      if (watching.isEmpty) {
        return Center(
          child: Text('Nothing yet :(',
          style: TextStyle(
              fontSize: 14,
            color: Colors.grey
          ),),
        );
      }
      return ListView(
          children: ListTile.divideTiles(
              color: Colors.white30,
              context: context,
              tiles: watching.keys.map((int index) {
                return _tvEntry(context, watching[index], index);
              })
          ).toList()
      );
    } else {
      var movies = pref.savedMovie.asMap();
      if (movies.isEmpty) {
        return Center(
          child: Text('Nothing yet :(',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey
            ),),
        );
      }
      return ListView(
          children: ListTile.divideTiles(
              color: Colors.white30,
              context: context,
              tiles: movies.keys.map((int index) {
                return _movieEntry(context, movies[index], index);
              })
          ).toList()
      );
    }
  }

  Widget _posterImage(BuildContext context, bool isTv, String path, int id){
    return SizedBox(
      height: 162, width: 104,
      child: InkWell(
        child: path?.isNotEmpty == true
            ? CachedNetworkImage(
            imageUrl: (SMALL_IMAGE_PREFIX + path),
            fit: BoxFit.contain,
            height: 156, width: 104,
            placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER)
        )
            : Image(image: AssetImage(POSTER_PLACEHOLDER),
          fit: BoxFit.contain,
          height: 156, width: 104,),
        onTap: () {
          if (!deleteMode) {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext _) {
                      return isTv ? TvDetailPage(id: id, pref: pref,) : MovieDetailPage(id: id, pref: pref,);
                    }
                )
            );
          }
        },
      ),
    );
  }

  Widget _nextEpisodeText(TvDetails tv){
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

  Widget _movieEntry(BuildContext context, MovieDetails movie, int indexInList){
    List<Widget> widgetList = List<Widget>();
    widgetList.add(SizedBox(width: 12,));
    widgetList.add(_posterImage(context, false, movie.poster, movie.id));
    widgetList.add(SizedBox(width: 8,));
    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(movie.title ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 16.0,),
                ),
                SizedBox(height: 5,),
                Text(
                  (movie.release ?? ''),
                  style: TextStyle(color: Colors.grey, fontSize: 12.0,),
                ),
              ],
            )
        )
    );
    widgetList.add(SizedBox(width: 5,));
    if (deleteMode) {
      widgetList.add(_deleteModeDeleteButton(context, false, movie.id));
      return Row(children: widgetList,);
    }
    return Builder(
      builder: (BuildContext context){
        return _dismissible(context, (_){
          pref.removeShow(movie.id);
          onUpdate();
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Item removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    pref.addShow(movie, index: indexInList);
                    onUpdate();
                  },
                ),
              )
          );
        }, Row(children: widgetList,), movie.id.toString());
      },
    );
  }

  Widget _tvEntry(BuildContext context, TvDetails tv, int indexInList){
    List<Widget> widgetList = List<Widget>();
    widgetList.add(SizedBox(width: 12,));
    widgetList.add(_posterImage(context, true, tv.posterPath, tv.id));
    widgetList.add(SizedBox(width: 8,));
    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tv.name ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 16.0,),
                ),
                SizedBox(height: 5,),
                _nextEpisodeText(tv),
                _progressRow(context, tv)
              ],
            )
        )
    );
    widgetList.add(
        SizedBox(width: 5,)
    );
    if (deleteMode) {
      widgetList.add(_deleteModeDeleteButton(context, true, tv.id));
      return Row(children: widgetList,);
    }
    return Builder(
        builder: (BuildContext context) {
          return _dismissible(context,
                  (_) {
                pref.removeTv(tv.id);
                onUpdate();
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Item removed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          pref.addTv(tv, index: indexInList);
                          onUpdate();
                        },
                      ),
                    )
                );
              },
              Row(children: widgetList,),
              tv.id.toString());
        });
  }

  Widget _deleteModeDeleteButton(BuildContext context, bool isTv, int id){
    return Container(
      height: 162,
      color: Colors.redAccent,
      child: Center(
        child: IconButton(
          icon: Icon(Icons.delete, size: 20),
          color: Colors.white,
          onPressed: (){
            _showRemoveDialog(context, isTv, id);
          },
        ),
      ),
    );
  }

  Widget _dismissible(BuildContext context, DismissDirectionCallback onDismiss, Widget child, String key){
    return Dismissible(
      // Show a red background as the item is swiped away.
      background: Container(
        color: Colors.redAccent,
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
      key: Key(key),
      direction: DismissDirection.endToStart,
      onDismissed: onDismiss,
      child: child,
    );
  }

  _showRemoveDialog(BuildContext context, bool isTv, int id){
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
                  style: TextStyle(color: Colors.redAccent),),
                onPressed: (){
                  Navigator.of(context).pop();
                  if (isTv) {
                    pref.removeTv(id);
                  } else {
                    pref.removeShow(id);
                  }
                  onUpdate();
                },
              ),
            ],
          );
        }
    );
  }

  Widget _progressRow(BuildContext context, TvDetails tv){
    var isLast = tv.lastEpisodeAir?.seasonNo == tv.progress?.seasonNo && tv.lastEpisodeAir?.episodeNo == tv.progress?.episodeNo;
    var isFirst = tv.progress?.seasonNo == 1 && tv.progress?.episodeNo == 1;
    List<Widget> widgetList = List<Widget>();
    if (!deleteMode) {
      widgetList.add(IconButton(
        icon: Icon(Icons.add),
        color: Colors.white,
        disabledColor: Colors.grey,
        onPressed: isLast
            ? null
            : (){
          tv.progress = tv.progress.next(tv.seasons);
          onUpdate();
        },
      ));
    }
    widgetList.add(Text(
      tv.progress.userReadable(),
      style: TextStyle(
        color: Colors.white,
      ),
    ));
    if (deleteMode) {
      widgetList.add(
          IconButton(
            icon: Icon(Icons.edit, size: 14),
            color: Colors.white,
            onPressed: () {
              _selectEpisode(context, tv);
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
              tv.progress = tv.progress.previous(tv.seasons);
              onUpdate();
            },
          )
      );
    }

    return Row(children: widgetList);
  }

  _selectEpisode(BuildContext context, TvDetails tv){
    showDialog(context: context,
        barrierDismissible: true,
        builder: (context){
          return EpisodeSelectDialog.show(
            seasons: tv.seasons,
            currentProgress: tv.progress,
            onEpisodeSelected: (episode){
              tv.progress = episode;
              onUpdate();
            },
          );
        }
    );
  }
}