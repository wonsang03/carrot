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
      // ✨ [수정된 부분]
      // HomePage가 상태를 가지는 StatefulWidget이 되었으므로 const 키워드를 제거합니다.
      home: HomePage(),
    );
  }
}
