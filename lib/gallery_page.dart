import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// 아이템 갯수
int _itemcount = 6;

class galleryPage extends StatefulWidget {
  @override
  State <StatefulWidget> createState() {
    return _galleryPage();
  }
}

class _galleryPage extends State<galleryPage>{
  double _contextHeightPercent = 100;
  double _contextWidthPercent = 100;
  //_contextHeight = MediaQuery.of(context).size.height / 100;
  //_contextWidth = MediaQuery.of(context).size.width / 100;

  // 무한 반복 넘기기를 위해 initialPage 설정 및 *100으로 설정
  PageController _pageController = PageController(initialPage: (_itemcount*100));
  TransformationController _transformationController = TransformationController();
  double interactiveScale = 1.0;
  // 확대시 페이지 넘기기 막기위해 physics 설정
  ScrollPhysics pageph = PageScrollPhysics();

  int _currentPage = _itemcount*100; //현재 갤러리 페이지
  int _currentIcon = 0;
  int _currentSet = 0; // 현재 갤러리 셋트

  void _pageListener() {
    if(_pageController.position.activity.velocity == 0.0){
      setState(() {
        _currentIcon = (_currentPage%_itemcount);
      });
    }
  }

  void _onInteractionUpdate(){
    setState(() {
      interactiveScale = _transformationController.value.getMaxScaleOnAxis();
      if(interactiveScale > 1) {
        pageph = NeverScrollableScrollPhysics();
      }else{
        pageph = PageScrollPhysics();
      }
    });
  }

  void directoryInit() async{
    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir.path;
    var test1 = Directory(appDocPath);

    print(appDocPath);
    print(test1.listSync().length);
    print("=====================================");
    for(var i=0; i<test1.listSync().length; i++){
      print(test1.listSync().elementAt(i));

      if(test1.listSync().elementAt(i) is Directory){
        print("▼=====================================");
        var test2 = Directory(test1.listSync().elementAt(i).path);
        print(test2.listSync().length);
        test2.listSync().forEach((element) {
          print(element);
        });
      }
    }
    print("=====================================");

    List appDocDir2 = await getExternalStorageDirectories(type: StorageDirectory.dcim);
    appDocDir2.forEach((element) {
      print(element);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
    directoryInit();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _contextHeightPercent = MediaQuery.of(context).size.height / 100;
    _contextWidthPercent = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
      ),

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            physics: pageph,
            controller: _pageController,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 10,
                transformationController: _transformationController,
                constrained: true,
                child: Image(
                  fit: BoxFit.scaleDown,
                  image: AssetImage("assets/gallery/1/g${(index)%_itemcount+1}.jpg"),
                ),
                onInteractionUpdate: (details) {
                  _onInteractionUpdate();
                },
              );
            },
            onPageChanged: (value) {
              _currentSet = (value%(_itemcount*100)-(value%_itemcount));
              _currentPage = value;
            },
          ),
          Container(
            height: 10*_contextHeightPercent,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _itemcount,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 2*_contextWidthPercent),
                  width: 4*_contextWidthPercent,
                  height: 4*_contextWidthPercent,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5*_contextWidthPercent, color: Colors.black.withOpacity(0.2)),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.circle),
                    color: (index == _currentIcon) ? Colors.white.withOpacity(1) : Colors.white.withOpacity(0.5),
                    splashRadius: 6*_contextWidthPercent,
                    iconSize: 3*_contextWidthPercent,
                    onPressed: () {
                      _pageController.animateToPage(
                        (_itemcount*100) + _currentSet + index,
                        duration: Duration(milliseconds: 500,),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(right: 4*_contextWidthPercent, top: 5*_contextWidthPercent),
            child: interactiveScale > 1 ? CircleAvatar(
              radius: 6*_contextWidthPercent,
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: Icon(Icons.close_fullscreen, size: 6*_contextWidthPercent,),
                color: Colors.black.withOpacity(0.5),
                onPressed: () {
                  _transformationController.value = Matrix4.identity();
                  _onInteractionUpdate();
                },
              ),
            ) : null,
          ),
        ],
      ),
    );
  }
}