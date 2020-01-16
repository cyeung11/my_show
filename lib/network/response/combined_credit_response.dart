import 'dart:collection';

import 'package:my_show/model/combined_credit.dart';
import 'package:my_show/network/response/base_response.dart';

class CombinedCreditResponse extends BaseResponse{
  final int id;
  List<CombinedCredit> cast;
  List<CombinedCredit> crew;

  CombinedCreditResponse(this.id, this.cast, this.crew, String msg, int code): super(msg, code);

  factory CombinedCreditResponse.fromMap(Map<String, dynamic> json) {
    return CombinedCreditResponse(
        json['id'],
        json['cast'] != null ? (json['cast'] as List).map((i) => CombinedCredit.fromJson(i)).toList() : null,
        json['crew'] != null ? (json['crew'] as List).map((i) => CombinedCredit.fromJson(i)).toList() : null,
        json['status_message'],
        json['status_code']
    );
  }

  mergeDuplicate(){
    var newCast = HashMap<int, CombinedCredit>();
    cast.forEach((c){
      if (newCast.containsKey(c.id)) {
        newCast[c.id].character =  newCast[c.id].character + ', ' + c.character;
      } else {
        newCast[c.id] = c;
      }
    });
    cast = newCast.values.toList();

    var newCrew = HashMap<int, CombinedCredit>();
    crew.forEach((c){
      if (newCrew.containsKey(c.id)) {
        newCrew[c.id].job =  newCrew[c.id].job + ', ' + c.job;
      } else {
        newCrew[c.id] = c;
      }
    });
    crew = newCrew.values.toList();
  }

  removeAdult(){
    cast?.removeWhere((c) => c.adult == true);
    crew?.removeWhere((c) => c.adult == true);
  }

  sortByDate(){
    crew?.sort((s1, s2) {
      String date1;
      String date2;
      if (s1.isMovie()) {
        date1 = s1.release;
      } else {
        date1 = s1.firstAir;
      }
      if (s2.isMovie()) {
        date2 = s2.release;
      } else {
        date2 = s2.firstAir;
      }
      if (date1 == null && date2 == null) {
        return 0;
      } else if (date1 == null) {
        return 1;
      } else if (date2 == null) {
        return -1;
      } else
        return date2.compareTo(date1);
    });

    cast?.sort((s1, s2) {
      String date1;
      String date2;
      if (s1.isMovie()) {
        date1 = s1.release;
      } else {
        date1 = s1.firstAir;
      }
      if (s2.isMovie()) {
        date2 = s2.release;
      } else {
        date2 = s2.firstAir;
      }
      if (date1 == null && date2 == null) {
        return 0;
      } else if (date1 == null) {
        return 1;
      } else if (date2 == null) {
        return -1;
      } else
        return date2.compareTo(date1);
    });
  }
}