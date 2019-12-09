import 'package:intl/intl.dart';
import 'package:my_show/model/country.dart';
import 'package:my_show/model/genre.dart';

class MovieDetails {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final List<Genre> genres;
  final String language;
  final String release;
  final List<Country> country;
  final int runtime;
  final String status;
  final int budget;
  final int revenue;
  final String homePage;
  final String imdbId;
  final bool adult;
  final String backdrop;
  final String poster;
  final double popularity;
  final int voteCount;
  final double votePoint;
  final bool video;
  final String tagline;


  factory MovieDetails.fromMap(Map<String, dynamic> json){
    Iterable genreIterable = json['genres'];
    var genres = genreIterable.map((entry){
      return Genre.fromMap(entry);
    }).toList();
    Iterable countryIterable = json['production_countries'];
    var country = countryIterable.map((entry){
      return Country.fromMap(entry);
    }).toList();

    return MovieDetails(
        json['id'],
        json['title'],
        json['original_language'],
        json['overview'],
        genres,
        json['original_language'],
        json['release_date'],
        country,
        json['runtime'],
        json['status'],
        json['budget'],
        json['revenue'],
        json['homepage'],
        json['imdb_id'],
        json['adult'],
        json['backdrop_path'],
        json['poster_path'],
        json['popularity'],
        json['vote_count'],
        json['vote_average'],
        json['video'],
        json['tagline']
    );
  }

  DateTime getReleaseDate(){
    DateFormat format = DateFormat("yyyy-MM-dd");
    return format.parse(release);
  }

  MovieDetails(this.id, this.title, this.originalTitle, this.overview,
      this.genres, this.language, this.release, this.country, this.runtime,
      this.status, this.budget, this.revenue, this.homePage, this.imdbId,
      this.adult, this.backdrop, this.poster, this.popularity, this.voteCount,
      this.votePoint, this.video, this.tagline);
}