import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/movie_details_page.dart';
import 'package:my_show/page/tv_details_page.dart';
import 'package:my_show/storage/pref_helper.dart';

import '../asset_path.dart';

class ShowWidgetBuilder {

  static Widget buildImage(String path){
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

  static Widget buildShowEntry(BuildContext context, Show show, {bool forPeople = false, List<Widget> extraText}){
    var entryDetails = List<Widget>.empty(growable: true);
    var name = show.title ?? show.name;
    if (forPeople) {
      name = name + (show.isMovie() ? ' (Movie)' : ' (TV)');
    }
    entryDetails.add(Text(
      name,
      style: TextStyle(
        color: Colors.white,
        fontSize: 17.0,
      ),
    ));
    entryDetails.add(SizedBox(height: 8));

    if (!forPeople) {
      List<Genre> genreList = show.isMovie() ? PrefHelper.instance.movieGenres : PrefHelper.instance.tvGenres;
      var stringBuilder = StringBuffer();
      show.genres.forEach((g){
        var match = genreList.firstWhere((all) => all.id == g, orElse: () => null);
        if (match?.name?.isNotEmpty == true) {
          if (stringBuilder.isNotEmpty) {
            stringBuilder.write(', ');
          }
          stringBuilder.write(match.name);
        }
      });
      entryDetails.add(Text(stringBuilder.toString(),
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          )
      ));
      entryDetails.add(SizedBox(height: 5));
    }

    var date =  show.isMovie() ? (show.release ?? '') : (show.firstAir?.isNotEmpty == true ? 'Since: ${show.firstAir}' : '');
    if (date.isNotEmpty == true) {
      entryDetails.add(Text(
            date,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ));
      entryDetails.add(SizedBox(height: 8));
    }
    if (!forPeople && (show.votePoint ?? 0) != 0){
      MaterialColor color;
      if (show.votePoint >= 6.5)
        color = Colors.green;
      else if (show.votePoint >= 4)
        color = Colors.yellow;
      else
        color = Colors.red;

      entryDetails.add(RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(text: show.votePoint.toString(), style: TextStyle(fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16.0,)),
            TextSpan(text: ' / 10', style: TextStyle(
              color: Colors.grey,
              fontSize: 10.0,
            ))
          ],
        ),
      ));
    }
    if (extraText?.isNotEmpty == true) {
      entryDetails.addAll(extraText);
    }

    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 156, width: 104,
              child:  buildImage(show.poster),
            ),
            SizedBox(width: 8,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entryDetails,
                )
            ),
            SizedBox(width: 5,),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext _) {
                  return show.isMovie() ? MovieDetailPage(show.id) : TvDetailPage(show.id);
                }
            )
        );
      },
    );
  }

}