class Country {
  final String code;
  final String name;

  Country(this.code, this.name);

  factory Country.fromMap(Map<String, dynamic> json) {
    return Country(
      json['iso_3166_1'],
      json['name'],
    );
  }
}