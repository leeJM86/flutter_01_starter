import 'package:flutter/material.dart';
import 'grid_page.dart';
import 'list_page.dart';
//import 'web_page.dart';
import 'web_page2.dart';
import 'video_page.dart';
import 'gallery_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState(){
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage>{
  int _selectedTabIndex = 0;
  var ttt = "test";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie'),
        leading: Icon(Icons.menu),
        actions: <Widget>[
          PopupMenuButton <int>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              if(value == 0){ print("예매율순");}
              else if(value == 1){ print("큐레이순"); }
              else { print("최신순"); }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 0, child: Text("예매유순")),
                PopupMenuItem(value: 1, child: Text("큐레이순")),
                PopupMenuItem(value: 2, child: Text("최신순")),
              ];
            },
          ),
        ],
      ),

      //body: _buildPage(_selectedTabIndex),
      body: Center(
        child: _buildPage(_selectedTabIndex),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            //title: Text("리스트"),
            label: '리스트',
            tooltip: '리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            //title: Text("타일"),
            label: '타일',
            tooltip: '타일',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            //title: Text("타일"),
            label: '웹',
            tooltip: '웹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            //title: Text("타일"),
            label: '비데오',
            tooltip: '비데오',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            //title: Text("타일"),
            label: '갤러리',
            tooltip: '갤러리',
          ),
        ],
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            if(index < 3){
            _selectedTabIndex = index;
            }else if(index >= 3){
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 200),
                  reverseTransitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    if(_selectedTabIndex == 2) {
                      WebPage_hide();
                    }
                    if(index == 3){
                      return videoPage();
                    }else{
                      return galleryPage();
                    }
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var curve = Curves.fastLinearToSlowEaseIn;

                    var tween = Tween(begin: begin, end: end);
                    var curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    );

                    if(_selectedTabIndex == 2 && animation.status == AnimationStatus.reverse) {
                      WebPage_show();
                    }

                    return SlideTransition(
                      position: tween.animate(curvedAnimation),
                      child: child,
                    );
                  },
                ),
              );
            }
            print("$_selectedTabIndex Tab Clicked");
          });
        },
      ),
    );
  }
}

// 1-2. 탭 화면 (State 구현)
Widget _buildPage(index){
  if(index == 0){
    return ListPage();
  }else if(index == 1){
    return GridPage();
  }else if(index == 2){
    return WebPage2();
  }else{
    return null;
  }
}

// 1-2. 탭 화면 (List, Grid Widget 반환)