import 'package:my_show/model/selectable.dart';

class SortType implements Selectable{
  final String _name;
  final String queryParam;

  @override
  String getString() {
    return _name;
  }

  @override
  bool isEqual(Selectable selectable) {
    return selectable is SortType && selectable.queryParam == queryParam;
  }

  SortType(this._name, this.queryParam);

  factory SortType.popularityDesc(){
    return SortType('Most Popular', 'popularity.desc');
  }
  factory SortType.popularityAsc(){
    return SortType('Least Popular', 'popularity.asc');
  }
  factory SortType.voteDesc(){
    return SortType('Highest Score', 'vote_average.desc');
  }
  factory SortType.voteAsc(){
    return SortType('Lowest Score', 'vote_average.asc');
  }
  factory SortType.releaseDesc(){
    return SortType('Latest', 'primary_release_date.desc');
  }
  factory SortType.releaseAsc(){
    return SortType('Oldest', 'primary_release_date.asc');
  }
  factory SortType.firstAirDesc(){
    return SortType('Latest', 'first_air_date.desc');
  }
  factory SortType.firstAirAsc(){
    return SortType('Oldest', 'first_air_date.asc');
  }

  static List<SortType> allMovie(){
    return [SortType.popularityDesc(), SortType.popularityAsc(), SortType.voteDesc(), SortType.voteAsc(), SortType.releaseDesc(), SortType.releaseAsc()];
  }

  static List<SortType> allTv(){
    return [SortType.popularityDesc(), SortType.popularityAsc(), SortType.voteDesc(), SortType.voteAsc(), SortType.firstAirDesc(), SortType.firstAirAsc()];
  }
}

