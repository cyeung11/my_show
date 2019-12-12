import 'package:flutter/material.dart';
import 'package:my_show/model/season.dart';

import 'model/watch_progress.dart';

class EpisodeSelectDialog extends StatelessWidget {
  final List<WatchProgress> selectable = List<WatchProgress>();

  final ValueChanged<WatchProgress> onEpisodeSelected;

  EpisodeSelectDialog({@required List<Season> seasons, @required this.onEpisodeSelected, Key key}): super(key: key){
    int episodeTotalNo = 0;
    seasons.forEach((season) {
      var seasonNo = season.seasonNo ?? 0;
      if (seasonNo != 0) {
        selectable.add(WatchProgress(seasonNo, -1, -1));
        var list = List<WatchProgress>.generate(season.episodeCount ?? 0, (i) {
          episodeTotalNo++;
          return WatchProgress(seasonNo, i + 1, episodeTotalNo);
        });
        selectable.addAll(list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 1.0,
      backgroundColor: Colors.white,
      child: ListView(
          children: ListTile.divideTiles(
              color: Colors.black54,
              context: context,
              tiles: selectable.map((WatchProgress episodeSelectable){
                var isEpisode = episodeSelectable.totalEpisode != -1;
                return InkWell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(isEpisode ? episodeSelectable.userReadable() : "Season ${episodeSelectable.seasonNo}",
                      style: TextStyle(
                          fontSize: isEpisode ? 15 : 17,
                          fontWeight: isEpisode ? FontWeight.normal : FontWeight.bold
                      ),
                    ),
                  ),
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
}
