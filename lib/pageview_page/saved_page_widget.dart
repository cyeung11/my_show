import 'package:flutter/material.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/model/watch_progress.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';
import 'package:my_show/pageview_page/page_manager/saved_page_manager.dart';
import 'package:my_show/pageview_page/show_widget_builder.dart';
import 'package:my_show/state/movie_state_model.dart';
import 'package:my_show/state/tv_state_model.dart';
import 'package:my_show/widget/episode_select_dialog.dart';
import 'package:provider/provider.dart';

class SavedPageWidget extends StatefulWidget{

  final SavedPageManager _pageManager;

  final VoidCallback _onSearch;

  SavedPageWidget(this._pageManager, this._onSearch, {Key key}): super(key: key);

  @override
  State createState()  => _SavedPageState();
}

class _SavedPageState extends State<SavedPageWidget> {

  ScrollController _scrollController;

  List<MovieDetails> savedMovie;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget._pageManager.scrollOffsetToRestore);
    Provider.of<TvStateModel>(context, listen: false).getUpdatedWatchTv();
    Provider.of<MovieStateModel>(context, listen: false).getUpdateWatchMovie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(widget._pageManager.isTv),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: widget._pageManager.isTv ? _savedTvList(context) : _savedMovieList(context),
          )
        ],
      ),
    );
  }

  @override
  dispose() {
    _scrollController.dispose();
    widget._pageManager.deleteMode = false;
    super.dispose();
  }

  Widget _appBar(bool isTv){
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      title: Text(
        isTv ? 'Saved TV' : 'Saved Movies',
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
            setState(() {
              widget._pageManager.isTv = !widget._pageManager.isTv;
            });
          },
        ),
        IconButton(
          icon: Icon(widget._pageManager.deleteMode ? Icons.done : Icons.edit),
          color: Colors.white,
          onPressed: (){
            setState(() {
              widget._pageManager.deleteMode = !widget._pageManager.deleteMode;
            });
          },
        ),
      ],
    );
  }

  Widget _emptyWidget(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 15,
        direction: Axis.vertical,
        children: <Widget>[
          Text('Nothing yet :(',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey
              )
          ),
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(7.5),
              child: Wrap(
                spacing: 3,
                direction: Axis.horizontal,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.redAccent, size: 16),
                  Text('add item',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent
                      )
                  )
                ],
              ),
            ),
            onTap: widget._onSearch,
          )
        ],
      ),
    );
  }

  Widget _savedTvList(BuildContext context){
    return Consumer<TvStateModel>(builder: (context, value, _){
      List<TvDetails> data = value.watchTv;
      if (data.isEmpty) {
        return _emptyWidget(context);
      } else {
        return NotificationListener(
          child: ListView(
              controller: _scrollController,
              children: ListTile.divideTiles(
                  color: Colors.white30,
                  context: context,
                  tiles: data.map((TvDetails detail) {
                    return _tvEntry(context, detail);
                  })
              ).toList()
          ),
          onNotification: (notification){
            if (notification is ScrollNotification) {
              widget._pageManager.scrollOffsetToRestore = notification.metrics.pixels;
            }
            return false;
          },
        );
      }
    });
  }

  Widget _savedMovieList(BuildContext context){
    return Consumer<MovieStateModel>(builder: (context, value, _){
      List<MovieDetails> data = value.watchMovie;
      if (data.isEmpty) {
        return _emptyWidget(context);
      } else {
        return NotificationListener(
          child: ListView(
              controller: _scrollController,
              children: ListTile.divideTiles(
                  color: Colors.white30,
                  context: context,
                  tiles: data.map((MovieDetails detail) {
                    return _movieEntry(context, detail);
                  })
              ).toList()
          ),
          onNotification: (notification){
            if (notification is ScrollNotification) {
              widget._pageManager.scrollOffsetToRestore = notification.metrics.pixels;
            }
            return false;
          },
        );
      }
    });
  }

  Widget _posterImage(BuildContext context, bool isTv, String path, int id){
    return SizedBox(
      height: 162, width: 104,
      child: isTv ? wrapWithInkWellToDetail(context, ShowWidgetBuilder.buildImage(path), true, id) : ShowWidgetBuilder.buildImage(path),
    );
  }

  Widget wrapWithInkWellToDetail(BuildContext context, Widget child, bool isTv, int id) {
    return InkWell(
      child: child,
      onTap: () {
        if (!widget._pageManager.deleteMode) {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext _) {
                    return isTv ? TvDetailPage(id) : MovieDetailPage(id);
                  }
              )
          );
        }
      },
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

  Widget _movieEntry(BuildContext buildContext, MovieDetails movie){
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    widgetList.add(SizedBox(width: 12,));
    widgetList.add(_posterImage(buildContext, false, movie.posterPath, movie.id));
    widgetList.add(SizedBox(width: 8,));
    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text((movie.name?.isNotEmpty == true ? movie.name : movie.originalName) ?? '',
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
    if (widget._pageManager.deleteMode) {
      widgetList.add(_deleteModeDeleteButton(buildContext, false, movie.id));
      return Row(children: widgetList,);
    }
    return Builder(
      builder: (BuildContext c){
        return _dismissible(c, (_){
          Provider.of<MovieStateModel>(c, listen: false).removeMovie(movie.id);
          ScaffoldMessenger.of(c).showSnackBar(
              SnackBar(content: Text('Item removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    Provider.of<MovieStateModel>(context, listen: false).addMovie(movie);
                  },
                ),
              )
          );
        }, wrapWithInkWellToDetail(c, Row(children: widgetList,), false, movie.id), movie.id.toString());
      },
    );
  }

  Widget _tvEntry(BuildContext buildContext, TvDetails tv){
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    widgetList.add(SizedBox(width: 12,));
    widgetList.add(_posterImage(buildContext, true, tv.posterPath, tv.id));
    widgetList.add(SizedBox(width: 8,));
    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text((tv.name?.isNotEmpty == true ? tv.name : tv.originalName) ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 16.0,),
                ),
                SizedBox(height: 5,),
                _nextEpisodeText(tv),
                _progressRow(buildContext, tv)
              ],
            )
        )
    );
    widgetList.add(
        SizedBox(width: 5,)
    );
    if (widget._pageManager.deleteMode) {
      widgetList.add(_deleteModeDeleteButton(buildContext, true, tv.id));
      return Row(children: widgetList,);
    }
    return Builder(
        builder: (BuildContext c) {
          return _dismissible(c,
                  (_) {
                Provider.of<TvStateModel>(c, listen: false).removeTv(tv.id);
                ScaffoldMessenger.of(c).showSnackBar(
                    SnackBar(content: Text('Item removed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          Provider.of<TvStateModel>(context, listen: false).addTv(tv);
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
      color: Colors.red,
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
              TextButton(
                child: Text('Cancel'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Remove',
                  style: TextStyle(color: Colors.redAccent),),
                onPressed: (){
                  Navigator.of(context).pop();
                  if (isTv) {
                    Provider.of<TvStateModel>(context, listen: false).removeTv(id);
                  } else {
                    Provider.of<MovieStateModel>(context, listen: false).removeMovie(id);
                  }
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
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    if (!widget._pageManager.deleteMode) {
      widgetList.add(
          IconButton(
            icon: Icon(Icons.remove),
            color: Colors.white,
            disabledColor: Colors.grey,
            onPressed: isFirst
                ? null
                : (){
              tv.progress = tv.progress.previous(tv.seasons);
              Provider.of<TvStateModel>(context, listen: false).addTv(tv);
            },
          ));
    }
    if (widget._pageManager.deleteMode) {
      widgetList.add(Text(
        tv.progress.userReadable(),
        style: TextStyle(
          color: Colors.white,
        ),
      ));
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
      widgetList.add(GestureDetector(
        child: Text(
          tv.progress.userReadable(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onLongPress: (){
          _selectEpisode(context, tv);
        },
      ));
      widgetList.add(
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.white,
            disabledColor: Colors.grey,
            onPressed: isLast
                ? null
                : (){
              tv.progress = tv.progress.next(tv.seasons);
              Provider.of<TvStateModel>(context, listen: false).addTv(tv);
            },
          )
      );
    }

    return Row(children: widgetList);
  }

  _selectEpisode(BuildContext context, TvDetails tv){
    showDialog<WatchProgress>(context: context,
        barrierDismissible: true,
        builder: (context){
          return EpisodeSelectDialog.show(
            seasons: tv.seasons,
            currentProgress: tv.progress,
          );
        }
    ).then((progress){
      if (progress != null) {
        tv.progress = progress;
        Provider.of<TvStateModel>(context, listen: false).addTv(tv);
      }
    });
  }
}