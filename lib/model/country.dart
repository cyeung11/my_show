class Country {
  final String code;
  final String name;

  Country({this.code, this.name});

  factory Country.fromMap(Map<String, dynamic> json) {
    return Country(
      code: json['iso_3166_1'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iso_3166_1'] = this.code;
    data['name'] = this.name;
    return data;
  }
}