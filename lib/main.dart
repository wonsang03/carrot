import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page.dart';

// 앱의 진입점(main 함수)
// .env 파일을 비동기적으로 로드해야 하므로 main 함수를 async로 변경합니다.
Future<void> main() async {
  // Flutter 엔진과 위젯 트리를 바인딩합니다. main 함수가 비동기가 되면 필수적으로 호출해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env 파일을 로드하여 환경 변수를 준비합니다.
  await dotenv.load(fileName: ".env");

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
