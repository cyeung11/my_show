import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:my_show/page/gallery_page.dart';

import '../asset_path.dart';

class DetailPhotoList extends StatelessWidget {
  final bool horizontal;
  final bool hd;

  final int maxPreview;
  final double imageWidth;
  final double imageHeight;
  final List<String> _images;

  DetailPhotoList(this._images, this.maxPreview, this.imageWidth, this.imageHeight, {this.horizontal = true, this.hd = false, Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: horizontal ? 16 : 0),
        itemCount: maxPreview,
        scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
        itemBuilder: (context, index){
          return _photoBox(context, index);
        }
    );
  }

  _photoBox(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal ? 5 : 0, vertical: horizontal ? 0 :10),
      width: imageWidth, height: imageHeight,
      child: GestureDetector(
        child: CachedNetworkImage(imageUrl: (hd ? BACKDROP_IMAGE_PREFIX_HD : BACKDROP_IMAGE_PREFIX) + (_images[index]),
            fit: BoxFit.cover,
            placeholder: (context, _) => Image.asset(BACKDROP_PLACEHOLDER),
            height: imageHeight, width: imageWidth),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) {
                return GalleryPage(_images, initialIndex: index,);
              }
          ));
        },
      ),
    );
  }

}