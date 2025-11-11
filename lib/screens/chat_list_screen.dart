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

  //아직 DB에서 원하는 값 못 받아와서 일단 더미 데이터 만들어두었음.
  // ✨ [추가] UI 테스트를 위한 더미 데이터 생성 함수
  Future<List<ChatRoom>> _fetchDummyChatRooms() async {
    // 1초간의 가짜 딜레이를 주어 실제 네트워크 통신처럼 보이게 합니다.
    await Future.delayed(const Duration(seconds: 1));

    // 백엔드 API가 완성되면 보내줄 것으로 기대하는 데이터의 예시입니다.
    return [
      ChatRoom(
        Chat_Number: 'dummy-room-1',
        name: '백엔드 개발자',
        lastMessage: '네, API 수정해서 보내드릴게요!',
        time: '오후 10:45',
        unreadCount: 2,
        avatarUrl: '', // 프로필 이미지가 없을 경우
      ),
      ChatRoom(
        Chat_Number: 'dummy-room-2',
        name: '프론트엔드 개발자',
        lastMessage: '확인 감사합니다. 기다리겠습니다.',
        time: '오후 10:42',
        unreadCount: 0,
        avatarUrl: 'https://i.pravatar.cc/150?img=1', // 프로필 이미지가 있는 경우
      ),
      ChatRoom(
        Chat_Number: 'dummy-room-3',
        name: '디자이너',
        lastMessage: '아이콘은 이걸로 사용해주세요.',
        time: '오전 09:10',
        unreadCount: 1,
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    //더미데이터 지울때 수정 필요한 부분
    // ✨ [수정] 기존 API 호출 대신 더미 데이터 함수를 호출하도록 임시 변경합니다.
    // 백엔드 API가 완성되면 이 부분을 다시 원래대로 돌려놓으면 됩니다.
    // futureChatRooms = ApiService.fetchChatRooms(myUserId);
    futureChatRooms = _fetchDummyChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatRoom>>(
      future: futureChatRooms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final chatRooms = snapshot.data!;
          if (chatRooms.isEmpty) {
            return const Center(child: Text('참여 중인 채팅방이 없습니다.'));
          }

          // ✨ [수정] 더미 데이터로 UI가 잘 나오는지 확인하기 위해 ListTile을 개선합니다.
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, i) {
              final room = chatRooms[i];
              
              // 아바타 URL이 있으면 네트워크 이미지를, 없으면 기본 아이콘을 보여줍니다.
              final leadingWidget = room.avatarUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(room.avatarUrl),
                    )
                  : const CircleAvatar( // 기본 아바타
                      child: Icon(Icons.person),
                    );

              return ListTile(
                leading: leadingWidget,
                title: Text(room.name),
                subtitle: Text(room.lastMessage),
                // 안 읽은 메시지가 있으면 빨간 점으로 표시합니다.
                trailing: room.unreadCount > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          room.unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : null, // 없으면 아무것도 표시하지 않음
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
