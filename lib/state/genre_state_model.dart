import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/storage/pref_helper.dart';

const _GENRE_TIME_OUT = 86400000;

class GenreStateModel extends ChangeNotifier {

  List<Genre> _tvGenres;
  List<Genre> _movieGenres;


  List<Genre> getTvGenre()  {
    if (_tvGenres == null || _tvGenres.isEmpty){

      if (PrefHelper.instance.pref.containsKey(PREF_TV_GENRE)) {
        List<String> savedList = PrefHelper.instance.pref.getStringList(PREF_TV_GENRE);
        _tvGenres = savedList.map((string) => Genre.fromMap(jsonDecode(string))).toList();
        notifyListeners();
      }
    }

    int lastUpdate = PrefHelper.instance.getInt(PREF_TV_GENRE_UPDATE_TIME, defaultValue: -1);
    if (lastUpdate == null || DateTime.now().millisecondsSinceEpoch - lastUpdate > _GENRE_TIME_OUT) {
      updateTvGenre();
    }

    return _tvGenres ?? List.empty(growable: true);
  }

  List<Genre> getMovieGenre()  {
    if (_movieGenres == null || _movieGenres.isEmpty){

      if (PrefHelper.instance.pref.containsKey(PREF_MOVIE_GENRE)) {
        List<String> savedList = PrefHelper.instance.pref.getStringList(PREF_MOVIE_GENRE);
        _movieGenres = savedList.map((string) => Genre.fromMap(jsonDecode(string))).toList();
        notifyListeners();
      }
    }

    int lastUpdate = PrefHelper.instance.getInt(PREF_MOVIE_GENRE_UPDATE_TIME, defaultValue: -1);
    if (lastUpdate == null || DateTime.now().millisecondsSinceEpoch - lastUpdate > _GENRE_TIME_OUT) {
      updateMovieGenre();
    }

    return _movieGenres ?? List.empty(growable: true);
  }

  void updateTvGenre(){
    getGenre(GET_TV_GENRE).then((data){
      if (data?.genres != null) {

        List<String> toSave = data.genres.map((genre) => jsonEncode(genre)).toList();
        PrefHelper.instance.pref.setStringList(PREF_TV_GENRE, toSave);
        PrefHelper.instance.setInt(PREF_TV_GENRE_UPDATE_TIME, DateTime.now().millisecondsSinceEpoch);

        _tvGenres = data.genres;

        notifyListeners();
      }
    });
  }


  void updateMovieGenre(){
    getGenre(GET_MOVIE_GENRE).then((data){
      if (data?.genres != null) {

        List<String> toSave = data.genres.map((genre) => jsonEncode(genre)).toList();

        PrefHelper.instance.pref.setStringList(PREF_MOVIE_GENRE, toSave);
        PrefHelper.instance.setInt(PREF_MOVIE_GENRE_UPDATE_TIME, DateTime.now().millisecondsSinceEpoch);

        _movieGenres = data.genres;

        notifyListeners();
      }
    });
  }


}