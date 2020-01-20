import 'package:my_show/model/people.dart';

class Cast extends People {
    int castId;
    String character;
    String creditId;
    int order;

    Cast({this.castId, this.character, this.creditId, int gender, int id, String name, this.order, String profilePath}) : super(id, name, profilePath, gender);

    factory Cast.fromJson(Map<String, dynamic> json) {
        return Cast(
            castId: json['cast_id'],
            character: json['character'],
            creditId: json['credit_id'],
            gender: json['gender'],
            id: json['id'],
            name: json['name'],
            order: json['order'],
            profilePath: json['profile_path'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['cast_id'] = this.castId;
        data['character'] = this.character;
        data['credit_id'] = this.creditId;
        data['gender'] = this.gender;
        data['id'] = this.id;
        data['name'] = this.name;
        data['order'] = this.order;
        data['profile_path'] = this.profilePath;
        return data;
    }
}