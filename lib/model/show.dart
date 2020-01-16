class Show {

  final int id;
  final String title; // for movie
  final String name; // for tv
  final String originalTitle;
  final String overview;
  final String language;
  final String release;
  final String firstAir;
  final List<int> genres;
  final bool adult;
  final String backdrop;
  final String poster;
  final double popularity;
  final int voteCount;
  final double votePoint;
  final bool video;

  bool isMovie() => (title != null);

  Show(this.id, this.title, this.name, this.originalTitle, this.overview, this.language,
      this.release, this.firstAir, this.genres, this.adult, this.backdrop, this.poster,
      this.popularity, this.voteCount, this.votePoint, this.video);


  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'name': name,
    'original_title': originalTitle,
    'overview': overview,
    'original_language': language,
    'release_date': release,
    'first_air_date': firstAir,
    'genre_ids': genres,
    'adult': adult,
    'backdrop_path': backdrop,
    'poster_path': poster,
    'popularity': popularity,
    'vote_count': voteCount,
    'vote_average': votePoint,
    'video': video,
  };
}