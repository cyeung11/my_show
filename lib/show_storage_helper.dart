import 'dart:convert';

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

class ShowStorageHelper {
  SharedPreferences pref;

  List<TvDetails> watchTv;
  List<MovieDetails> savedMovie;
  List<Genre> tvGenres;
  List<Genre> movieGenres;

  ShowStorageHelper(this.pref) {
    if (pref.containsKey(PREF_SAVED_MOVIE)) {
      List<String> savedList = pref.getStringList(PREF_SAVED_MOVIE);
      savedMovie = savedList.map((string) => MovieDetails.fromJson(jsonDecode(string))).toList();
    } else {
      savedMovie = List<MovieDetails>();
    }

    if (pref.containsKey(PREF_WATCH_TV)) {
      List<String> savedList = pref.getStringList(PREF_WATCH_TV);
      watchTv = savedList.map((string) => TvDetails.fromJson(jsonDecode(string))).toList();
    } else {
      watchTv = List<TvDetails>();
    }

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

  Future<bool> addMovie(MovieDetails newMovie, {int index = -1}){
    if (!isMovieSaved(newMovie.id)) {
      if (index != -1 && index < watchTv.length) {
        savedMovie.insert(index, newMovie);
      } else {
        savedMovie.add(newMovie);
      }
      return saveMovies();
    }
    return Future.value(false);
  }

  Future<bool> removeMovie(int movieId){
    savedMovie.removeWhere((saved){
      return saved.id == movieId;
    });
    return saveMovies();
  }

  Future<bool> addTv(TvDetails newTv, {int index = -1}){
    if (!isTvSaved(newTv.id)) {
      if (index != -1 && index < watchTv.length) {
        watchTv.insert(index, newTv);
      } else {
        watchTv.add(newTv);
      }
      return saveTv();
    }
    return Future.value(false);
  }

  Future<bool> removeTv(int tvId){
    watchTv.removeWhere((saved){
      return saved.id == tvId;
    });
    return saveTv();
  }

  bool isMovieSaved(int movieId) {
    return savedMovie.firstWhere((saved) => saved.id == movieId, orElse: () => null) != null;
  }
  bool isTvSaved(int tvId) {
    return watchTv.firstWhere((saved) => saved.id == tvId, orElse: () => null) != null;
  }

  Future<bool> saveTv() {
    List<String> toSave = watchTv.map((tv) => jsonEncode(tv)).toList();
    return pref.setStringList(PREF_WATCH_TV, toSave);
  }

  Future<bool> saveMovies() {
    List<String> toSave = savedMovie.map((movie) => jsonEncode(movie)).toList();
    return pref.setStringList(PREF_SAVED_MOVIE, toSave);
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

}