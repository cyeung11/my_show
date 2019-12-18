import 'package:my_show/model/selectable.dart';

class Genre implements Selectable {
  final int id;
  final String name;

  @override
  String getString() {
    return name;
  }

  @override
  bool isEqual(Selectable selectable) {
    return selectable is Genre && selectable.id == id;
  }

  Genre({this.id, this.name});

  factory Genre.fromMap(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

}