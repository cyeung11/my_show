
import 'dart:convert';

import 'package:my_show/storage/database_helper.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/episode.dart';
import 'package:my_show/model/role.dart';
import 'package:my_show/model/watch_progress.dart';
import 'package:sqflite/sqflite.dart';

import 'genre.dart';
import 'person.dart';
import 'season.dart';

class TvDetails extends Details {
    List<Person> createdBy;
    List<int> episodeRunTime;
    String firstAirDate;
    bool inProduction;
    List<String> languages;
    String lastAirDate;
    Episode lastEpisodeAir;
    List<Role> networks;
    Episode nextEpisodeAir;
    int noEpisodes;
    int noSeasons;
    List<String> originCountry;
    String originalLanguage;
    List<Season> seasons;
    String type;

    WatchProgress progress = WatchProgress(1, 1, 1);

    TvDetails({String backdropPath, this.createdBy, this.episodeRunTime, this.firstAirDate, List<Genre> genres, String homePage, int id, this.inProduction,
        this.languages, this.lastAirDate, this.lastEpisodeAir, String name, this.networks, this.nextEpisodeAir, this.noEpisodes, this.noSeasons,
        this.originCountry, this.originalLanguage, String originalName, String overview, double popularity, String posterPath, List<Role> productionCompanies,
        this.seasons, String status, this.type, double voteAverage, int voteCount, this.progress, int savedTime}
        ) : super(backdropPath: backdropPath, genres: genres, homePage: homePage, id: id, name: name, originalName: originalName, overview: overview, popularity: popularity,
        posterPath: posterPath, productionCompanies: productionCompanies, status: status, voteAverage: voteAverage, voteCount: voteCount, savedTime: savedTime){
        seasons.sort((s1, s2) => s1.seasonNo.compareTo(s2.seasonNo));
    }

