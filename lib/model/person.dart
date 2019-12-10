class Person {
    String creditId;
    int id;
    String name;
    String profilePath;

    Person({this.creditId, this.id, this.name, this.profilePath});

    factory Person.fromJson(Map<String, dynamic> json) {
        return Person(
            creditId: json['credit_id'],
            id: json['id'], 
            name: json['name'], 
            profilePath: json['profile_path'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['credit_id'] = this.creditId;
        data['id'] = this.id;
        data['name'] = this.name;
        data['profile_path'] = this.profilePath;
        return data;
    }
}