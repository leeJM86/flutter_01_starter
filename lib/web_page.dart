import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';

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
  initArchive() async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    final zipFile = File("assets/web.zip");
    final destinationDir = Directory("${appDocPath}/web").create();

    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            print('progress: ${progress.toStringAsFixed(1)}%');
            print('name: ${zipEntry.name}');
            print('isDirectory: ${zipEntry.isDirectory}');
            print(
                'modificationDate: ${zipEntry.modificationDate.toLocal().toIso8601String()}');
            print('uncompressedSize: ${zipEntry.uncompressedSize}');
            print('compressedSize: ${zipEntry.compressedSize}');
            print('compressionMethod: ${zipEntry.compressionMethod}');
            print('crc: ${zipEntry.crc}');
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initArchive();
  }

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
        /*Expanded(
          child: WebviewScaffold(
            url: "file:///android_asset/flutter_assets/assets/test.html",
            javascriptChannels: jsChannels,
            withLocalUrl: true,
            allowFileURLs: true,
            withJavascript: true,
            withLocalStorage: true,
          ),
        ),*/
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
  }
}