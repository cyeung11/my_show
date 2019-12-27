import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_show/drive/drive_helper.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/storage/pref_helper.dart';

class ShowBackupHelper{
  
  static const String FILE_NAME_MOVIE = 'saved_movie';
  static const String FILE_NAME_TV = 'saved_tv';
  static const String FOLDER_NAME_BACKUP = 'backup';

  static Future<String> _createFolder(DriveHelper driveHelper) async {
    return await driveHelper.createFolder(FOLDER_NAME_BACKUP);
  }
  
  static Future<bool> backup(GoogleSignInAccount acc) async {
    var helper = await _assertInit(acc);
    var folderId = await _createFolder(helper);

    var m = await PrefHelper.instance.savedMovie;
    var savedMovie = jsonEncode(m.map((movie) => jsonEncode(movie)).toList());
    var movieId = await helper.uploadStringAsFile(FILE_NAME_MOVIE, folderId, savedMovie);

    var t = await PrefHelper.instance.watchTv;
    var savedTv = jsonEncode(t.map((tv) => jsonEncode(tv)).toList());
    var tvId = await helper.uploadStringAsFile(FILE_NAME_TV, folderId, savedTv);

    var backedUp = movieId?.isNotEmpty == true && tvId?.isNotEmpty == true;
    if (backedUp) {
      PrefHelper.instance.setInt(PREF_DRIVE_BACKUP_TIME, DateTime.now().millisecondsSinceEpoch);
    }
    return backedUp;
  }

  static Future<Backup> restore(GoogleSignInAccount acc) async {
    var helper = await _assertInit(acc);

    var backup = Backup();

    var folder = await helper.searchFile(FOLDER_NAME_BACKUP, mime: DriveHelper.FOLDER_MIME);

    var movieFile = await helper.searchFile(FILE_NAME_MOVIE, mime: DriveHelper.TEXT_MIME, folderId: folder?.id);
    if (movieFile?.id?.isNotEmpty == true){
      helper.downloadFileAsString(movieFile.id, (saved) {
        try {
          List<dynamic> parsed = jsonDecode(saved);
          if (parsed?.isNotEmpty == true) {
            var movies = parsed.map((s) => MovieDetails.fromJson(jsonDecode(s)));
            if (movies?.isNotEmpty == true) {
              backup.movies.addAll(movies);
            }
          }
        } catch (exception){
          print(exception);
        }
      });
    }

    var tvFile = await helper.searchFile(FILE_NAME_TV, mime: DriveHelper.TEXT_MIME, folderId: folder?.id);

    if (tvFile?.id?.isNotEmpty == true){
      helper.downloadFileAsString(tvFile.id, (saved) {
        try {
          List<dynamic> parsed = jsonDecode(saved);
          if (parsed?.isNotEmpty == true) {
            var tv = parsed.map((s) => TvDetails.fromJson(jsonDecode(s)));
            if (tv?.isNotEmpty == true) {
              backup.tv.addAll(tv);
            }
          }
        } catch (exception){
          print(exception);
        }
      });
    }

    return backup;
  }

  static Future<DriveHelper> _assertInit(GoogleSignInAccount acc) async{
    var headers = await acc.authHeaders;
    return DriveHelper(headers);
  }
}

class Backup{
  final tv = List<TvDetails>();
  final movies = List<MovieDetails>();
}