import 'package:my_show/model/show.dart';

class CombinedCredit extends Show {

  final String creditId;
  String character;
  String job;
  final String mediaType;
  final String originalName;
  final int episodeCount;

  @override
  bool isMovie() => (mediaType == 'movie');

  CombinedCredit(this.creditId, this.character, this.job, this.mediaType,
      this.originalName, this.episodeCount, int id, String title, String name, String originalTitle, String overview, String language,
      String release, String firstAir, List<int> genres, bool adult, String backdrop, String poster,
      double popularity, int voteCount, double votePoint, bool video
      ) : super(id, title, name, originalTitle, overview, language,
      release, firstAir, genres, adult, backdrop, poster,
      popularity, voteCount, votePoint, video);

  factory CombinedCredit.fromJson(Map<String, dynamic> json) {
    return CombinedCredit(
      json['credit_id'] as String,
      json['character'] as String,
      json['job'] as String,
      json['media_type'] as String,
      json['original_name'] as String,
      json['episode_count'] as int,
      json['id'] as int,
      json['title'] as String,
      json['name'] as String,
      json['original_title'] as String,
      json['overview'] as String,
      json['original_language'] as String,
      json['release_date'] as String,
      json['first_air_date'] as String,
      (json['genre_ids'] as List)?.map((e) => e as int)?.toList(),
      json['adult'] as bool,
      json['backdrop_path'] as String,
      json['poster_path'] as String,
      (json['popularity'] as num)?.toDouble(),
      json['vote_count'] as int,
      (json['vote_average'] as num)?.toDouble(),
      json['video'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson(){
    var result = super.toJson();
    result['credit_id'] = creditId;
    result['character'] = character;
    result['job'] = job;
    result['media_type'] = mediaType;
    result['original_name'] = originalName;
    result['episode_count'] = episodeCount;
    return result;
  }
}