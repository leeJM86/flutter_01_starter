import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'flutterMessage',
      onMessageReceived: (JavascriptMessage message) {
        print("JSCh============${message.message}");
      }),
].toSet();

WebViewController wc;

class WebPage_evJS {
  WebPage_evJS(String str){
    print("evJS============${str}");
    wc.evaluateJavascript("message1('${str}');");
  }
}

class WebPage extends StatefulWidget {
  @override
  _WebPage createState() => new _WebPage();
}

class _WebPage extends State<WebPage>{
  @override
  build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
           child: WebView(
             initialUrl: "file:///android_asset/flutter_assets/assets/test.html",
             javascriptMode: JavascriptMode.unrestricted,
             javascriptChannels: jsChannels,
             onWebViewCreated: (controller) {
               wc = controller;
             },
           ),
        ),
        SizedBox(
          child: TextButton(
            child: Text("button"),
            onPressed: () {
              WebPage_evJS("sdfasfgaefd");
            },
          ),
          height: 40,
        ),
      ],
    );

    /*return WebView(
      initialUrl: "file:///android_asset/flutter_assets/assets/test.html",
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: jsChannels,
    );*/

    /*final flutterWebViewPlugin = FlutterWebviewPlugin();

    return WebviewScaffold(
      withLocalUrl: true,
      url: "file:///android_asset/flutter_assets/assets/test.html",
      withJavascript: true,
      javascriptChannels: jsChannels,
    );*/
  }
}