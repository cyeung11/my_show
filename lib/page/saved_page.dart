import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class SavedPage extends StatefulWidget{

  final ShowStorageHelper pref;

  SavedPage({@required this.pref, Key key}): super(key: key);

  @override
  State createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage>{

  bool _deleteMode = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_deleteMode){
          setState(() {
            _deleteMode = false;
          });
          return Future.value(false);
        } else return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          title: Text(
            'Saved',
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
              icon: Icon(_deleteMode ? Icons.done : Icons.delete),
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
    var list = widget.pref.savedShow;
    return ListView(
        children: ListTile.divideTiles(
            color: Colors.white30,
            context: context,
            tiles: list.map((Show currentMovie){
              return buildMovieEntry(currentMovie);
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

  Widget buildMovieEntry(Show movie){
    List<Widget> widgetList = List<Widget>();
    widgetList.add(SizedBox(
      height: 156, width: 104,
      child:  getPoster(movie.poster),
    ));
    widgetList.add(
        SizedBox(width: 8,)
    );
    widgetList.add(
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (movie.title ?? movie.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  ((movie.release ?? movie.firstAir) ?? ''),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
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
            color: Colors.red,
            onPressed: (){
              _showRemoveDialog(movie);
            },
          )
      );
    }

    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: widgetList,
        ),
      ),
      onTap: () {
        if (_deleteMode) {
          _showRemoveDialog(movie);
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext _) {
                    return movie.isMovie()
                        ? MovieDetailPage(id: movie.id)
                        : TvDetailPage(id: movie.id,);
                  }
              )
          );
        }
      },
    );
  }

  _showRemoveDialog(Show movie){
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
                    widget.pref.removeShow(movie.id);
                  });
                },
              ),
            ],
          );
        }
    );
  }
}