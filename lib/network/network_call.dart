import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/api_key.dart';
import 'package:my_show/network/model/movie.dart';

import 'movie_list_response.dart';


Future<MovieListResponse> getUpcoming(int page) async {

  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  if (page != null) {
    queryParameters['page'] = page.toString();
  }

  final response = await http.get(Uri.https(DOMAIN, GET_UPCOMING, queryParameters));
  if (response.statusCode == 200) {
    return MovieListResponse.fromMap(json.decode(response.body));

  } else {
    throw Exception('Unable to login from the REST API');
  }

}