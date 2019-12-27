import 'package:flutter/material.dart';
import 'package:my_show/model/selectable.dart';

class SelectDialog<T extends Selectable> extends StatelessWidget {
  final List<T> selectables;
  final T currentSelect;

  SelectDialog({@required this.selectables, @required this.currentSelect, Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 1.0,
      backgroundColor: Colors.white,
      child: ListView(
        shrinkWrap: true,
          children: ListTile.divideTiles(
              color: Colors.black54,
              context: context,
              tiles: selectables.map((T selectable){
                return InkWell(
                  child: buildSelectable(selectable),
                  onTap: () {
                    Navigator.of(context).pop(selectable);
                  }
                );
              })
          ).toList()),
    );
  }

  Widget buildSelectable(Selectable selectable){
    return Row(
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          height: 45,
          child: Center(
            child: Text(selectable.getString(),
              style: TextStyle(
                fontSize: selectable.isEqual(currentSelect) ? 16 : 15,
                fontWeight: selectable.isEqual(currentSelect) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        )
      ],
    );
  }
}
