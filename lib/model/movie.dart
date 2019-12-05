

class Movie {

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
        json['name'],
        json['original_title'],
        json['overview'],
        json['original_language'],
        json['release_date'],
        json['first_air_date'],
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

  Movie(this.id, this.title, this.name, this.originalTitle, this.overview, this.language,
      this.release, this.firstAir, this.genres, this.adult, this.backdrop, this.poster,
      this.popularity, this.voteCount, this.votePoint, this.video);
}