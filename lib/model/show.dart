import 'package:json_annotation/json_annotation.dart';

part 'show.g.dart';

@JsonSerializable()
class Show {

  final int id;
  final String title; // for movie
  final String name; // for tv
  @JsonKey(name: "original_title")
  final String originalTitle;
  final String overview;
  @JsonKey(name: "original_language")
  final String language;
  @JsonKey(name: "release_date")
  final String release;
  @JsonKey(name: "first_air_date")
  final String firstAir;
  @JsonKey(name: "genre_ids")
  final List<int> genres;
  final bool adult;
  @JsonKey(name: "backdrop_path")
  final String backdrop;
  @JsonKey(name: "poster_path")
  final String poster;
  final double popularity;
  @JsonKey(name: "vote_count")
  final int voteCount;
  @JsonKey(name: "vote_average")
  final double votePoint;
  final bool video;

  int watchedSeason;
  int watchedEpisode;

  bool isMovie() => (title != null);

  factory Show.fromMap(Map<String, dynamic> json) => _$ShowFromJson(json);

  Map<String, dynamic> toJson() => _$ShowToJson(this);

  Show(this.id, this.title, this.name, this.originalTitle, this.overview, this.language,
      this.release, this.firstAir, this.genres, this.adult, this.backdrop, this.poster,
      this.popularity, this.voteCount, this.votePoint, this.video, this.watchedSeason, this.watchedEpisode);

}