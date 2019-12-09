import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/movie_details_page.dart';

import '../asset_path.dart';
import '../show_storage_helper.dart';

class SavedPage extends StatefulWidget{

  final ShowStorageHelper pref;

  SavedPage({@required this.pref, Key key}): super(key: key);

  @override
  State createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: buildSaveList(),
      ),
    );
  }

  Widget buildSaveList(){
    var list = widget.pref.getSaved();
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
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 156, width: 104,
              child:  getPoster(movie.poster),
            ),
            SizedBox(width: 8,),
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
            ),
            SizedBox(width: 5,),
            IconButton(
              icon: Icon(widget.pref.isShowSaved(movie) ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 30,),
              onPressed: (){
                setState(() {
                  if (widget.pref.isShowSaved(movie)) {
                    widget.pref.removeShow(movie);
                  } else {
                    widget.pref.addShow(movie);
                  }
                });
              },
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext _) {
                  return MovieDetailPage(id: movie.id);
                }
            )
        );
      },
    );
  }
}