import 'package:flutter/material.dart';
import 'package:my_show/model/cast.dart';
import 'package:my_show/model/cast_detail.dart';
import 'package:my_show/model/combined_credit.dart';
import 'package:my_show/model/people.dart';
import 'package:my_show/model/show.dart';
import 'package:my_show/network/network_call.dart';
import 'package:my_show/network/response/combined_credit_response.dart';
import 'package:my_show/pageview_page/show_widget_builder.dart';

class PeopleDetailPage extends StatefulWidget {

  final People people;

  PeopleDetailPage(this.people, {Key key}) : super(key: key);

  @override
  State createState() => _PeopleState();
}

class _PeopleState extends State<PeopleDetailPage> {

  CastDetail _detail;

  CombinedCreditResponse _credit;

  bool _requestingCredit = false;

  TabController mController;

  @override
  void initState() {
    super.initState();
    _makeNetworkCall();
  }

  @override
  Widget build(BuildContext context) {
    var allCredit = List<CombinedCredit>.empty(growable: true);
    if (_credit?.cast?.isNotEmpty == true) {
      allCredit.addAll(_credit.cast);
    }
    if (_credit?.crew?.isNotEmpty == true) {
      allCredit.addAll(_credit.crew);
    }

    var tabLength = _credit != null ? (_credit?.crew?.isNotEmpty == true && _credit?.cast?.isNotEmpty == true ? 2 : 1) : 2;

    var listOfTabBar = List<Widget>.empty(growable: true);
    var castTab = Tab(child: Text('Acting', style: TextStyle(color: Colors.white, fontSize: 16),),);
    var crewTab = Tab(child: Text('Production', style: TextStyle(color: Colors.white),),);
    if (tabLength == 2) {
      listOfTabBar.add(castTab);
      listOfTabBar.add(crewTab);
    } else if (_credit?.crew?.isNotEmpty == true) {
      listOfTabBar.add(crewTab);
    } else {
      listOfTabBar.add(castTab);
    }

    var listOfTabView = List<Widget>.empty(growable: true);
    var castView = _credit?.cast != null ? _creditList(true, _credit?.cast) : Center(child: CircularProgressIndicator(),);
    var crewView = _credit?.crew != null ? _creditList(false, _credit?.crew) : Center(child: CircularProgressIndicator());
    if (tabLength == 2) {
      listOfTabView.add(castView);
      listOfTabView.add(crewView);
    } else if (_credit?.crew?.isNotEmpty == true) {
      listOfTabView.add(crewView);
    } else {
      listOfTabView.add(castView);
    }

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          leading: BackButton(color: Colors.white),
          title: Text(widget.people is Cast ? 'Cast Details' : 'Crew Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
              )),
        ),
        body:
        Column(
          children: <Widget>[
            _peopleInfo(context),
            Flexible(
              flex: 1,
              child: Container(
                constraints: BoxConstraints.expand(),
                child:  DefaultTabController(
                  length: tabLength,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TabBar(
                        tabs: listOfTabBar,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: listOfTabView,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget _peopleInfo(BuildContext context){
    var infoWidgets = List<Widget>.empty(growable: true);
    infoWidgets.add(Text(widget.people.name,
      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ));
    if (_detail?.knownForDepartment?.isNotEmpty == true) {
      infoWidgets.add(SizedBox(height: 5));
      infoWidgets.add(RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Known For : ', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
              TextSpan(text: _detail.knownForDepartment, style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic))
            ],
          )
      ));
    }
    if (_detail?.birthday?.isNotEmpty == true) {
      infoWidgets.add(SizedBox(height: 5));
      infoWidgets.add(RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Born : ', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
              TextSpan(text: _detail?.placeOfBirth?.isNotEmpty == true ? '${_detail.birthday} (${_detail.placeOfBirth})' : _detail.birthday, style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic))
            ],
          )
      ));
    }
    if (_detail?.deathDay?.isNotEmpty == true) {
      infoWidgets.add(SizedBox(height: 5));
      infoWidgets.add(RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Died : ', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
              TextSpan(text: _detail.deathDay, style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic))
            ],
          )
      ));
    }

    if (_detail?.biography?.isNotEmpty == true) {
      infoWidgets.add(SizedBox(height: 8));
      infoWidgets.add(InkWell(
        child: Text(_detail.biography,
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: (){
          showDialog(context: context,
              builder: (context){
                return AlertDialog(
                  title: Text('Biography of ${widget.people.name}',),
                  content: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text(_detail?.biography,
                      style: TextStyle(height: 1.3),)
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK',
                          style: TextStyle(color: Colors.blueGrey)),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        },
      ));
    }


    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child:  Row(
            children: <Widget>[
              SizedBox(height: 156, width: 104,
                  child: ShowWidgetBuilder.buildImage(widget.people.profilePath)),
              SizedBox(width: 8,),
              Expanded(
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: infoWidgets
                ),
              )
            ]
        )
    );
  }

  Widget _creditList(bool cast, List<Show> shows) {
    return Container(
      color: Colors.white10,
      constraints: BoxConstraints.expand(),
      child:  ListView(
          children: ListTile.divideTiles(context: context,
            color: Colors.white30,
            tiles: shows.map((show) => ShowWidgetBuilder.buildShowEntry(context, show, forPeople: true,
                extraText: [
                  SizedBox(height: 5),
                  Text(
                    (cast ? (show as CombinedCredit)?.character : (show as CombinedCredit)?.job) ?? '',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  )
                ]
            )),
          ).toList()
      ),
    );
  }

  _makeNetworkCall(){
    if (_detail == null) {
      getPeopleDetail(widget.people.id).then((response){
        if (response != null) {
          setState(() {
            _detail = response;
          });
        }
      });
    }
    if (_credit == null && !_requestingCredit) {
      _requestingCredit = true;
      getPeopleShow(widget.people.id).then((response){
        if (response != null) {
          setState(() {
            _requestingCredit = false;
            _credit = response;
          });
        }
      });
    }
  }
}