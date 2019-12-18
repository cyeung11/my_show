import 'package:my_show/model/country.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/role.dart';
import 'package:my_show/model/spoken_lang.dart';

class MovieDetails extends Details {
  int budget;
  List<Country> country;
  String language;
  String release;
  List<SpokenLanguage> spokenLanguages;
  int runtime;
  int revenue;
  String imdbId;
  bool adult;
  bool video;
  String tagline;

  MovieDetails({this.adult, String backdropPath, this.budget, List<Genre> genres, String homePage,
    int id, this.imdbId, this.language, String originalTitle, String overview, double popularity, String posterPath,
    List<Role> productionCompanies, this.country, this.release, this.revenue, this.runtime, this.spokenLanguages,
    String status, this.tagline, String title, this.video, double voteAverage, int voteCount}
      ) : super(backdropPath: backdropPath, genres: genres, homePage: homePage, id: id, originalName: originalTitle,
      overview: overview, popularity: popularity, posterPath: posterPath, productionCompanies: productionCompanies,
      status: status, name: title, voteAverage: voteAverage, voteCount: voteCount);

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      budget: json['budget'],
      genres: json['genres'] != null ? (json['genres'] as List).map((i) => Genre.fromMap(i)).toList() : null,
      homePage: json['homepage'],
      id: json['id'],
      imdbId: json['imdb_id'],
      language: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      popularity: json['popularity'],
      posterPath: json['poster_path'],
      productionCompanies: json['production_companies'] != null ? (json['production_companies'] as List).map((i) => Role.fromJson(i)).toList() : null,
      country: json['production_countries'] != null ? (json['production_countries'] as List).map((i) => Country.fromMap(i)).toList() : null,
      release: json['release_date'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: json['spoken_languages'] != null ? (json['spoken_languages'] as List).map((i) => SpokenLanguage.fromJson(i)).toList() : null,
      status: json['status'],
      tagline: json['tagline'],
      title: json['title'],
      video: json['video'],
      voteAverage: json['vote_average'],
      voteCount: json['vote_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['adult'] = this.adult;
    data['budget'] = this.budget;
    data['imdb_id'] = this.imdbId;
    data['original_language'] = this.language;
    data['original_title'] = this.originalName;
    data['poster_path'] = this.posterPath;
    data['release_date'] = this.release;
    data['revenue'] = this.revenue;
    data['runtime'] = this.runtime;
    data['tagline'] = this.tagline;
    data['title'] = this.name;
    data['video'] = this.video;
    if (this.country != null) {
      data['production_countries'] = this.country.map((v) => v.toJson()).toList();
    }
    if (this.spokenLanguages != null) {
      data['spoken_languages'] = this.spokenLanguages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}