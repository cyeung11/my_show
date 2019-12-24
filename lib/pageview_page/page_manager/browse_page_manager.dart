import 'package:my_show/model/genre.dart';
import 'package:my_show/model/sort.dart';
import 'package:my_show/pageview_page/page_manager/page_manager.dart';

class BrowsePageManager extends ScrollablePageManager{
  int year;
  double vote;
  Genre genre;
  SortType sort = SortType.popularityDesc();
}