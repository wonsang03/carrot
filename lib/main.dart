// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 파일 구조상 'lib/screens/home_page.dart'에 파일이 있으므로 아래 경로가 정확합니다.
import 'screens/home_page.dart';

// ✅ 대파마켓의 초록색 메인 테마 정의 (dapaGreen을 여기에 정의하여 전역으로 사용)
const MaterialColor dapaGreen = MaterialColor(
  0xFF4CAF50, // 메인 초록색 (Green 500)
  <int, Color>{
    50: Color(0xFFE8F5E9),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF4CAF50), // Main Color
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  },
);

// 앱의 진입점(main 함수)
Future<void> main() async {
  // Flutter 엔진과 위젯 트리를 바인딩
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일을 로드
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

// 앱 전체의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대파마켓 클론', // ✅ 앱 이름 변경 (당근마켓 클론 -> 대파마켓 클론)
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: ThemeData(
        primarySwatch: dapaGreen, // ✅ 기본 테마를 초록색 계열로 변경
        primaryColor: dapaGreen[500], // ✅ 기본 Primary Color 설정
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[50],
        // ✅ AppBar와 IconTheme의 기본 색상을 초록색 테마로 설정
        appBarTheme: AppBarTheme(
          color: dapaGreen[500],
          foregroundColor: Colors.white, // AppBar 글자 및 아이콘 색상
        ),
        // ✅ 버튼 테마 설정 (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: dapaGreen[500],
            foregroundColor: Colors.white,
          ),
        ),
        // ✅ 텍스트 버튼 및 기타 액션 색상 설정
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: dapaGreen[700], // 텍스트 버튼 색상
          ),
        ),
      ),
      // HomePage는 StatefulWidget이므로 const를 붙이지 않습니다.
      home: const HomePage(),
    );
  }
}