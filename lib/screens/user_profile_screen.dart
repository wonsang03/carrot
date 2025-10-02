import 'package:flutter/material.dart';
// TODO: 나중에 실제 사용자 정보를 담을 User 모델을 import 해야 합니다.
// import '../models/user.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // UserProfileScreen에서 사용할 데이터 추출 (null-safety 및 타입 캐스팅 고려)
    String userId = user['User_ID']?.toString() ?? '사용자 ID 없음';
    String userLocation = user['User_Location']?.toString() ?? '위치 정보 없음';
    String userNumber = user['User_Number']?.toString() ?? '고유번호 정보 없음';
    // String userPassword = user['User_Password']?.toString() ?? ''; // 화면에 표시하지 않으므로 변수 선언 불필요
    int userPoint = user['User_point'] is int ? user['User_point'] : (user['User_point'] is String ? int.tryParse(user['User_point'] ?? '0') ?? 0 : 0);
    String? imageUrl = user['imageUrl']?.toString();
    // email 필드는 HomePage의 _prepareUserProfileData에서 현재 주석 처리되어 있으므로 여기서는 기본값을 사용하거나 표시하지 않음.
    // String userEmail = user['email']?.toString() ?? '이메일 정보 없음';

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              backgroundColor: Colors.grey[200], // 이미지 없을 때 배경색
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.grey) // 기본 아이콘
                  : null,
            ),
            const SizedBox(height: 20), // 프로필 이미지와 사용자 ID 사이의 간격
            Text(userId, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center), // 사용자 ID 표시
            const SizedBox(height: 12), // 사용자 ID와 정보 목록 사이의 간격

            // 프로필 정보들을 헬퍼 위젯을 사용하여 표시
            _buildProfileInfoRow(Icons.person_pin_circle_outlined, '고유번호', userNumber),
            _buildProfileInfoRow(Icons.location_on_outlined, '위치', userLocation),
            _buildProfileInfoRow(Icons.thermostat_outlined, '매너온도', '$userPoint °C'),

            //일단 유지
            // email 필드가 필요하다면 아래 주석 해제 및 HomePage에서 데이터 제공 필요
            // _buildProfileInfoRow(Icons.email_outlined, '이메일', userEmail),

            const Spacer(), // 정보 목록과 하단 버튼 사이의 공간을 채움 (버튼을 하단으로 밀어냄)
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // 버튼 배경색
                foregroundColor: Colors.white, // 버튼 글자 및 아이콘 색상
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // 버튼 내부 여백
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // 버튼 글자 스타일
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 기능은 준비 중입니다.')),
                );
              },
            ),
            const SizedBox(height: 20), // 화면 하단 여백
          ],
        ),
      ),
    );
  }

  // 프로필 정보 행(Row)을 만드는 헬퍼 위젯 함수
  // - icon: 정보 왼쪽에 표시될 아이콘 데이터 (예: Icons.location_on_outlined)
  // - label: 정보의 종류를 나타내는 문자열 (예: "위치")
  // - value: 실제 정보 값을 나타내는 문자열 (예: "서울시 강남구")
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    // Padding 위젯: Row 주변에 상하로 8.0의 여백을 줍니다.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Row 위젯: 자식 위젯들을 가로로 나란히 배치합니다.
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center; // 이전 중앙 정렬 주석 처리 (아래 Expanded로 인해 레이블과 값 정렬이 더 중요)
        crossAxisAlignment: CrossAxisAlignment.start, // 아이콘과 텍스트를 상단 기준으로 정렬
        children: [
          // Icon 위젯: 전달받은 icon 데이터를 화면에 아이콘으로 표시합니다.
          Icon(icon, color: Colors.grey[700], size: 20),
          // SizedBox 위젯: 아이콘과 레이블 텍스트 사이에 가로로 12.0의 고정된 간격을 만듭니다.
          const SizedBox(width: 12),
          // Text 위젯: 레이블 문자열(예: "위치:")을 표시합니다.
          Text(
            '$label:', // 전달받은 label 뒤에 콜론(:)을 붙입니다.
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          // SizedBox 위젯: 레이블 텍스트와 값 텍스트 사이에 가로로 8.0의 고정된 간격을 만듭니다.
          const SizedBox(width: 8),
          // Expanded 위젯: 남은 가로 공간을 모두 차지하도록 자식 위젯(Text)을 확장합니다.
          // 이렇게 하면 정보 값(value)이 길어져도 화면 밖으로 넘어가지 않고, 다음 줄로 자동 줄바꿈되거나 잘립니다 (ellipsis).
          Expanded(
            // Text 위젯: 실제 정보 값(value)을 표시합니다.
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start, // 텍스트를 시작점(왼쪽) 기준으로 정렬합니다.
              overflow: TextOverflow.ellipsis, // 텍스트가 너무 길어서 한 줄에 다 안 보일 경우, 말줄임표(...)로 표시합니다.
            ),
          ),
        ],
      ),
    );
  }
}
