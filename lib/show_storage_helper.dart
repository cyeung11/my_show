import 'dart:convert';

import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_SAVED_MOVIE = "saved_movie";
const String PREF_WATCH_TV = "watched_tv";

class ShowStorageHelper {
  SharedPreferences pref;

  List<TvDetails> watchTv;
  List<MovieDetails> savedMovie;

  ShowStorageHelper(this.pref) {
    savedMovie = _getMovie(PREF_SAVED_MOVIE) ?? List<MovieDetails>();
    watchTv = _getTv(PREF_WATCH_TV) ?? List<TvDetails>();
  }

  addShow(MovieDetails newMovie, {int index = -1}){
    if (!isMovieSaved(newMovie.id)) {
      if (index != -1 && index < watchTv.length) {
        savedMovie.insert(index, newMovie);
      } else {
        savedMovie.add(newMovie);
      }
      _saveMovies();
    }
  }

  removeShow(int movieId){
    savedMovie.removeWhere((saved){
      return saved.id == movieId;
    });
    _saveMovies();
  }

  addTv(TvDetails newTv, {int index = -1}){
    if (!isTvSaved(newTv.id)) {
      if (index != -1 && index < watchTv.length) {
        watchTv.insert(index, newTv);
      } else {
        watchTv.add(newTv);
      }
      saveTv();
    }
  }

  removeTv(int tvId){
    watchTv.removeWhere((saved){
      return saved.id == tvId;
    });
    saveTv();
  }

  bool isMovieSaved(int movieId) {
    return savedMovie.firstWhere((saved) => saved.id == movieId, orElse: () => null) != null;
  }
  bool isTvSaved(int tvId) {
    return watchTv.firstWhere((saved) => saved.id == tvId, orElse: () => null) != null;
  }

  saveTv() {
    List<String> toSave = watchTv.map((tv) => jsonEncode(tv)).toList();
    pref.setStringList(PREF_WATCH_TV, toSave);
  }

  _saveMovies() {
    List<String> toSave = savedMovie.map((movie) => jsonEncode(movie)).toList();
    pref.setStringList(PREF_SAVED_MOVIE, toSave);
  }

  List<TvDetails> _getTv(String key){
    if (pref.containsKey(key)) {
      List<String> savedList = pref.getStringList(key);
      List<TvDetails> tv = savedList.map((string) => TvDetails.fromJson(jsonDecode(string))).toList();
      return tv;
    } else {
      return null;
    }
  }

  List<MovieDetails> _getMovie(String key){
    if (pref.containsKey(key)) {
      List<String> savedList = pref.getStringList(key);
      List<MovieDetails> movies = savedList.map((string) => MovieDetails.fromMap(jsonDecode(string))).toList();
      return movies;
    } else {
      return null;
    }
  }

}