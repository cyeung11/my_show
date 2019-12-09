// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Show _$ShowFromJson(Map<String, dynamic> json) {
  return Show(
    json['id'] as int,
    json['title'] as String,
    json['name'] as String,
    json['original_title'] as String,
    json['overview'] as String,
    json['original_language'] as String,
    json['release_date'] as String,
    json['first_air_date'] as String,
    (json['genre_ids'] as List)?.map((e) => e as int)?.toList(),
    json['adult'] as bool,
    json['backdrop_path'] as String,
    json['poster_path'] as String,
    (json['popularity'] as num)?.toDouble(),
    json['vote_count'] as int,
    (json['vote_average'] as num)?.toDouble(),
    json['video'] as bool,
  );
}

Map<String, dynamic> _$ShowToJson(Show instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'original_title': instance.originalTitle,
      'overview': instance.overview,
      'original_language': instance.language,
      'release_date': instance.release,
      'first_air_date': instance.firstAir,
      'genre_ids': instance.genres,
      'adult': instance.adult,
      'backdrop_path': instance.backdrop,
      'poster_path': instance.poster,
      'popularity': instance.popularity,
      'vote_count': instance.voteCount,
      'vote_average': instance.votePoint,
      'video': instance.video,
    };
