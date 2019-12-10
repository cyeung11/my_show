class Episode {
    String airDate;
    int episodeNo;
    int id;
    String name;
    String overview;
    String productionCode;
    int seasonNo;
    int showId;
    String stillPath;
    double voteAverage;
    int voteCount;

    Episode({this.airDate, this.episodeNo, this.id, this.name, this.overview, this.productionCode, this.seasonNo, this.showId, this.stillPath, this.voteAverage, this.voteCount});

    factory Episode.fromJson(Map<String, dynamic> json) {
        return Episode(
            airDate: json['air_date'],
            episodeNo: json['episode_number'],
            id: json['id'],
            name: json['name'],
            overview: json['overview'],
            productionCode: json['production_code'],
            seasonNo: json['season_number'],
            showId: json['show_id'],
            stillPath: json['still_path'],
            voteAverage: json['vote_average'],
            voteCount: json['vote_count'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['air_date'] = this.airDate;
        data['episode_number'] = this.episodeNo;
        data['id'] = this.id;
        data['name'] = this.name;
        data['overview'] = this.overview;
        data['production_code'] = this.productionCode;
        data['season_number'] = this.seasonNo;
        data['show_id'] = this.showId;
        data['still_path'] = this.stillPath;
        data['vote_average'] = this.voteAverage;
        data['vote_count'] = this.voteCount;
        return data;
    }
}