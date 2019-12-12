import 'package:my_show/model/season.dart';

class WatchProgress {
  int episodeNo;
  int seasonNo;
  int totalEpisode;

  WatchProgress(this.episodeNo, this.seasonNo, this.totalEpisode);

  factory WatchProgress.fromMap(Map<String, dynamic> json) {
    return WatchProgress(
      json['episodeNo'],
      json['seasonNo'],
      json['totalEpisode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['episodeNo'] = this.episodeNo;
    data['seasonNo'] = this.seasonNo;
    data['totalEpisode'] = this.totalEpisode;
    return data;
  }

  String userReadable() => "   S$seasonNo E$episodeNo ($totalEpisode)";

  WatchProgress next(List<Season> seasonsInfo) {
    var currentSeason = seasonsInfo.firstWhere((season) => season.seasonNo == seasonNo, orElse: ()=> null);
    if (currentSeason != null) {
      var isLastEpisodeInTheSeason = currentSeason.episodeCount == episodeNo;
      if (isLastEpisodeInTheSeason) {
        var nextSeason = seasonsInfo.firstWhere((season) => season.seasonNo == seasonNo + 1, orElse: ()=> null);
        if (nextSeason != null) {
          return WatchProgress(nextSeason.seasonNo, 1, totalEpisode + 1);
        }
      } else {
        return WatchProgress(seasonNo, episodeNo + 1, totalEpisode + 1);
      }
    }
    return null;
  }

  WatchProgress previous(List<Season> seasonsInfo) {
    if (episodeNo != 1 || seasonNo != 1) {
      if (episodeNo != 1) {
        return WatchProgress(seasonNo, episodeNo - 1, totalEpisode -1);
      } else {
        var lastSeason = seasonsInfo.firstWhere((season) => season.seasonNo == seasonNo - 1, orElse: ()=> null);
        if (lastSeason != null) {
          return WatchProgress(seasonNo - 1, lastSeason.episodeCount, totalEpisode - 1);
        }
      }
    }
    return null;
  }
}