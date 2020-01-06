import 'dart:convert';

import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/genre.dart';
import 'network/api_constant.dart';
import 'network/network_call.dart';

const String PREF_SAVED_MOVIE = "saved_movie";
const String PREF_WATCH_TV = "watched_tv";

const String PREF_TV_GENRE = "tv_genre";
const String PREF_MOVIE_GENRE = "movie_genre";

const String PREF_DRIVE_USER_NAME = "drive_user_name";
const String PREF_DRIVE_BACKUP_TIME = "drive_backup_time";

class StorageHelper {
  SharedPreferences pref;

  Future<List<TvDetails>> get watchTv => TvDetails.all();
  Future<List<MovieDetails>> get savedMovie => MovieDetails.all();
  List<Genre> tvGenres;
  List<Genre> movieGenres;

  StorageHelper(this.pref) {
    tvGenres = getTvGenre();
    if (tvGenres.isEmpty) {
      getGenre(GET_TV_GENRE).then((data){
        if (data?.genres != null) {
          saveTVGenre(data.genres);
        }
      });
    }
    movieGenres = getMovieGenre();
    if (movieGenres.isEmpty) {
      getGenre(GET_MOVIE_GENRE).then((data){
        if (data?.genres != null) {
          saveMovieGenre(data.genres);
        }
      });
    }
  }

  restore(Backup backup) {
    if (backup.movies != null) {
      MovieDetails.insertAll(backup.movies);
    }
    if (backup.tv != null) {
      TvDetails.insertAll(backup.tv);
    }
  }

  Future<void> addMovie(MovieDetails newMovie){
    return newMovie.insert();
  }

  Future<void> removeMovie(int movieId){
    return MovieDetails.delete(movieId);
  }

  Future<void> addTv(TvDetails newTv){
    return newTv.insert();
  }

  Future<void> removeTv(int tvId){
    return TvDetails.delete(tvId);
  }

  Future<bool> isMovieSaved(int movieId) async {
    return await MovieDetails.getById(movieId) != null;
  }
  Future<bool> isTvSaved(int tvId) async {
    return await TvDetails.getById(tvId) != null;
  }

  saveTVGenre(List<Genre> genres){
    tvGenres = genres;
    _saveGenre(genres, PREF_TV_GENRE);
  }
  saveMovieGenre(List<Genre> genres){
    movieGenres = genres;
    _saveGenre(genres, PREF_MOVIE_GENRE);
  }
  _saveGenre(List<Genre> genres, String key){
    List<String> toSave = genres.map((genre) => jsonEncode(genre)).toList();
    pref.setStringList(key, toSave);
  }

  List<Genre> _getGenre(String key){
    if (pref.containsKey(key)) {
      List<String> savedList = pref.getStringList(key);
      return savedList.map((string) => Genre.fromMap(jsonDecode(string))).toList();
    } else {
      return List<Genre>();
    }
  }
  List<Genre> getTvGenre(){
    return _getGenre(PREF_TV_GENRE);
  }
  List<Genre> getMovieGenre(){
    return _getGenre(PREF_MOVIE_GENRE);
  }

  setString(String key, String value){
    if (value?.isNotEmpty == true) {
      pref.setString(key, value);
    } else {
      pref.remove(key);
    }
  }

  setInt(String key, int value){
    if (value != null) {
      pref.setInt(key, value);
    } else {
      pref.remove(key);
    }
  }

  String getString(String key){
    return pref.getString(key);
  }

  int getInt(String key, {int defaultValue}){
    return pref.getInt(key) ?? defaultValue;
  }

}