import 'dart:math';

class Movie {

  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String language;
  final String release;
  final List<int> genres;
  final bool adult;
  final String backdrop;
  final String poster;
  final double popularity;
  final int voteCount;
  final double votePoint;
  final bool video;

  factory Movie.fromMap(Map<String, dynamic> json) {

    Iterable iterable = json['genre_ids'];
    var genres = iterable.map((entry){
      return entry as int;
    }).toList();

    var voteAverage = json["vote_average"];
    var popularity = json["popularity"];

    return Movie(
        json['id'],
        json['title'],
        json['original_title'],
        json['overview'],
        json['original_language'],
        json['release_date'],
        genres,
        json['adult'],
        json['backdrop_path'],
        json['poster_path'],
        popularity is int ? popularity.toDouble() : popularity,
        json['vote_count'],
        voteAverage is int ? voteAverage.toDouble() : voteAverage,
        json['video']
    );
  }

  Movie(this.id, this.title, this.originalTitle, this.overview, this.language,
      this.release, this.genres, this.adult, this.backdrop, this.poster,
      this.popularity, this.voteCount, this.votePoint, this.video);
}