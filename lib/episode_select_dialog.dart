import 'package:flutter/material.dart';
import 'package:my_show/model/season.dart';

import 'model/watch_progress.dart';

class EpisodeSelectDialog extends StatelessWidget {
  final List<WatchProgress> selectable;

  final ValueChanged<WatchProgress> onEpisodeSelected;

  final WatchProgress currentProgress;

  final int scrollIndex;

  final ScrollController _scrollController = ScrollController();

  EpisodeSelectDialog({@required this.selectable, @required this.scrollIndex, @required this.currentProgress, @required this.onEpisodeSelected, Key key}): super(key: key);

  factory EpisodeSelectDialog.show({@required List<Season> seasons, WatchProgress currentProgress, @required ValueChanged<WatchProgress> onEpisodeSelected, Key key}){
    List<WatchProgress> selectableList = List<WatchProgress>();
    int scroll = 0;

    int episodeTotalNo = 0;
    seasons.forEach((season) {
      var seasonNo = season.seasonNo ?? 0;
      if (seasonNo != 0) {
        selectableList.add(WatchProgress(seasonNo, -1, -1)); // Season separator

        var list = List<WatchProgress>.generate(season.episodeCount ?? 0, (i) {
          episodeTotalNo++;
          return WatchProgress(seasonNo, i + 1, episodeTotalNo);
        });

        if (currentProgress != null && seasonNo == currentProgress.seasonNo) {
          if (currentProgress.episodeNo <= season.episodeCount) {
            scroll = selectableList.length + currentProgress.episodeNo;
          }
        }

        selectableList.addAll(list);
      }
    });

    if (scroll >= 4) {
      scroll -= 4;
    } else {
      scroll = 0;
    }

    return EpisodeSelectDialog(selectable: selectableList, scrollIndex: scroll, currentProgress: currentProgress, onEpisodeSelected: onEpisodeSelected, key: key,);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      _scrollController.animateTo((45.0 * scrollIndex) - _scrollController.offset,
          curve: Curves.easeIn, duration: Duration(milliseconds: 500));
    });
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 1.0,
      backgroundColor: Colors.white,
      child: ListView(
          controller: _scrollController,
          children: ListTile.divideTiles(
              color: Colors.black54,
              context: context,
              tiles: selectable.map((WatchProgress episodeSelectable){
                var isEpisode = episodeSelectable.totalEpisode != -1;
                return InkWell(
                  child: buildSelectable(isEpisode, episodeSelectable),
                  onTap:
                  isEpisode
                      ? (){
                    Navigator.of(context).pop();
                    onEpisodeSelected(episodeSelectable);
                  }
                      : null,
                );
              })
          ).toList()),
    );
  }

  Widget buildSelectable(bool isEpisode, WatchProgress episodeSelectable){
    if (!isEpisode) {
      return SizedBox(
        height: 45,
        child: Center(
          child: Text(isEpisode ? episodeSelectable.userReadable() : "Season ${episodeSelectable.seasonNo}",
              style: TextStyle(
                  fontSize: isEpisode ? 15 : 17,
                  fontWeight: isEpisode ? FontWeight.normal : FontWeight.bold
              )
          ),
        ),
      );
    }

    var result = List<Widget>();
    result.add(SizedBox(width: 10));
    result.add(Container(
      height: 45,
      child: Center(
        child: Text(isEpisode ? episodeSelectable.userReadable() : "Season ${episodeSelectable.seasonNo}",
          style: TextStyle(
              fontSize: isEpisode ? 15 : 17,
              fontWeight: isEpisode ? FontWeight.normal : FontWeight.bold
          ),
        ),
      ),
    ));
    if (currentProgress.episodeNo == episodeSelectable.episodeNo && currentProgress.seasonNo == episodeSelectable.seasonNo) {
      result.add(Spacer());
      result.add(Icon(Icons.check));
      result.add(SizedBox(width: 10));
    }

    return Row(
      children: result,
    );
  }
}
