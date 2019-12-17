import 'package:my_show/model/genre.dart';
import 'package:my_show/network/response/base_response.dart';

class GenreListResponse extends BaseResponse{
  final List<Genre> genres;

  GenreListResponse(this.genres, String msg, int code): super(msg, code);

  factory GenreListResponse.fromMap(Map<String, dynamic> json) {

    Iterable iterable = json['genres'];
    var genres = iterable.map((entry){
      return Genre.fromMap(entry);
    }).toList();

    return GenreListResponse(
        genres,
        json['status_message'],
        json['status_code']
    );
  }
}