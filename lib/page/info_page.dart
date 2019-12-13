import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../asset_path.dart';

class InfoPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          title: Text(
            'About this App',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
          leading: IconButton(
              icon: Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.maybePop(context);
              },
            )
        ),
        body: WebView(
          initialUrl: 'about:blank',
          navigationDelegate: (request) async{
            if (await canLaunch(request.url)) {
              await launch(request.url);
            }
            return NavigationDecision.prevent;
          },
          onWebViewCreated: (WebViewController webViewController){
            _loadHtmlFromAssets(webViewController);
          },
        ),
      ),
    );
  }

  _loadHtmlFromAssets(WebViewController webViewController) async {
    String fileHtmlContents = await rootBundle.loadString(INFO_HTML);
    webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}