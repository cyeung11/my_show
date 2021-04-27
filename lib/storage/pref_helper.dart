import 'dart:convert';

import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/genre.dart';
import '../network/api_constant.dart';
import '../network/network_call.dart';

const String _PREF_SAVED_MOVIE = "saved_movie";
const String _PREF_WATCH_TV = "watched_tv";
const String _PREF_TV_GENRE = "tv_genre";
const String _PREF_MOVIE_GENRE = "movie_genre";

const String PREF_DRIVE_USER_NAME = "drive_user_name";
const String PREF_DRIVE_BACKUP_TIME = "drive_backup_time";

class PrefHelper {
  SharedPreferences _pref;

  static PrefHelper instance;

  Future<List<TvDetails>> get watchTv => TvDetails.allIn(_watchTvIds.toList());
  Future<List<MovieDetails>> get savedMovie => MovieDetails.allIn(_savedMovieIds.toList());

  Set<int> _watchTvIds;
  Set<int> _savedMovieIds;

  List<Genre> tvGenres;
  List<Genre> movieGenres;

  static Future<void> init() async{
    if (instance == null) {
      var pref = await SharedPreferences.getInstance();
      instance = PrefHelper(pref);
    }
  }

  PrefHelper(this._pref) {
    _savedMovieIds = getIntList(_PREF_SAVED_MOVIE)?.toSet() ?? Set<int>();
    _watchTvIds = getIntList(_PREF_WATCH_TV)?.toSet() ?? Set<int>();

    tvGenres = _getGenre(_PREF_TV_GENRE);
    if (tvGenres.isEmpty) {
      getGenre(GET_TV_GENRE).then((data){
        if (data?.genres != null) {
          saveTVGenre(data.genres);
        }
      });
    }
    movieGenres = _getGenre(_PREF_MOVIE_GENRE);
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
      _savedMovieIds.addAll(backup.movies.map((m) => m.id));
      setIntList(_PREF_SAVED_MOVIE, _savedMovieIds.toList());
      MovieDetails.insertAll(backup.movies);
    }
    if (backup.tv != null) {
      _watchTvIds.addAll(backup.tv.map((t) => t.id));
      setIntList(_PREF_WATCH_TV, _watchTvIds.toList());
      TvDetails.insertAll(backup.tv);
    }
  }

  Future<bool> addMovie(MovieDetails newMovie){
    newMovie.insert();
    _savedMovieIds.add(newMovie.id);
    return setIntList(_PREF_SAVED_MOVIE, _savedMovieIds.toList());
  }

  Future<bool> removeMovie(int movieId){
    if (_savedMovieIds.remove(movieId)){
      return setIntList(_PREF_SAVED_MOVIE, _savedMovieIds.toList());
    } else {
      return Future.value(false);
    }
  }

  Future<bool> addTv(TvDetails newTv){
    newTv.insert();
    _watchTvIds.add(newTv.id);
    return setIntList(_PREF_WATCH_TV, _watchTvIds.toList());
  }

  Future<bool> removeTv(int tvId){
    if (_watchTvIds.remove(tvId)){
      return setIntList(_PREF_WATCH_TV, _watchTvIds.toList());
    } else {
      return Future.value(false);
    }
  }

  bool isMovieSaved(int movieId) {
    return _savedMovieIds.contains(movieId);
  }
  bool isTvSaved(int tvId) {
    return _watchTvIds.contains(tvId);
  }

  saveTVGenre(List<Genre> genres){
    tvGenres = genres;
    _saveGenre(genres, _PREF_TV_GENRE);
  }
  saveMovieGenre(List<Genre> genres){
    movieGenres = genres;
    _saveGenre(genres, _PREF_MOVIE_GENRE);
  }
  _saveGenre(List<Genre> genres, String key){
    List<String> toSave = genres.map((genre) => jsonEncode(genre)).toList();
    _pref.setStringList(key, toSave);
  }

  List<Genre> _getGenre(String key){
    if (_pref.containsKey(key)) {
      List<String> savedList = _pref.getStringList(key);
      return savedList.map((string) => Genre.fromMap(jsonDecode(string))).toList();
    } else {
      return List<Genre>.empty(growable: true);
    }
  }

  setString(String key, String value){
    if (value?.isNotEmpty == true) {
      _pref.setString(key, value);
    } else {
      _pref.remove(key);
    }
  }

  setInt(String key, int value){
    if (value != null) {
      _pref.setInt(key, value);
    } else {
      _pref.remove(key);
    }
  }

  String getString(String key){
    return _pref.getString(key);
  }

  int getInt(String key, {int defaultValue}){
    return _pref.getInt(key) ?? defaultValue;
  }

  Future<bool> setIntList(String key, List<int> value){
    if (value != null) {
      return _pref.setStringList(key, value.map((i) => i.toString()).toList());
    } else {
      return _pref.remove(key);
    }
  }

  List<int> getIntList(String key){
    return _pref.getStringList(key)?.map((string) => (int.tryParse(string) ?? 0))?.toList();
  }
}