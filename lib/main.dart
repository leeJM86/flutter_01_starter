import 'package:flutter/material.dart';
import 'package:padak_starter/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const cl1 = Colors.green;
  static const cl1_1 = Colors.green;
  static const cl2 = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: cl1,
        buttonColor: cl1,
        appBarTheme: AppBarTheme(
          color: cl1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.shifting,
          backgroundColor: cl1,
          selectedItemColor: cl1,
          unselectedItemColor: cl1.shade100,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: cl2,
        buttonColor: cl2,
        appBarTheme: AppBarTheme(
          color: cl2,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: cl2,
        ),
      ),
      home: MainPage(),
    );
  }
}
