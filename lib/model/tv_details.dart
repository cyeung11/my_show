import 'package:intl/intl.dart';
import 'package:my_show/model/episode.dart';
import 'package:my_show/model/role.dart';
import 'package:my_show/model/watch_progress.dart';

import 'genre.dart';
import 'person.dart';
import 'season.dart';

class TvDetails {
    String backdropPath;
    List<Person> createdBy;
    List<int> episodeRunTime;
    String firstAirDate;
    List<Genre> genres;
    String homepage;
    int id;
    bool inProduction;
    List<String> languages;
    String lastAirDate;
    Episode lastEpisodeAir;
    String name;
    List<Role> networks;
    Episode nextEpisodeAir;
    int noEpisodes;
    int noSeasons;
    List<String> originCountry;
    String originalLanguage;
    String originalName;
    String overview;
    double popularity;
    String posterPath;
    List<Role> productionCompanies;
    List<Season> seasons;
    String status;
    String type;
    double voteAverage;
    int voteCount;

    WatchProgress progress;

    TvDetails({this.backdropPath, this.createdBy, this.episodeRunTime, this.firstAirDate, this.genres, this.homepage, this.id, this.inProduction,
        this.languages, this.lastAirDate, this.lastEpisodeAir, this.name, this.networks, this.nextEpisodeAir, this.noEpisodes, this.noSeasons,
        this.originCountry, this.originalLanguage, this.originalName, this.overview, this.popularity, this.posterPath, this.productionCompanies,
        this.seasons, this.status, this.type, this.voteAverage, this.voteCount, this.progress});

    factory TvDetails.fromJson(Map<String, dynamic> json) {
        return TvDetails(
            backdropPath: json['backdrop_path'],
            createdBy: json['created_by'] != null ? (json['created_by'] as List).map((i) => Person.fromJson(i)).toList() : null,
            episodeRunTime: json['episode_run_time'] != null ? new List<int>.from(json['episode_run_time']) : null,
            firstAirDate: json['first_air_date'],
            genres: json['genres'] != null ? (json['genres'] as List).map((i) => Genre.fromMap(i)).toList() : null,
            homepage: json['homepage'], 
            id: json['id'], 
            inProduction: json['in_production'],
            languages: json['languages'] != null ? new List<String>.from(json['languages']) : null, 
            lastAirDate: json['last_air_date'],
            lastEpisodeAir: json['last_episode_to_air'] != null ? Episode.fromJson(json['last_episode_to_air']) : null,
            name: json['name'], 
            networks: json['networks'] != null ? (json['networks'] as List).map((i) => Role.fromJson(i)).toList() : null,
            nextEpisodeAir: json['next_episode_to_air'] != null ? Episode.fromJson(json['next_episode_to_air']) : null,
            noEpisodes: json['number_of_episodes'],
            noSeasons: json['number_of_seasons'],
            originCountry: json['origin_country'] != null ? new List<String>.from(json['origin_country']) : null,
            originalLanguage: json['original_language'],
            originalName: json['original_name'],
            overview: json['overview'], 
            popularity: json['popularity'], 
            posterPath: json['poster_path'],
            productionCompanies: json['production_companies'] != null ? (json['production_companies'] as List).map((i) => Role.fromJson(i)).toList() : null,
            seasons: json['seasons'] != null ? (json['seasons'] as List).map((i) => Season.fromJson(i)).toList() : null, 
            status: json['status'], 
            type: json['type'], 
            voteAverage: json['vote_average'],
            voteCount: json['vote_count'],
            progress: json['progress'] != null ? WatchProgress.fromMap(json['progress']) : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['backdrop_path'] = this.backdropPath;
        data['first_air_date'] = this.firstAirDate;
        data['homepage'] = this.homepage;
        data['id'] = this.id;
        data['in_production'] = this.inProduction;
        data['last_air_date'] = this.lastAirDate;
        data['name'] = this.name;
        data['number_of_episodes'] = this.noEpisodes;
        data['number_of_seasons'] = this.noSeasons;
        data['original_language'] = this.originalLanguage;
        data['original_name'] = this.originalName;
        data['overview'] = this.overview;
        data['popularity'] = this.popularity;
        data['poster_path'] = this.posterPath;
        data['status'] = this.status;
        data['type'] = this.type;
        data['vote_average'] = this.voteAverage;
        data['vote_count'] = this.voteCount;
        if (this.createdBy != null) {
            data['created_by'] = this.createdBy.map((v) => v.toJson()).toList();
        }
        if (this.episodeRunTime != null) {
            data['episode_run_time'] = this.episodeRunTime;
        }
        if (this.genres != null) {
            data['genres'] = this.genres.map((v) => v.toJson()).toList();
        }
        if (this.languages != null) {
            data['languages'] = this.languages;
        }
        if (this.lastEpisodeAir != null) {
            data['last_episode_to_air'] = this.lastEpisodeAir.toJson();
        }
        if (this.networks != null) {
            data['networks'] = this.networks.map((v) => v.toJson()).toList();
        }
        if (this.nextEpisodeAir != null) {
            data['next_episode_to_air'] = this.nextEpisodeAir.toJson();
        }
        if (this.originCountry != null) {
            data['origin_country'] = this.originCountry;
        }
        if (this.productionCompanies != null) {
            data['production_companies'] = this.productionCompanies.map((v) => v.toJson()).toList();
        }
        if (this.seasons != null) {
            data['seasons'] = this.seasons.map((v) => v.toJson()).toList();
        }
        if (this.progress != null) {
            data['progress'] = this.progress.toJson();
        }
        return data;
    }

    DateTime getFirstAirDate(){
        DateFormat format = DateFormat("yyyy-MM-dd");
        return format.parse(firstAirDate);
    }
}