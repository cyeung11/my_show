class Role {
    int id;
    String logoPath;
    String name;
    String originCountry;

    Role({this.id, this.logoPath, this.name, this.originCountry});

    factory Role.fromJson(Map<String, dynamic> json) {
        return Role(
            id: json['id'],
            logoPath: json['logo_path'],
            name: json['name'], 
            originCountry: json['origin_country'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['name'] = this.name;
        data['origin_country'] = this.originCountry;
        data['logo_path'] = this.logoPath;
        return data;
    }
}