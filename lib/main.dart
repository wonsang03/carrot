import 'package:flutter/material.dart';
import 'screens/home_page.dart';

// 앱의 진입점(main 함수)
void main() {
  // runApp()은 앱 전체의 루트 위젯을 실행합니다.
  runApp(const MyApp());
}

// 앱 전체의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당근마켓 클론',
      debugShowCheckedModeBanner: false, // 오른쪽 상단 debug 배너 숨김
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomePage(), // 앱 시작 시 보여줄 첫 화면
    );
  }
}
