import 'package:flutter/foundation.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/storage/pref_helper.dart';

class MovieStateModel extends ChangeNotifier {

  Set<int> _watchMovieIds = PrefHelper.instance.getIntList(PREF_SAVED_MOVIE)?.toSet() ?? Set<int>();

  List<MovieDetails> _watchMovieList = List.empty(growable: true);

  Future<List<MovieDetails>> getUpdateWatchMovie() async {
    _watchMovieList = await MovieDetails.allIn(_watchMovieIds.toList());

    _watchMovieList.forEach((m) {
      if (m.isExpired) {
        getMovieDetail(m.id).then((result) {
          result.insert();
          var index = _watchMovieList.indexWhere((saved) => m.id == saved.id);
          if (index != -1) {
            _watchMovieList[index] = result;
            notifyListeners();
          }
        });
      }
    });

    notifyListeners();

    return _watchMovieList;
  }

  List<MovieDetails> get watchMovie => _watchMovieList;

  void addMovie(MovieDetails newMovie){
    newMovie.insert();
    _watchMovieIds.add(newMovie.id);
    PrefHelper.instance.setIntList(PREF_SAVED_MOVIE, _watchMovieIds.toList());

    MovieDetails.allIn(_watchMovieIds.toList()).then((value){
      _watchMovieList = value;
      notifyListeners();
    });
  }

  void removeMovie(int movieId){
    if (_watchMovieIds.remove(movieId)){
      PrefHelper.instance.setIntList(PREF_SAVED_MOVIE, _watchMovieIds.toList());

      MovieDetails.allIn(_watchMovieIds.toList()).then((value){
        _watchMovieList = value;
        notifyListeners();
      });
    }
  }

  bool isMovieSaved(int movieId) {
    return _watchMovieIds.contains(movieId);
  }

  void restore(List<MovieDetails> movies) {
    _watchMovieIds.addAll(movies.map((m) => m.id));
    PrefHelper.instance.setIntList(PREF_SAVED_MOVIE, _watchMovieIds.toList());
    MovieDetails.insertAll(movies);

    MovieDetails.allIn(_watchMovieIds.toList()).then((value){
      _watchMovieList = value;
      notifyListeners();
    });
  }
}