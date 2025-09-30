import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';

class ChatListScreen extends StatefulWidget {
  final void Function(ChatRoom, String) onRoomTap;
  const ChatListScreen({Key? key, required this.onRoomTap}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatRoom>> futureChatRooms;

  // 실제 Supabase 사용자 UUID (이 값은 이제 고정됩니다)
  final String myUserId = '8ac96703-506e-40fe-9ad2-5ba09d9896d5';

  @override
  void initState() {
    super.initState();

    // 이제 initState에는 API 호출 코드만 남습니다.
    futureChatRooms = ApiService.fetchChatRooms(myUserId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatRoom>>(
      future: futureChatRooms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 서버 통신 중 발생하는 실제 에러를 표시합니다.
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final chatRooms = snapshot.data!;
          if (chatRooms.isEmpty) {
            return const Center(child: Text('참여 중인 채팅방이 없습니다.'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, i) {
              final room = chatRooms[i];
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(room.name),
                subtitle: Text(room.lastMessage),
                onTap: () => widget.onRoomTap(room, myUserId),
              );
            },
          );
        } else {
          return const Center(child: Text('채팅방이 없습니다.'));
        }
      },
    );
  }
}

