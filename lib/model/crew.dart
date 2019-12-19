class Crew {
    final String creditId;
    final String department;
    final int gender;
    final int id;
    String job;
    final String name;
    final String profilePath;

    Crew({this.creditId, this.department, this.gender, this.id, this.job, this.name, this.profilePath});

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
        final Map<String, dynamic> data = new Map<String, dynamic>();
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