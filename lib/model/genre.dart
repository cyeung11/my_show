class Genre {
  final int id;
  final String name;

  Genre(this.id, this.name);

  factory Genre.fromMap(Map<String, dynamic> json) {
    return Genre(
      json['id'],
      json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}