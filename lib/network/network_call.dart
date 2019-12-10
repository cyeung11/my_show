import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/api_key.dart';

import 'response/movie_list_response.dart';


//Future<MovieListResponse> getUpcoming(int page) async {
//
//  var queryParameters = {
//    'api_key': API_KEY_V3,
//  };
//  if (page != null) {
//    queryParameters['page'] = page.toString();
//  }
//
//  try {
//    final response = await http.get(Uri.https(DOMAIN, GET_UPCOMING, queryParameters));
//    if (response.statusCode == 200) {
//      return MovieListResponse.fromMap(json.decode(response.body));
//    } else {
//      return null;
//    }
//  } catch (e) {
//    return null;
//  }
//
//}
//
//Future<MovieListResponse> getPopular(int page) async {
//
//  var queryParameters = {
//    'api_key': API_KEY_V3,
//  };
//  if (page != null) {
//    queryParameters['page'] = page.toString();
//  }
//
//  try {
//    final response = await http.get(Uri.https(DOMAIN, GET_POPULAR, queryParameters));
//
//    if (response.statusCode == 200) {
//      return MovieListResponse.fromMap(json.decode(response.body));
//    } else {
//      return null;
//    }
//  } catch (e) {
//    return null;
//  }
//
//}

Future<MovieListResponse> getShows(String path, String query, int page) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  if (query != null) {
    queryParameters['query'] = query;
  }
  if (page != null) {
    queryParameters['page'] = page.toString();
  }

  try {
    final response = await http.get(Uri.https(DOMAIN, path, queryParameters));

    if (response.statusCode == 200) {
      return MovieListResponse.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<MovieDetails> getMovieDetail(int id) async {

  var queryParameters = {
    'api_key': API_KEY_V3,
  };

  try {
    final response = await http.get(Uri.https(DOMAIN, GET_MOVIE_DETAIL + id.toString(), queryParameters));
    if (response.statusCode == 200) {
      return MovieDetails.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<TvDetails> getTVDetail(int id) async {

  var queryParameters = {
    'api_key': API_KEY_V3,
  };

  try {
    final response = await http.get(Uri.https(DOMAIN, GET_TV_DETAIL + id.toString(), queryParameters));
    if (response.statusCode == 200) {
      return TvDetails.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}