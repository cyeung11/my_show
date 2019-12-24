import 'package:my_show/pageview_page/page_manager/page_manager.dart';

import '../../show_storage_helper.dart';

class SavedPageManager extends ScrollablePageManager{

  bool deleteMode = false;

  bool needSave = false;

  final ShowStorageHelper _pref;

  SavedPageManager(this._pref);

  saveToStorage(){
    if (needSave) {
      _pref.saveTv().whenComplete((){
        needSave = false;
      });
    }
  }
}