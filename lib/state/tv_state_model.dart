import 'package:flutter/foundation.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/storage/pref_helper.dart';

class TvStateModel extends ChangeNotifier {

  Set<int> _watchTvIds = PrefHelper.instance.getIntList(PREF_WATCH_TV)?.toSet() ?? Set<int>();

  List<TvDetails> _watchTvList = List.empty(growable: true);

  Future<List<TvDetails>> getUpdatedWatchTv() async {
    _watchTvList = await TvDetails.allIn(_watchTvIds.toList());

    _watchTvList.forEach((t) {
      if (t.isExpired) {
        getTVDetail(t.id).then((result) {
          result.insert();
          var index = _watchTvList.indexWhere((saved) => t.id == saved.id);
          if (index != -1) {
            _watchTvList[index] = result;
            notifyListeners();
          }
        });
      }
    });

    notifyListeners();

    return _watchTvList;
  }

  List<TvDetails> get watchTv => _watchTvList;

  void addTv(TvDetails newTv){
    newTv.insert();
    _watchTvIds.add(newTv.id);
    PrefHelper.instance.setIntList(PREF_WATCH_TV, _watchTvIds.toList());

    TvDetails.allIn(_watchTvIds.toList()).then((value){
      _watchTvList = value;
      notifyListeners();
    });
  }

  void removeTv(int tvId){
    if (_watchTvIds.remove(tvId)){
      PrefHelper.instance.setIntList(PREF_WATCH_TV, _watchTvIds.toList());

      TvDetails.allIn(_watchTvIds.toList()).then((value){
        _watchTvList = value;
        notifyListeners();
      });
    }
  }

  bool isTvSaved(int tvId) {
    return _watchTvIds.contains(tvId);
  }

  void restore(List<TvDetails> tvs) {
    _watchTvIds.addAll(tvs.map((t) => t.id));
    PrefHelper.instance.setIntList(PREF_WATCH_TV, _watchTvIds.toList());
    TvDetails.insertAll(tvs);

    TvDetails.allIn(_watchTvIds.toList()).then((value){
      _watchTvList = value;
      notifyListeners();
    });
  }
}