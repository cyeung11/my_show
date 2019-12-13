import 'dart:convert';

import 'package:my_show/model/show.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_SAVED_SHOW = "saved_show";
const String PREF_WATCH_TV = "watched_tv";

class ShowStorageHelper {
  SharedPreferences pref;

  List<TvDetails> watchTv;
  List<Show> savedShow;

  ShowStorageHelper(this.pref) {
    savedShow = _getShows(PREF_SAVED_SHOW) ?? List<Show>();
    watchTv = _getTv(PREF_WATCH_TV) ?? List<TvDetails>();
  }

  addShow(Show newShow){
    if (!isShowSaved(newShow.id)) {
      savedShow.add(newShow);
      _saveShows();
    }
  }

  removeShow(int showId){
    savedShow.removeWhere((saved){
      return saved.id == showId;
    });
    _saveShows();
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

  bool isShowSaved(int showId) {
    return savedShow.firstWhere((saved) => saved.id == showId, orElse: () => null) != null;
  }
  bool isTvSaved(int tvId) {
    return watchTv.firstWhere((saved) => saved.id == tvId, orElse: () => null) != null;
  }

  saveTv() {
    List<String> toSave = watchTv.map((tv) => jsonEncode(tv)).toList();
    pref.setStringList(PREF_WATCH_TV, toSave);
  }

  _saveShows() {
    List<String> toSave = savedShow.map((show) => jsonEncode(show)).toList();
    pref.setStringList(PREF_SAVED_SHOW, toSave);
  }

  List<Show> _getShows(String key){
    if (pref.containsKey(key)) {
      List<String> savedList = pref.getStringList(key);
      List<Show> shows = savedList.map((string) => Show.fromMap(jsonDecode(string))).toList();
      return shows;
    } else {
      return null;
    }
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

}