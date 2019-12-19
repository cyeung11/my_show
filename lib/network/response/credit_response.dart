import 'package:my_show/model/cast.dart';
import 'package:my_show/model/crew.dart';
import 'package:my_show/network/response/base_response.dart';

class CreditResponse extends BaseResponse{
  final int id;
  final List<Cast> cast;
  final List<Crew> crew;

  CreditResponse(this.id, this.cast, this.crew, String msg, int code): super(msg, code);

  factory CreditResponse.fromMap(Map<String, dynamic> json) {
    return CreditResponse(
        json['id'],
        json['cast'] != null ? (json['cast'] as List).map((i) => Cast.fromJson(i)).toList() : null,
        json['crew'] != null ? (json['crew'] as List).map((i) => Crew.fromJson(i)).toList() : null,
        json['status_message'],
        json['status_code']
    );
  }
}