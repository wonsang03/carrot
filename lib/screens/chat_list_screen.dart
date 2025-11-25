// lib/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';
import '../main.dart'; // DapaGreen 상수를 사용하기 위해 import

class ChatListScreen extends StatefulWidget {
  final void Function(ChatRoom, String) onRoomTap;
  const ChatListScreen({Key? key, required this.onRoomTap}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatRoom>> futureChatRooms;

  final String myUserId = '8ac96703-506e-40fe-9ad2-5ba09d9896d5';

  @override
  void initState() {
    super.initState();
    futureChatRooms = ApiService.fetchChatRooms(myUserId);
  }

  void _refreshChatRooms() {
    if(mounted) {
      setState(() {
        futureChatRooms = ApiService.fetchChatRooms(myUserId);
      });
    }
  }

  // 서버에서 받은 시간을 '오후 00:00' 형태로 포맷하는 헬퍼 함수
  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString).toLocal();
      return '${dateTime.hour > 12 ? '오후' : '오전'} ${dateTime.hour % 12}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString.length > 5 ? timeString.substring(11, 16) : timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeGreen = dapaGreen[700]!;
    final double avatarRadius = 37.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대파마켓 채팅', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false, // ✅ 수정 완료: 제목을 왼쪽(시작점)으로 정렬
      ),
      body: FutureBuilder<List<ChatRoom>>(
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

            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, i) {
                final room = chatRooms[i];
                final hasUnread = room.Chat_UnreadCount > 0;
                final formattedTime = _formatTime(room.Chat_Time);

                final leadingWidget = CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: room.Chat_AvatarUrl.isNotEmpty
                      ? NetworkImage(room.Chat_AvatarUrl)
                      : null as ImageProvider<Object>?,
                  child: room.Chat_AvatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey, size: avatarRadius * 0.8)
                      : null,
                );

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: leadingWidget,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 핵심: 왼쪽 정렬
                        children: [
                          Text(
                            room.opponentName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4), // 제목과 부제 사이 간격
                          Text(
                            room.Chat_LastMessage,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      subtitle: null, // 기존 subtitle 제거
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread ? activeGreen : Colors.grey[600],
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hasUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        widget.onRoomTap(room, myUserId);
                        _refreshChatRooms();
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: Colors.grey.shade300,
                      indent: 16 + avatarRadius * 2 + 16,
                      endIndent: 16,
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: Text('채팅방이 없습니다.'));
          }
        },
      ),
    );
  }
}