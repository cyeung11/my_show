class CastDetail {
    final bool adult;
    final List<String> alias;
    final String biography;
    final String birthday;
    final String deathDay;
    final int gender;
    final String homePage;
    final int id;
    final String imdbId;
    final String knownForDepartment;
    final String name;
    final String placeOfBirth;
    final double popularity;
    final String profilePath;

    CastDetail({this.adult, this.alias, this.biography, this.birthday, this.deathDay, this.gender, this.homePage, this.id, this.imdbId, this.knownForDepartment, this.name, this.placeOfBirth, this.popularity, this.profilePath});

    factory CastDetail.fromJson(Map<String, dynamic> json) {
        return CastDetail(
            adult: json['adult'], 
            alias: json['also_known_as'] != null ? List<String>.from(json['also_known_as']) : null,
            biography: json['biography'], 
            birthday: json['birthday'], 
            deathDay: json['deathday'],
            gender: json['gender'], 
            homePage: json['homepage'],
            id: json['id'], 
            imdbId: json['imdb_id'],
            knownForDepartment: json['known_for_department'],
            name: json['name'], 
            placeOfBirth: json['place_of_birth'],
            popularity: json['popularity'], 
            profilePath: json['profile_path'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data =  Map<String, dynamic>();
        data['adult'] = this.adult;
        data['biography'] = this.biography;
        data['birthday'] = this.birthday;
        data['deathday'] = this.deathDay;
        data['gender'] = this.gender;
        data['homepage'] = this.homePage;
        data['id'] = this.id;
        data['imdb_id'] = this.imdbId;
        data['known_for_department'] = this.knownForDepartment;
        data['name'] = this.name;
        data['place_of_birth'] = this.placeOfBirth;
        data['popularity'] = this.popularity;
        data['profile_path'] = this.profilePath;
        if (this.alias != null) {
            data['also_known_as'] = this.alias;
        }
        return data;
    }
}