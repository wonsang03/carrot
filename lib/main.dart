import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 파일 구조상 'lib/screens/home_page.dart'에 파일이 있으므로 아래 경로가 정확합니다.
import 'screens/home_page.dart';

// 앱의 진입점(main 함수)
Future<void> main() async {
  // Flutter 엔진과 위젯 트리를 바인딩
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일을 로드 (파일이 없다면 이 줄은 에러가 날 수 있으니 .env 파일 확인 필요)
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

// 앱 전체의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당근마켓 클론',
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // HomePage는 StatefulWidget이므로 const를 붙이지 않습니다.
      home: HomePage(),
    );
  }
}