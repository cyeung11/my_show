import 'package:flutter/material.dart';
import 'package:my_show/model/genre.dart';

class GenreSelectDialog extends StatelessWidget {
  final List<Genre> selectable;

  final ValueChanged<Genre> onGenreSelected;

  GenreSelectDialog({@required this.selectable, @required this.onGenreSelected, Key key}): super(key: key);

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
              tiles: selectable.map((Genre genreSelectable){
                return InkWell(
                  child: buildSelectable(genreSelectable),
                  onTap: () {
                    Navigator.of(context).pop();
                    onGenreSelected(genreSelectable);
                  }
                );
              })
          ).toList()),
    );
  }

  Widget buildSelectable(Genre genre){
    return Row(
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          height: 45,
          child: Center(
            child: Text(genre.name,
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
