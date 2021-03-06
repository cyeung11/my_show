import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_show/model/cast_detail.dart';
import 'package:my_show/model/genre.dart';
import 'package:my_show/model/media.dart';
import 'package:my_show/model/movie_details.dart';
import 'package:my_show/model/sort.dart';
import 'package:my_show/model/tv_details.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/api_key.dart';
import 'package:my_show/network/response/combined_credit_response.dart';
import 'package:my_show/network/response/credit_response.dart';
import 'package:my_show/network/response/genre_list_response.dart';

import 'response/movie_list_response.dart';

Future<ShowListResponse> getShows(String path, String query, int page, {bool searchingMovie = false}) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  if (searchingMovie) {
    queryParameters['include_adult'] = 'false';
  }
  if (query != null) {
    queryParameters['query'] = query;
  }
  if (page != null) {
    queryParameters['page'] = page.toString();
  }

  try {
    final response = await http.get(Uri.https(DOMAIN, path, queryParameters));

    if (response.statusCode == 200) {
      var shows = ShowListResponse.fromMap(json.decode(response.body));
      shows.removeAdult();
      return shows;
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
  if (!forTv) {
    queryParameters['include_adult'] = 'false';
  }
  if (year != null) {
    if (forTv) {
      queryParameters['first_air_date_year'] = year.toString();
    } else {
      queryParameters['primary_release_date.gte'] = '$year-01-01';
    }
  }
  if (voteAverage != null) {
    queryParameters['vote_average.gte'] = voteAverage.toString();
  }
  if (page != null) {
    queryParameters['page'] = page.toString();
  }
  if (genre?.id != null) {
    queryParameters['with_genres'] = genre.id.toString();
  }
  if (sort != null) {
    queryParameters['sort_by'] = sort.queryParam;
  }

  try {
    final response = await http.get(Uri.https(DOMAIN, forTv ? DISCOVER_TV : DISCOVER_MOVIE, queryParameters));

    if (response.statusCode == 200) {
      var shows = ShowListResponse.fromMap(json.decode(response.body));
      shows.removeAdult();
      return shows;
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

Future<CreditResponse> getCredit(bool forTv, int id) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  try {
    final response = await http.get(Uri.https(DOMAIN, (forTv ? GET_TV_DETAIL : GET_MOVIE_DETAIL) + id.toString() + CREDIT, queryParameters));
    if (response.statusCode == 200) {
      return CreditResponse.fromMap(json.decode(response.body));
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
      var movie = MovieDetails.fromJson(json.decode(response.body));
      movie.insert();
      return movie;
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
      var tv = TvDetails.fromJson(json.decode(response.body));
      tv.insert();
      return tv;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<ShowMedia> getMedia(String path) async {
  var queryParameters = {
    'api_key': API_KEY_V3,
  };
  try {
    final response = await http.get(Uri.https(DOMAIN, path, queryParameters));
    if (response.statusCode == 200) {
      return ShowMedia.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}


Future<CastDetail> getPeopleDetail(int id) async {

  var queryParameters = {
    'api_key': API_KEY_V3,
  };

  try {
    final response = await http.get(Uri.https(DOMAIN, GET_PEOPLE_DETAIL + id.toString(), queryParameters));
    if (response.statusCode == 200) {
      var people = CastDetail.fromJson(json.decode(response.body));
      return people;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<CombinedCreditResponse> getPeopleShow(int id) async {

  var queryParameters = {
    'api_key': API_KEY_V3,
  };

  try {
    final response = await http.get(Uri.https(DOMAIN, GET_PEOPLE_DETAIL + id.toString() + COMBINE_CREDIT, queryParameters));
    if (response.statusCode == 200) {
      var peopleShow = CombinedCreditResponse.fromMap(json.decode(response.body));
      peopleShow?.removeAdult();
      peopleShow?.mergeDuplicate();
      peopleShow?.sortByDate();
      return peopleShow;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
