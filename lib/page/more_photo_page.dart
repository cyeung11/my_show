import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_show/widget/detail_photo_list.dart';

class MorePhotoPage extends StatelessWidget{

  final List<String> _images;

  MorePhotoPage(this._images, {Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          title: Text(
            'More',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
          leading: BackButton(color: Colors.white,)
        ),
        body: DetailPhotoList(_images, _images.length, width, width * 0.6,  horizontal: false, hd: true,),
      ),
    );
  }

}