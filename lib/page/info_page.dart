import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../asset_path.dart';

class InfoPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebView(
          initialUrl: 'about:blank',
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