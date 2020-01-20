import 'package:my_show/model/people.dart';

class Crew extends People {
    final String creditId;
    final String department;
    String job;

    Crew({this.creditId, this.department, int gender, int id, this.job, String name, String profilePath}) : super(id, name, profilePath, gender);

    factory Crew.fromJson(Map<String, dynamic> json) {
        return Crew(
            creditId: json['credit_id'],
            department: json['department'],
            gender: json['gender'],
            id: json['id'],
            job: json['job'],
            name: json['name'],
            profilePath: json['profile_path'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['credit_id'] = this.creditId;
        data['department'] = this.department;
        data['gender'] = this.gender;
        data['id'] = this.id;
        data['job'] = this.job;
        data['name'] = this.name;
        data['profile_path'] = this.profilePath;
        return data;
    }
}