import 'package:flutter/material.dart';
import 'package:my_show/widget/browse_page_manager.dart';

class SortSelectDialog extends StatelessWidget {
  final List<SortType> selectable;

  final ValueChanged<SortType> onSortSelected;

  SortSelectDialog({@required this.selectable, @required this.onSortSelected, Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 1.0,
      backgroundColor: Colors.white,
      child: ListView(
          children: ListTile.divideTiles(
              color: Colors.black54,
              context: context,
              tiles: selectable.map((SortType sort){
                return InkWell(
                  child: buildSelectable(sort),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSortSelected(sort);
                  }
                );
              })
          ).toList()),
    );
  }

  Widget buildSelectable(SortType sort){
    return Row(
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          height: 45,
          child: Center(
            child: Text(sortString(sort),
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        )
      ],
    );
  }
}
