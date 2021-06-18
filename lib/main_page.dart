import 'package:flutter/material.dart';

import 'grid_page.dart';
import 'list_page.dart';

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
        ],
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
            print("$_selectedTabIndex Tab Clicked");
          });
        },
      ),
    );
  }
}

// 1-2. 탭 화면 (State 구현)
Widget _buildPage(index){
  if(index ==0){
    return ListPage();
  }else{
    return GridPage();
  }
}

// 1-2. 탭 화면 (List, Grid Widget 반환)