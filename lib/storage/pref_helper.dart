
import 'package:flutter/widgets.dart';
import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/state/movie_state_model.dart';
import 'package:my_show/state/tv_state_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_SAVED_MOVIE = "saved_movie";
const String PREF_WATCH_TV = "watched_tv";

const String PREF_TV_GENRE = "tv_genre";
const String PREF_MOVIE_GENRE = "movie_genre";
const String PREF_TV_GENRE_UPDATE_TIME = "tv_genre_update_time";
const String PREF_MOVIE_GENRE_UPDATE_TIME = "movie_genre_update_time";


const String PREF_DRIVE_USER_NAME = "drive_user_name";
const String PREF_DRIVE_BACKUP_TIME = "drive_backup_time";

class PrefHelper {
  SharedPreferences pref;

  static PrefHelper instance;

  static Future<void> init() async{
    if (instance == null) {
      var pref = await SharedPreferences.getInstance();
      instance = PrefHelper(pref);
    }
  }

  PrefHelper(this.pref);

  restore(BuildContext context, Backup backup) {
    if (backup.movies != null) {
      Provider.of<MovieStateModel>(context, listen: false).restore(backup.movies);
    }
    if (backup.tv != null) {
      Provider.of<TvStateModel>(context, listen: false).restore(backup.tv);
    }
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

  Future<bool> setIntList(String key, List<int> value){
    if (value != null) {
      return pref.setStringList(key, value.map((i) => i.toString()).toList());
    } else {
      return pref.remove(key);
    }
  }

  List<int> getIntList(String key){
    return pref.getStringList(key)?.map((string) => (int.tryParse(string) ?? 0))?.toList();
  }
}