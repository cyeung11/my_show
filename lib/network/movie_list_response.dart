import 'package:my_show/network/base_response.dart';
import 'package:my_show/network/model/movie.dart';

class MovieListResponse extends BaseResponse{
  final int page;
  final int totalResult;
  final int totalPage;
  final List<Movie> result;

  MovieListResponse(this.page, this.totalResult, this.totalPage, this.result, String msg, int code): super(msg, code);

  factory MovieListResponse.fromMap(Map<String, dynamic> json) {

    Iterable iterable = json['results'];
    var posts = iterable.map((entry){
      return Movie.fromMap(entry);
    }).toList();

    return MovieListResponse(
        json['page'],
        json['total_results'],
        json['total_pages'],
        posts,
        json['status_message'],
        json['status_code']
    );
  }
}