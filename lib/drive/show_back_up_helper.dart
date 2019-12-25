import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_show/drive/drive_helper.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/show_storage_helper.dart';

class ShowBackupHelper{
  
  static const String FILE_NAME_MOVIE = 'saved_movie';
  static const String FILE_NAME_TV = 'saved_tv';

  GoogleSignInAccount _acc;
  
  ShowStorageHelper _pref;
  
  DriveHelper _driveHelper;
  
  ShowBackupHelper(this._acc, this._pref);
  
  
  Future<void> backup() async {
    if (_driveHelper == null) {
      var headers = await _acc.authHeaders;
      _driveHelper = DriveHelper(headers);
    }

    var savedMovie = jsonEncode(_pref.savedMovie.map((tv) => jsonEncode(tv)).toList());
    _driveHelper.uploadStringAsFile(FILE_NAME_MOVIE, savedMovie);
  }

  Future<void> restore() async {
    if (_driveHelper == null) {
      var headers = await _acc.authHeaders;
      _driveHelper = DriveHelper(headers);
    }

    var id = await _driveHelper.searchFile(FILE_NAME_MOVIE);
    if (id?.isNotEmpty == true){
      var savedString = await _driveHelper.downloadFileAsString(id);
      List<String> parsed = jsonDecode(savedString);
      var movies = parsed.map((s) => MovieDetails.fromJson(jsonDecode(s)));
      movies.forEach((m) {
        _pref.addMovie(m);
      });
    }
  }
  
}