import 'dart:convert';

import 'package:my_show/model/show.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_SAVED_SHOW = "saved_show";

class ShowStorageHelper {
  SharedPreferences pref;

  Set<Show> _savedShow;
  List<Show> getSaved() => _savedShow.toList();

  ShowStorageHelper(this.pref) {
    _savedShow = _getShows(PREF_SAVED_SHOW) ?? Set<Show>();
  }

  addShow(Show newShow){
    _savedShow.add(newShow);
    _saveShows();
  }

  bool removeShow(Show show){
    if (isShowSaved(show)) {
      _savedShow.remove(show);
      _saveShows();
      return true;
    } else {
      return false;
    }
  }
  
  bool isShowSaved(Show show) {
    return _savedShow.firstWhere((saved) => saved.id == show.id, orElse: () => null) != null;
  }

  _saveShows() {
    List<String> toSave = _savedShow.map((show) => jsonEncode(show)).toList();
    pref.setStringList(PREF_SAVED_SHOW, toSave);
  }

  Set<Show> _getShows(String key){
    if (pref.containsKey(key)) {
      List<String> savedList = pref.getStringList(key);
      List<Show> shows = savedList.map((string) => Show.fromMap(jsonDecode(string))).toList();
      return shows.toSet();
    } else {
      return null;
    }
  }

}