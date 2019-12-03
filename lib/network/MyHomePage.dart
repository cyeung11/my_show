import 'package:flutter/material.dart';
import 'package:my_show/network/model/movie.dart';

import 'movie_list_response.dart';
import 'network_call.dart';

class UpcomingPage extends StatefulWidget {

  @override
  _UpcomingPageState createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {

  Future<MovieListResponse> movies;

  @override
  void initState() {
    super.initState();
    movies = getUpcoming(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: FutureBuilder<MovieListResponse>(
          future: movies,
          builder: (context, snapshot){
            return buildMovieList(snapshot.data?.result);
          },
        ),
    );
  }

  Widget buildMovieList(List<Movie> data){
    if (data?.isNotEmpty == true) {
      return ListView(
          children: ListTile.divideTiles(
              context: context,
              tiles: data.map((Movie movie){
                return ListTile(
                  title: Text(
                      movie.title
                  ),
                );
              })
          ).toList()
      );
    }
    return CircularProgressIndicator();
  }
}