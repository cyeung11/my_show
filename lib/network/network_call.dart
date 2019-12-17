import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/api_key.dart';
import 'package:my_show/network/response/genre_list_response.dart';
import 'package:my_show/widget/browse_page_manager.dart';

import 'response/movie_list_response.dart';

Future<ShowListResponse> getShows(String path, String query, int page) async {
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
      return ShowListResponse.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<ShowListResponse> discover(bool forTv, int year, double voteAverage, Genre genre, SortType sort, int page) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  if (year != null) {
    queryParameters[forTv ? 'first_air_date_year' :'year'] = year.toString();
  }
  if (voteAverage != null) {
    queryParameters['vote_average.gte'] = voteAverage.toString();
  }
  if (page != null) {
    queryParameters['page'] = page.toString();
  }
  if (genre != null) {
    queryParameters['with_genres'] = genre.id.toString();
  }
  if (sort != null) {
    switch (sort) {
      case SortType.VoteDesc:
        queryParameters['sort_by'] = 'vote_average.desc';
        break;
      case SortType.VoteAsc:
        queryParameters['sort_by'] = 'vote_average.asc';
        break;
      case SortType.PopularityDesc:
        queryParameters['sort_by'] = 'popularity.desc';
        break;
      case SortType.PopularityAsc:
        queryParameters['sort_by'] = 'popularity.asc';
        break;
      case SortType.ReleaseAsc:
        queryParameters['sort_by'] = forTv ? 'first_air_date.asc' : 'release_date.asc';
        break;
      case SortType.ReleaseDesc:
        queryParameters['sort_by'] = forTv ? 'first_air_date.desc' : 'release_date.desc';
        break;
    }
  }

  try {
    final response = await http.get(Uri.https(DOMAIN, forTv ? DISCOVER_TV : DISCOVER_MOVIE, queryParameters));

    if (response.statusCode == 200) {
      return ShowListResponse.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<GenreListResponse> getGenre(String path) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  try {
    final response = await http.get(Uri.https(DOMAIN, path, queryParameters));
    if (response.statusCode == 200) {
      return GenreListResponse.fromMap(json.decode(response.body));
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
      return MovieDetails.fromJson(json.decode(response.body));
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