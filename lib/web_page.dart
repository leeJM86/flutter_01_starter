import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_assets_server/local_assets_server.dart';

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

class WebPage extends StatefulWidget {
  @override
  _WebPage createState() => new _WebPage();
}

class _WebPage extends State<WebPage>{
  var server;

  initWeb() async{
    final String zipName = "seedusnetWebBook_v1_cheongyang_2020.zip";
    final webZip = await rootBundle.load("assets/${zipName}");

    final Directory appCacheDir = await getTemporaryDirectory();
    final String appCachePath = appCacheDir.path;

    final String homePath = "web";
    Directory("${appCachePath}/${homePath}").create();

    String address;
    int port;

    final zipFile = File("${appCachePath}/${homePath}/${zipName}");
    await zipFile.writeAsBytes(webZip.buffer.asUint8List(webZip.offsetInBytes, webZip.lengthInBytes));

    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: Directory("${appCachePath}/${homePath}"),
          onExtracting: (zipEntry, progress) {
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      print("extractToDirectory Error:${e}");
    } finally {
      server = new LocalAssetsServer(
        address: InternetAddress.loopbackIPv4,
        rootDir: Directory("${appCachePath}/${homePath}"),
        logger: DebugLogger(),
      );

      final serverAddress = await server.serve();

      address = serverAddress.address;
      port = server.boundPort;

      print("http://$address:$port/");

      fwp.reloadUrl("http://$address:$port/");
    }
  }

  @override
  void initState() {
    initWeb();
    super.initState();
  }

  @override
  void dispose() {
    fwp.hide();
    fwp.close();
    fwp.dispose();
    server?.stop();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: WebviewScaffold(
            url: "none",
            allowFileURLs: true,
            withJavascript: true,
            withLocalStorage: true,
            withLocalUrl: true,
            mediaPlaybackRequiresUserGesture: true,
            useWideViewPort: true,
            debuggingEnabled: true,
            javascriptChannels: jsChannels,
          ),
        ),
        SizedBox(
          child: TextButton(
            child: Text("button"),
            onPressed: () {
              //print("file:///${appDocPath}/file/index.html");
              //fwp.reloadUrl("file:///${appDocPath}/file/index.html");
              WebPage_evJS("sdfasfgaefd");
            },
          ),
          height: 40,
        ),
      ],
    );
  }
}