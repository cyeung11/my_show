import 'package:my_show/model/show.dart';

class ScrollablePageManager{
  bool isLoading = false;

  int currentPage = 1;
  int totalPage;

  double scrollOffsetToRestore = 0.0;

  bool isTv = true;

  final List<Show> shows = List<Show>.empty(growable: true);

  resetLoad(){
    currentPage = 1;
    scrollOffsetToRestore = 0.0;
    shows.clear();
    isLoading = true;
  }
}