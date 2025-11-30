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

  // ✨ [개선] 시간 포맷 헬퍼 함수
  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '';

    try {
      // 1. DateTime으로 파싱 시도
      final dateTime = DateTime.parse(timeString).toLocal();
      final now = DateTime.now();

      // 2. 오늘 날짜와 비교
      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        // 오늘이면: "오후 3:30"
        final hour = dateTime.hour;
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? '오후' : '오전';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$period $displayHour:$minute';
      } else {
        // 오늘이 아니면: "11월 25일"
        return '${dateTime.month}월 ${dateTime.day}일';
      }
    } catch (e) {
      // 파싱 실패 시 원본 문자열에서 시간 부분만 추출 시도 (예: "2023-11-25 14:30:00")
      if (timeString.length >= 16) {
        return timeString.substring(11, 16); // "14:30" 부분 추출
      }
      return timeString; // 정 안되면 원본 그대로 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeGreen = dapaGreen[700]!;
    final double avatarRadius = 37.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대파마켓 채팅', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // [디버깅용] 새로고침 버튼 추가
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshChatRooms,
          )
        ],
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
                // 안 읽은 메시지 확인 (0보다 크면 true)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room.opponentName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 시간 표시 (우측 상단)
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
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
                      // Trailing에 안 읽은 메시지 카운트 배지 표시
                      trailing: hasUnread 
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Text(
                                room.Chat_UnreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(), // 없으면 빈 공간
                      
                      onTap: () async {
                        widget.onRoomTap(room, myUserId);
                        // 갔다 오면 목록 새로고침
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
