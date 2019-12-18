import 'package:my_show/model/cast.dart';
import 'package:my_show/network/response/base_response.dart';

class CreditResponse extends BaseResponse{
  final int id;
  final List<Cast> cast;

  CreditResponse(this.id, this.cast, String msg, int code): super(msg, code);

  factory CreditResponse.fromMap(Map<String, dynamic> json) {

    Iterable iterable = json['cast'];
    var casts = iterable.map((cast){
      return Cast.fromJson(cast);
    }).toList();

    return CreditResponse(
        json['id'],
        casts,
        json['status_message'],
        json['status_code']
    );
  }
}