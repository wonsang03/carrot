// 전역으로 관리되는 사용자 정보
class GlobalState {
  static String? User_ID; // 사용자 로그인 ID
  static String? User_Name; // 사용자 본명
  static String? User_Password; // 사용자 로그인 Password
  static int User_point = 36; // 매너온도 (기본값 설정)
  static int User_Number = 1000000; // 사용자 고유 번호
  static String User_location = ""; // 사용자 지정 위치

  // 로그인 상태 확인
  static bool get isLoggedIn => User_ID != null;

  // 로그아웃
  static void logout() {
    User_ID = null;
    User_Name = null;
    User_Password = null;
    User_point = 0;
    User_Number = 1000000;
    User_location = "";
  }

  // 테스트용 더미 로그인
  static void setDummyUser() {
    User_ID = "testuser@example.com";
    User_Name = "테스트 사용자";
    User_Password = "password";
    User_point = 36;
    User_Number = 1000001;
    User_location = "서울시 강남구";
  }
}