    factory TvDetails.fromJson(Map<String, dynamic> json) {
        return TvDetails(
            backdropPath: json['backdrop_path'],
            createdBy: json['created_by'] != null ? (json['created_by'] as List).map((i) => Person.fromJson(i)).toList() : null,
            episodeRunTime: json['episode_run_time'] != null ? new List<int>.from(json['episode_run_time']) : null,
            firstAirDate: json['first_air_date'],
            genres: json['genres'] != null ? (json['genres'] as List).map((i) => Genre.fromMap(i)).toList() : null,
            homePage: json['homepage'],
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
            progress: json['progress'] != null ? WatchProgress.fromMap(json['progress']) : WatchProgress(1, 1, 1),
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = super.toJson();
        data['first_air_date'] = this.firstAirDate;
        data['in_production'] = this.inProduction;
        data['last_air_date'] = this.lastAirDate;
        data['number_of_episodes'] = this.noEpisodes;
        data['number_of_seasons'] = this.noSeasons;
        data['original_language'] = this.originalLanguage;
        data['type'] = this.type;
        if (this.createdBy != null) {
            data['created_by'] = this.createdBy.map((v) => v.toJson()).toList();
        }
        if (this.episodeRunTime != null) {
            data['episode_run_time'] = this.episodeRunTime;
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
        if (this.seasons != null) {
            data['seasons'] = this.seasons.map((v) => v.toJson()).toList();
        }
        if (this.progress != null) {
            data['progress'] = this.progress.toJson();
        }
        return data;
    }

    factory TvDetails.fromDb(Map<String, dynamic> json) {
        return TvDetails(
            backdropPath: json['backdrop_path'],
            createdBy: json['created_by'] != null ? (jsonDecode(json['created_by']) as List).map((i) => Person.fromJson(i)).toList() : null,
            episodeRunTime: json['episode_run_time'] != null ? (json['episode_run_time'] as String).split(',').map((s) => int.tryParse(s)).toList() : null,
            firstAirDate: json['first_air_date'],
            genres: json['genres'] != null ? (jsonDecode(json['genres']) as List).map((i) => Genre.fromMap(i)).toList() : null,
            homePage: json['homepage'],
            id: json['id'],
            inProduction: json['in_production'] == 1,
            languages: json['languages'] != null ? (jsonDecode(json['languages']) as List).map((s) => s.toString()).toList() : null,
            lastAirDate: json['last_air_date'],
            lastEpisodeAir: json['last_episode_to_air'] != null ? Episode.fromJson(jsonDecode(json['last_episode_to_air'])) : null,
            name: json['name'],
            networks: json['networks'] != null ? (jsonDecode(json['networks']) as List).map((i) => Role.fromJson(i)).toList() : null,
            nextEpisodeAir: json['next_episode_to_air'] != null ? Episode.fromJson(jsonDecode(json['next_episode_to_air'])) : null,
            noEpisodes: json['number_of_episodes'],
            noSeasons: json['number_of_seasons'],
            originCountry: json['origin_country'] != null ? (jsonDecode(json['origin_country']) as List).map((s) => s.toString()).toList() : null,
            originalLanguage: json['original_language'],
            originalName: json['original_name'],
            overview: json['overview'],
            popularity: json['popularity'],
            posterPath: json['poster_path'],
            productionCompanies: json['production_companies'] != null ? (jsonDecode(json['production_companies']) as List).map((i) => Role.fromJson(i)).toList() : null,
            seasons: json['seasons'] != null ? (jsonDecode(json['seasons']) as List).map((i) => Season.fromJson(i)).toList() : null,
            status: json['status'],
            type: json['type'],
            voteAverage: json['vote_average'],
            voteCount: json['vote_count'],
            progress: json['progress'] != null ? WatchProgress.fromMap(jsonDecode(json['progress'])) : WatchProgress(1, 1, 1),
            savedTime: json['savedTime']
        );
    }

    Map<String, dynamic> toDbMap() {
        final Map<String, dynamic> data = super.toDb();
        data['first_air_date'] = this.firstAirDate;
        data['in_production'] = this.inProduction;
        data['last_air_date'] = this.lastAirDate;
        data['number_of_episodes'] = this.noEpisodes;
        data['number_of_seasons'] = this.noSeasons;
        data['original_language'] = this.originalLanguage;
        data['type'] = this.type;
        if (this.createdBy != null) {
            data['created_by'] = this.createdBy.map((v) => jsonEncode(v.toJson())).toList().toString();
        }
        if (this.episodeRunTime != null) {
            data['episode_run_time'] = this.episodeRunTime.join(',');
        }
        if (this.languages != null) {
            data['languages'] = jsonEncode(this.languages);
        }
        if (this.lastEpisodeAir != null) {
            data['last_episode_to_air'] = jsonEncode(this.lastEpisodeAir.toJson());
        }
        if (this.networks != null) {
            data['networks'] = this.networks.map((v) => jsonEncode(v.toJson())).toList().toString();
        }
        if (this.nextEpisodeAir != null) {
            data['next_episode_to_air'] = jsonEncode(this.nextEpisodeAir.toJson());
        }
        if (this.originCountry != null) {
            data['origin_country'] = jsonEncode(this.originCountry);
        }
        if (this.seasons != null) {
            data['seasons'] = this.seasons.map((v) => jsonEncode(v.toJson())).toList().toString();
        }
        if (this.progress != null) {
            data['progress'] = jsonEncode(this.progress.toJson());
        }
        return data;
    }

    Future<void> insert() async {
        savedTime = DateTime.now().millisecondsSinceEpoch;
        await DatabaseHelper.db.insert(
            DatabaseHelper.TABLE_TV,
            toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
        );
    }

    static Future<void> delete(int id) async {
        await DatabaseHelper.db.delete(
            DatabaseHelper.TABLE_TV,
            where: "id = ?",
            whereArgs: [id],
        );
    }

    static Future<void> insertAll(List<TvDetails> data) async {
        await DatabaseHelper.db.transaction((t) async {
            data.forEach((m) async {
                m.savedTime = DateTime.now().millisecondsSinceEpoch;
                await t.insert(
                    DatabaseHelper.TABLE_TV, m.toDbMap(),
                    conflictAlgorithm: ConflictAlgorithm.replace);
            });
        });
    }

    static Future<TvDetails> getById(int id) async {
        final List<Map<String, dynamic>> maps = await DatabaseHelper.db.query(DatabaseHelper.TABLE_TV,
            where: "id = ?",
            whereArgs: [id],);

        if (maps.isNotEmpty){
            return TvDetails.fromDb(maps[0]);
        } else {
            return null;
        }
    }

    static Future<List<TvDetails>> all() async {
        final List<Map<String, dynamic>> maps = await DatabaseHelper.db.query( DatabaseHelper.TABLE_TV);

        return List.generate(maps.length, (i) {
            return TvDetails.fromDb(maps[i]);
        });
    }


}