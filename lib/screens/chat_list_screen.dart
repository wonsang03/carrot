import 'package:flutter/material.dart';
import '../models/chat_room.dart';           // 채팅방 데이터 모델
import '../services/api_service.dart';       // 서버와 통신하는 서비스

// 📋 채팅 목록 화면 위젯 (하단 탭에서 채팅을 누르면 보임)
class ChatListScreen extends StatefulWidget {
  final void Function(ChatRoom) onRoomTap;   // 채팅방 클릭 시 실행할 함수
  const ChatListScreen({Key? key, required this.onRoomTap}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

// 채팅 목록 화면의 상태를 관리하는 클래스
class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatRoom>> futureChatRooms; // 서버에서 받아올 채팅방 목록

  @override
  void initState() {
    super.initState();
    // --- 수정된 부분: ApiService가 String을 받도록 변경되었으므로, 숫자 1을 문자열 '1'로 수정 ---
    // 실제 앱에서는 로그인된 사용자의 ID(String)를 사용해야 합니다.
    futureChatRooms = ApiService.fetchChatRooms('1');
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder: 서버에서 데이터를 받아올 때 화면을 자동으로 갱신해주는 위젯
    return FutureBuilder<List<ChatRoom>>(
      future: futureChatRooms, // 서버에서 받아올 데이터
      builder: (context, snapshot) {
        // 1. 데이터를 받아오는 중이면 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          // 2. 에러가 나면 에러 메시지 표시
        } else if (snapshot.hasError) {
          return Center(child: Text('채팅 목록을 불러올 수 없습니다.'));
          // 3. 데이터가 정상적으로 오면 채팅방 목록을 화면에 표시
        } else if (snapshot.hasData) {
          final chatRooms = snapshot.data!;
          // 채팅방이 하나도 없으면 안내 메시지 표시
          if (chatRooms.isEmpty) {
            return const Center(child: Text('채팅방이 없습니다.'));
          }
          // 채팅방이 있으면 리스트로 화면에 표시
          return ListView.builder(
            itemCount: chatRooms.length, // 채팅방 개수만큼 반복
            itemBuilder: (context, i) {
              final room = chatRooms[i];
              return ListTile(
                title: Text(room.name),           // 채팅방 이름
                subtitle: Text(room.lastMessage), // 마지막 메시지
                onTap: () => widget.onRoomTap(room), // 채팅방 클릭 시 상세 화면으로 이동
              );
            },
          );
          // 4. 그 외의 경우 (예상치 못한 상황)
        } else {
          return const Center(child: Text('알 수 없는 오류'));
        }
      },
    );
  }
}