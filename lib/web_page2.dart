import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'flutterMessage',
      onMessageReceived: (JavascriptMessage message) {
        print("JSCh============${message.message}");
      }),
].toSet();

final fwp = FlutterWebviewPlugin();

class WebPage_evJS {
  WebPage_evJS(String str){
    print("evJS============${str}");
    fwp.evalJavascript("message1('${str}');");
  }
}

class WebPage_hide {
  WebPage_hide(){
    fwp.hide();
    print("WebPage_hide============");
  }
}

class WebPage_show {
  WebPage_show(){
    fwp.show();
    print("WebPage_show============");
  }
}

class WebPage2 extends StatefulWidget {
  @override
  _WebPage2 createState() => new _WebPage2();
}

class _WebPage2 extends State<WebPage2>{
  @override
  void dispose() {
    fwp.hide();
    fwp.close();
    fwp.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: WebviewScaffold(
            url: "file:///android_asset/flutter_assets/assets/test.html",
            javascriptChannels: jsChannels,
            withLocalUrl: true,
            allowFileURLs: true,
            withJavascript: true,
            withLocalStorage: true,
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