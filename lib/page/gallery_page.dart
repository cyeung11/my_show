import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_show/network/api_constant.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget{

  final List<String> photoPaths;
  final int initialIndex;

  GalleryPage(this.photoPaths, {this.initialIndex = 0, Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>{

  var _currentPage = 0;

  var _fullscreen = false;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[
      Container(
          color: Colors.black,
          child: PhotoViewGallery.builder(
            pageController: PageController(initialPage: widget.initialIndex),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider((BACKDROP_IMAGE_PREFIX_HD + widget.photoPaths[index])),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  initialScale: PhotoViewComputedScale.contained,
                  onTapUp: (context, d, c){
                    setState(() {
                      _fullscreen = !_fullscreen;
                    });
                  }
              );
            },
            itemCount: widget.photoPaths.length,
            onPageChanged: (i){
              setState(() {
                _currentPage = i;
              });
            },
            loadingChild: Container(
              color: Colors.black,
              child: Icon(
                Icons.cloud_off,
                size: 50,
                color: Colors.grey,
              ),
            ),
          )
      ),
    ];

//    if (!_fullscreen) {

    widgetList.add(Positioned(
        left: 12,
        child: AnimatedOpacity(
          curve: Curves.easeIn,
          opacity: _fullscreen ? 0 : 1,
          duration: Duration(milliseconds: 200),
          child:  SafeArea(
            child: BackButton(color: Colors.white70,),
          ),
        )),
    );
    widgetList.add(Positioned(
        right: 20,
        bottom: 20,
        child: AnimatedOpacity(
          curve: Curves.easeIn,
          opacity: _fullscreen ? 0 : 1,
          duration: Duration(milliseconds: 200),
          child:  Text('Credit: TMDb',
            style: TextStyle(
                color: Colors.white70
            ),
          ),
        )),
    );


    if (widget.photoPaths.length > 1) {
      widgetList.add(Positioned(
          left: 20,
          bottom: 20,
          child: AnimatedOpacity(
            curve: Curves.easeIn,
            opacity: _fullscreen ? 0 : 1,
            duration: Duration(milliseconds: 200),
            child:  Text('${_currentPage + 1}/${widget.photoPaths.length}',
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
          )),
      );
    }

    return Scaffold(
      body: Stack(
          alignment: Alignment.topLeft,
          children: widgetList
      ),
    );
  }
}