import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/crew.dart';
import 'package:my_show/network/api_constant.dart';

import '../asset_path.dart';

class CrewPage extends StatelessWidget{

  final List<Crew> crews = List<Crew>();
  final String name;

  CrewPage({@required List<Crew> crews, this.name, Key key}): super(key: key){
    var mapCrews = HashMap<String, Crew>();
    crews.forEach((person){
      if (person.name != null) {
        if (mapCrews[person.name] != null) {
          mapCrews[person.name].job = mapCrews[person.name].job + ', ' + person.job;
        } else {
          mapCrews[person.name] = Crew.fromJson(person.toJson()); // clone
        }
      }
    });
    this.crews.addAll(mapCrews.values);
    this.crews.sort((c1, c2) => c1.name.compareTo(c2.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          leading: BackButton(color: Colors.white),
          title: Text('Crew of $name',
              style: TextStyle(
              color: Colors.white,
              fontSize: 20
          )),
        ),
        body: ListView(
            children: ListTile.divideTiles(context: context,
              color: Colors.white30,
              tiles: crews.map((crew) => _crewEntry(context, crew)),
            ).toList()
        )
    );
  }

  Widget _crewEntry(BuildContext context, Crew crew) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 150, width: 100,
            child:  _profilePic(crew.profilePath),
          ),
          SizedBox(width: 8,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (crew.name ?? ''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    (crew.job ?? ''),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _profilePic(String path){
    if (path?.isNotEmpty == true) {
      return CachedNetworkImage(
          imageUrl: (PROFILE_IMAGE_PREFIX_HD + path),
          fit: BoxFit.contain,
          height: 150, width: 100,
          placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER)
      );
    } else {
      return Image(image: AssetImage(POSTER_PLACEHOLDER),
        fit: BoxFit.contain,
        height: 150, width: 100,);
    }
  }
}

