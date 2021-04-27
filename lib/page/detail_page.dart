import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_show/model/cast.dart';
import 'package:my_show/model/crew.dart';
import 'package:my_show/model/details.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/page/people_detail_page.dart';
import 'package:my_show/widget/detail_photo_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../asset_path.dart';
import 'crew_page.dart';
import 'gallery_page.dart';
import 'more_photo_page.dart';

abstract class DetailPageState <T extends StatefulWidget> extends State<T> {

  List<Show> similar;
  List<String> images;

  String getDetailPath();

  getDetailSimilar(){
    if (similar == null) {
      getShows(getDetailPath() + SIMILAR, null, null).then((response){
        if (response?.result != null) {
          setState(() {
            similar = response.result;
          });
        }
      });
    }
  }

  getDetailMedia(){
    if (images == null) {
      getMedia(getDetailPath()  + IMAGE).then((response){
        if (response?.backdrops?.isNotEmpty == true) {
          setState(() {
            images = response.backdrops?.map((bd) => bd.filePath ?? '')?.toList() ?? List<String>.empty(growable: true);
          });
        }
      });
    }
  }

  Widget buildLoading(){
    return SafeArea(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 5, left: 5,
              child: BackButton(color: Colors.white,),
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  Widget buildRetry(BuildContext context){
    return SafeArea(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 5, left: 5,
              child: BackButton(color: Colors.white,),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white, size: 50,),
              onPressed: (){
                setState(() {
                  loadData(context);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildOverview(Details detail) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text(detail.overview ?? "",
          style: TextStyle(
            fontSize: 16.0,
            height: 1.4,
            color: Colors.white,
          )
      ),
    );
  }

  Widget buildVotePoint(Details detail) {
    MaterialColor color;
    if (detail.voteAverage >= 6.5)
      color = Colors.green;
    else if (detail.voteAverage >= 4)
      color = Colors.yellow;
    else
      color = Colors.red;

    return CircularPercentIndicator(
      radius: 40.0,
      lineWidth: 4.0,
      percent: detail.voteAverage / 10,
      center: Text(detail.voteAverage.toString(),
        style: TextStyle(fontSize: 12.0, color: Colors.white,),
      ),
      backgroundColor: Colors.grey,
      progressColor: color,
    );
  }

  Widget buildGenre(Details detail) {
    return Text(detail.genres.map((genre) => genre.name).join(', '),
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        )
    );
  }

  List<Widget> buildCastSection(List<Cast> allCast) {
    return [
      Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text('Cast',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )),
    ),
      Container(
        height: 250,
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCast.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              var person = allCast[index];
              return _castBox(context, person);
            }
        ),
      )];
  }

  List<Widget> buildCrewSection(Details detail, List<Crew> allCrew){
    var section = List<Widget>.empty(growable: true);
    section.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Crew',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            InkWell(
              child: Text('see all',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  )),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_){
                      return CrewPage(crews: allCrew, name: (detail.name ?? detail.originalName));
                    }
                ));
              },
            )
          ],
        )
    ));

    var directors = allCrew.where((person) => person.job?.trim()?.toLowerCase() == 'director').toList();
    if (directors.isNotEmpty) {
      section.add(Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Text('Director: ${directors.map((person) => person.name).join(', ')}',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            )),
      ));
    }
    return section;
  }

  List<Widget> buildImageSection(){
    var listChild = List<Widget>.empty(growable: true);
    listChild.add(Divider(indent: 10, endIndent: 10, height: 40, thickness: 0.5, color: Colors.white30,));

    listChild.add(Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Photos',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            InkWell(
              child: Text('more',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  )),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_){
                      return MorePhotoPage(images);
                    }
                ));
              },
            )
          ],
        )
    ));

    listChild.add(Container(
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: DetailPhotoList(images, min(4, images.length), 200, 120),
    ));

    return listChild;
  }

  Widget _castBox(BuildContext context, Cast cast) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        color: Color.fromARGB(255, 40, 40, 40),
        width: 110, height: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(imageUrl: PROFILE_IMAGE_PREFIX + (cast.profilePath ?? ''),
                fit: BoxFit.cover,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: 165, width: 110),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              child: Text(cast.name, style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.fade),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: Text(cast.character, style: TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.fade),
            )
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) {
              return PeopleDetailPage(cast);
            }
        ));
      }
    );
  }

  Widget buildHeaderImage(Details detail, Widget favButton) {
    var screenWidth = MediaQuery.of(context).size.width;
    var posterWidth = screenWidth *0.4;
    var posterHeight = posterWidth * 1.5;
    var backdropHeight = screenWidth / 1.78;
    var posterTopSpace = backdropHeight * 0.5;
    var headerHeight = posterTopSpace + posterHeight;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: screenWidth,
            height: backdropHeight,
            child: GestureDetector(
              child: CachedNetworkImage(
                  imageUrl: BACKDROP_IMAGE_PREFIX_HD + (detail.backdropPath ?? ''),
                  fit: BoxFit.scaleDown,
                  placeholder: (context, _) => Image.asset(BACKDROP_PLACEHOLDER),
                  height: backdropHeight, width: screenWidth
              ),
              onTap: (){
                if (detail.backdropPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([detail.backdropPath]);
                      }
                  ));
                }
              },
            ),
          ),
          Container(
            width: screenWidth,
            height: backdropHeight,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.4],
                    colors: [Colors.black54, Colors.transparent]
                )
            ),
          ),
          Positioned(
            top: posterTopSpace,
            height: posterHeight, width: posterWidth,
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl: IMAGE_PREFIX + (detail.posterPath ?? ''),
                fit: BoxFit.scaleDown,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: posterHeight, width: posterWidth,
              ),
              onTap: (){
                if (detail.posterPath?.isNotEmpty == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) {
                        return GalleryPage([detail.posterPath]);
                      }
                  ));
                }
              },
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: SafeArea(
              child: BackButton(
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: SafeArea(
              child:  favButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget similarBox(BuildContext context, Show show) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        color: Color.fromARGB(255, 40, 40, 40),
        width: 110, height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(imageUrl: LOW_IMAGE_PREFIX + (show.poster ?? ''),
                fit: BoxFit.cover,
                placeholder: (context, _) => Image.asset(POSTER_PLACEHOLDER),
                height: 165, width: 110),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              child: Text((show.isMovie() ? (show.title ?? show.originalTitle) : show.name) ?? '', style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis,),
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_){
              return goToDetailPage(show.id);
            }
        ));
      },
    );
  }

  Widget buildSearchWeb(Details detail){
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Image.asset(BTN_GOOGLE, width: 30, height: 30,),
            SizedBox(width: 10,),
            Text('Search in Web',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      onTap: (){
        Details.searchInGoogle((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
      },
    );
  }

  Widget buildSearchYoutube(Details detail){
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Image.asset(BTN_YOUTUBE, width: 30, height: 30,),
            SizedBox(width: 10,),
            Text('Search in YouTube',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      onTap: (){
        Details.searchInYoutube((detail.name?.isNotEmpty == true ? detail.name : detail.originalName) ?? '');
      },
    );
  }

  List<Widget> buildSimilar(){
    var listChild = List<Widget>.empty(growable: true);
    listChild.add(Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text('Similar Items',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )),
    ));
    listChild.add(Container(
      height: 235,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: similar.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index){
            var show = similar[index];
            return similarBox(context, show);
          }
      ),
    ));
    return listChild;
  }

  String getName(Show show);

  StatefulWidget goToDetailPage(int showId);

  loadData(BuildContext context);

  showRetrySnackbar(BuildContext context){
    final snackBar = SnackBar(content: Text('Fail to load :('),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: (){
          setState(() {
            loadData(context);
          });
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}