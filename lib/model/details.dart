import 'package:my_show/model/role.dart';

import 'genre.dart';

class Details {
  String backdropPath;
  List<Genre> genres;
  String homePage;
  int id;
  String name;
  String originalName;
  String overview;
  double popularity;
  String posterPath;
  List<Role> productionCompanies;
  String status;
  int voteCount;
  double voteAverage;

  Details({this.backdropPath, this.genres, this.homePage, this.id, this.name,
      this.originalName, this.overview, this.popularity,
      this.posterPath, this.productionCompanies, this.status, this.voteCount,
      this.voteAverage});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      backdropPath: json['backdrop_path'],
      genres: json['genres'] != null ? (json['genres'] as List).map((i) => Genre.fromMap(i)).toList() : null,
      homePage: json['homepage'],
      id: json['id'],
      name: json['name'],
      originalName: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'],
      posterPath: json['poster_path'],
      productionCompanies: json['production_companies'] != null ? (json['production_companies'] as List).map((i) => Role.fromJson(i)).toList() : null,
      status: json['status'],
      voteAverage: json['vote_average'],
      voteCount: json['vote_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['backdrop_path'] = this.backdropPath;
    data['homepage'] = this.homePage;
    data['id'] = this.id;
    data['name'] = this.name;
    data['original_name'] = this.originalName;
    data['overview'] = this.overview;
    data['popularity'] = this.popularity;
    data['poster_path'] = this.posterPath;
    data['status'] = this.status;
    data['vote_average'] = this.voteAverage;
    data['vote_count'] = this.voteCount;
    if (this.genres != null) {
      data['genres'] = this.genres.map((v) => v.toJson()).toList();
    }
    if (this.productionCompanies != null) {
      data['production_companies'] = this.productionCompanies.map((v) => v.toJson()).toList();
    }
    return data;
  }
}