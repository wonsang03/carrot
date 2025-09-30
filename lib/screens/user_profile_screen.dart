import 'package:flutter/material.dart';
// TODO: 나중에 실제 사용자 정보를 담을 User 모델을 import 해야 합니다.
// import '../models/user.dart';

class UserProfileScreen extends StatelessWidget {
  // ✨ [추가] 외부에서 사용자 정보를 전달받기 위한 변수.
  // final User user; // TODO: 실제 User 모델로 교체하세요.
  final dynamic user; // 지금은 임시로 dynamic 타입을 사용합니다.

  // ✨ [수정] 생성자에서 user 객체를 필수로 받도록 변경합니다.
  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✨ [제거] '홍길동'과 같은 모든 하드코딩된 더미 데이터가 제거되었습니다.

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              // ✨ [수정] 이제 외부에서 전달받은 user 객체의 정보를 사용합니다.
              backgroundImage: NetworkImage(user.imageUrl ?? 'https://placehold.co/150x150'),
            ),
            const SizedBox(height: 16),
            Text(user.name ?? '사용자 이름', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user.email ?? '이메일 정보 없음', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('위치: ${user.location ?? '위치 정보 없음'}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 기능은 준비 중입니다.')),
                );
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

