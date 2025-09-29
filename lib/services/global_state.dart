// lib/services/global_state.dart
// 🌍 전역으로 관리되는 사용자 정보 클래스
// ⭐ 개발 단계에서는 사용자를 1명으로 고정하여 사용

class GlobalState {
  // ===== 👤 사용자 기본 정보 =====
  static String? User_ID;                    // 사용자 로그인 ID (이메일)
  static String? User_Name;                  // 사용자 본명
  static String? User_Password;              // 사용자 로그인 Password
  static int User_Point = 40;                // 매너온도 (기본값: 40도로 높게 설정) ⭐ 수정
  static int User_Number = 1;                // ⭐ 개발용 고정 사용자 번호 (1번으로 고정)
  static String User_Location = "";          // 사용자 지정 위치 ⭐ User_location → User_Location

  // ===== 🔍 로그인 상태 확인 =====
  /// 사용자가 로그인되어 있는지 확인
  static bool get isLoggedIn => User_ID != null && User_ID!.isNotEmpty;

  // ===== 🚪 로그아웃 =====
  /// 모든 사용자 정보를 초기화
  static void logout() {
    print('🔓 사용자 로그아웃 처리 중...');

    User_ID = null;
    User_Name = null;
    User_Password = null;
    User_Point = 40;                         // ⭐ 기본값 40도
    User_Number = 1;                         // ⭐ 개발용으로 다시 1로 설정
    User_Location = "";                      // ⭐ 대문자 L

    print('✅ 로그아웃 완료');
  }

  // ===== 👑 개발용 고정 사용자 설정 (⭐ 핵심 함수) =====
  /// 개발 단계에서 사용할 고정 사용자 정보 설정
  /// 모든 상품 등록과 테스트는 이 사용자로 진행됩니다
  static void setDevelopmentUser() {
    print('👑 개발용 고정 사용자 설정 중...');

    // ⭐ 개발용 고정 정보 - 실제 DB에 이 정보가 있어야 함
    User_ID = "dev@dapamarket.com";           // 개발용 이메일
    User_Name = "개발자";                      // 개발용 이름
    User_Password = "dev123";                 // 개발용 비밀번호
    User_Point = 42;                         // 높은 매너온도
    User_Number = 1;                         // ⭐ 항상 1번 사용자로 고정
    User_Location = "서울시 강남구 테헤란로";    // 개발용 위치 ⭐ 대문자 L

    print('✅ 개발용 사용자 설정 완료!');
    print('📋 사용자 정보:');
    print('   - 번호: $User_Number (⭐ 개발용 고정)');
    print('   - 이름: $User_Name');
    print('   - ID: $User_ID');
    print('   - 위치: $User_Location');
    print('   - 매너온도: ${User_Point}°C');
  }

  // ===== 🧪 기존 호환성용 더미 사용자 함수 =====
  /// 기존 코드와 호환성을 위해 남겨둠 (실제로는 setDevelopmentUser 호출)
  static void setDummyUser() {
    print('🔄 setDummyUser 호출 → setDevelopmentUser로 리다이렉트');
    setDevelopmentUser(); // ⭐ 개발용 사용자 설정으로 통일
  }

  // ===== 🚀 앱 초기화 함수 (⭐ 핵심) =====
  /// 앱 시작 시 호출되는 초기화 함수
  /// 개발 단계에서는 자동으로 고정 사용자로 설정
  static void initializeApp() {
    print('\n🚀 대파마켓 앱 초기화 시작...');
    print('📅 현재 시간: ${DateTime.now()}');
    print('🔧 개발 모드: 사용자 1명 고정');

    // ⭐ 개발용 고정 사용자로 자동 설정
    setDevelopmentUser();

    print('✅ 앱 초기화 완료!\n');
  }

  // ===== 📝 사용자 정보 업데이트 함수들 =====

  /// 매너온도 업데이트
  static void updateUserPoint(int newPoint) {
    if (newPoint >= 0 && newPoint <= 100) {
      User_Point = newPoint;
      print('🌡️ 매너온도 업데이트: ${User_Point}°C');
    } else {
      print('❌ 잘못된 매너온도: $newPoint (0-100 사이만 가능)');
    }
  }

  /// 사용자 위치 업데이트 ⭐ User_location → User_Location
  static void updateUserLocation(String newLocation) {
    if (newLocation.isNotEmpty) {
      User_Location = newLocation;   // ⭐ 대문자 L
      print('📍 위치 업데이트: $User_Location');
    } else {
      print('❌ 빈 위치는 설정할 수 없습니다');
    }
  }

  /// 사용자 이름 업데이트
  static void updateUserName(String newName) {
    if (newName.isNotEmpty) {
      User_Name = newName;
      print('👤 이름 업데이트: $User_Name');
    } else {
      print('❌ 빈 이름은 설정할 수 없습니다');
    }
  }

  // ===== 🔍 디버깅 및 정보 출력 =====

  /// 현재 사용자 정보를 콘솔에 출력
  static void printCurrentUser() {
    print('\n' + '='*50);
    print('🔍 현재 사용자 정보');
    print('='*50);
    print('로그인 상태: ${isLoggedIn ? "✅ 로그인됨" : "❌ 로그아웃됨"}');

    if (isLoggedIn) {
      print('사용자 번호: $User_Number ⭐ (개발용 고정)');
      print('사용자 ID: $User_ID');
      print('사용자 이름: $User_Name');
      print('매너온도: ${User_Point}°C');
      print('위치: $User_Location');  // ⭐ 대문자 L
    } else {
      print('로그인이 필요합니다.');
    }
    print('='*50 + '\n');
  }

  /// 간단한 사용자 정보 출력
  static void printUserSummary() {
    if (isLoggedIn) {
      print('👤 현재 사용자: $User_Name (번호: $User_Number ⭐ 고정, 매너온도: ${User_Point}°C)');
    } else {
      print('❌ 로그인된 사용자가 없습니다');
    }
  }

  // ===== 📊 데이터 변환 =====

  /// 사용자 정보를 Map으로 변환 (API 호출 시 사용)
  static Map<String, dynamic> toJson() {
    return {
      'User_Number': User_Number,      // ⭐ 항상 1
      'User_ID': User_ID,
      'User_Name': User_Name,
      'User_Point': User_Point,
      'User_Location': User_Location,  // ⭐ 대문자 L
    };
  }

  /// Map 데이터로부터 사용자 정보 설정
  static void fromJson(Map<String, dynamic> json) {
    User_Number = json['User_Number'] ?? 1;    // ⭐ 기본값 1
    User_ID = json['User_ID'];
    User_Name = json['User_Name'];
    User_Point = json['User_Point'] ?? 40;     // 기본값 40도
    User_Location = json['User_Location'] ?? '';  // ⭐ 대문자 L

    print('📥 JSON으로부터 사용자 정보 로드: $User_Name');
  }

  // ===== 🔧 유틸리티 =====

  /// 현재 사용자가 개발용 사용자인지 확인
  static bool get isDevelopmentUser => User_Number == 1 && User_ID == "dev@dapamarket.com";

  /// 사용자 매너온도 등급 반환
  static String getUserGrade() {
    if (User_Point >= 50) return '🔥 최고';
    if (User_Point >= 40) return '😊 좋음';
    if (User_Point >= 30) return '😐 보통';
    return '😟 나쁨';
  }

  /// 앱 종료 시 정리
  static void dispose() {
    print('🔄 GlobalState 정리 중...');
    print('✅ GlobalState 정리 완료');
  }
}