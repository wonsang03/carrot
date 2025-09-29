// lib/main.dart
// 🚀 대파마켓 앱의 진입점 - 개발용 고정 사용자 적용

import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'services/global_state.dart';  // ⭐ 개발용 사용자 정보

/// 🚀 앱의 시작점
/// 개발 단계에서는 자동으로 1번 사용자로 고정 로그인
void main() {
  print('\n' + '=' * 60);
  print('🚀 대파마켓 앱 시작!');
  print('📅 실행 시간: ${DateTime.now()}');
  print('🔧 개발 모드: 사용자 1명 고정');
  print('=' * 60 + '\n');

  // Flutter 초기화 (플러그인 사용 시 필수)
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter 위젯 바인딩 초기화 완료');

  // ⭐ 개발용 고정 사용자로 자동 초기화
  GlobalState.initializeApp();
  print('✅ 개발용 사용자 초기화 완료');

  // 앱 실행
  runApp(const MyApp());
  print('✅ Flutter 앱 실행 완료\n');
}

/// 📱 앱 전체의 루트 위젯
/// 대파마켓(당근마켓 클론)에 맞는 테마 설정
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎨 MyApp build 시작...');

    return MaterialApp(
      // ===== 📱 앱 기본 정보 =====
      title: '대파마켓 - 당근마켓 클론',
      debugShowCheckedModeBanner: false,  // DEBUG 배너 숨김

      // ===== 🎨 앱 테마 설정 =====
      theme: ThemeData(
        // 주 색상: 당근마켓 스타일 주황색
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFF6F00),

        // 폰트 설정
        fontFamily: 'Roboto',

        // 전체 배경색
        scaffoldBackgroundColor: Colors.grey[50],

        // ===== 🎴 카드 스타일 =====
        // 카드 테마 설정, CardThemeData 로 변경
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        // ===== 📱 앱바 스타일 =====
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),

        // ===== 🔘 플로팅 액션 버튼 =====
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF6F00),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // ===== 📝 텍스트 테마 =====
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          headlineMedium: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        // ===== 🔘 버튼 스타일 =====
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6F00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 2,
          ),
        ),

        // ===== 📝 입력 필드 스타일 =====
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF6F00), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        // ===== 🎯 컬러 스킴 =====
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(
          secondary: const Color(0xFFFF8F00),
          surface: Colors.white,
          error: Colors.red,
        ),
      ),

      // ===== 🏠 시작 화면 =====
      home: const HomePage(),

      // ===== 🔧 글로벌 설정 =====
      builder: (context, child) {
        print('🔧 앱 글로벌 설정 적용 중...');

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,  // 텍스트 크기 고정
          ),
          child: child!,
        );
      },
    );
  }
}

/// 🔧 앱 정보 클래스
class AppInfo {
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String appName = '대파마켓';
  static const bool isDevelopmentMode = true;  // ⭐ 개발 모드 플래그

  static String get fullVersion => '$version+$buildNumber';

  /// 앱 정보 출력
  static void printAppInfo() {
    print('📱 앱 정보:');
    print('   - 이름: $appName');
    print('   - 버전: $fullVersion');
    print('   - 개발 모드: $isDevelopmentMode');  // ⭐ 개발 모드 표시
    print('   - 고정 사용자: ${GlobalState.User_Name} (번호: ${GlobalState.User_Number})');
  }
}

/// 앱 종료 시 정리 작업
void dispose() {
  print('🧹 앱 종료 - 정리 작업 시작');

  // 전역 상태 정리
  GlobalState.dispose();

  print('✅ 앱 정리 작업 완료');
}
