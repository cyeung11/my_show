import 'package:my_show/model/season.dart';

class WatchProgress {
  int seasonNo;
  int episodeNo;
  int totalEpisode;

  WatchProgress(this.seasonNo, this.episodeNo, this.totalEpisode);

  factory WatchProgress.fromMap(Map<String, dynamic> json) {
    return WatchProgress(
      json['seasonNo'],
      json['episodeNo'],
      json['totalEpisode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seasonNo'] = this.seasonNo;
    data['episodeNo'] = this.episodeNo;
    data['totalEpisode'] = this.totalEpisode;
    return data;
  }

  String userReadable() => "S$seasonNo E$episodeNo ($totalEpisode)";

  WatchProgress next(List<Season> seasonsInfo) {
    var currentSeasonIndex = seasonsInfo.indexWhere((season) => season.seasonNo == seasonNo);
    if (currentSeasonIndex != -1) {
      var isLastEpisodeInTheSeason = seasonsInfo[currentSeasonIndex].episodeCount == episodeNo;
      if (isLastEpisodeInTheSeason) {
        if (currentSeasonIndex < seasonsInfo.length - 1 ) {
          var nextSeason = seasonsInfo[currentSeasonIndex + 1];
          return WatchProgress(nextSeason.seasonNo, 1, totalEpisode + 1);
        }
      } else {
        return WatchProgress(seasonNo, episodeNo + 1, totalEpisode + 1);
      }
    }
    return null;
  }

  WatchProgress previous(List<Season> seasonsInfo) {
    if (episodeNo != 1 || seasonNo != seasonsInfo.first?.seasonNo) {
      if (episodeNo != 1) {
        return WatchProgress(seasonNo, episodeNo - 1, totalEpisode -1);
      } else {
        var currentSeasonIndex = seasonsInfo.indexWhere((season) => season.seasonNo == seasonNo);
        var lastSeason = seasonsInfo[currentSeasonIndex - 1];
        if (lastSeason != null) {
          return WatchProgress(lastSeason.seasonNo, lastSeason.episodeCount, totalEpisode - 1);
        }
      }
    }
    return null;
  }
}