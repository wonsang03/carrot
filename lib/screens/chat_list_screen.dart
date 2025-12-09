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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('채팅', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshChatRooms,
            tooltip: '새로고침',
          )
        ],
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: futureChatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(dapaGreen[500]!),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final chatRooms = snapshot.data!;
            if (chatRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '참여 중인 채팅방이 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _refreshChatRooms();
                await futureChatRooms;
              },
              color: dapaGreen[500],
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chatRooms.length,
                itemBuilder: (context, i) {
                  final room = chatRooms[i];
                  final hasUnread = room.Chat_UnreadCount > 0;
                  final formattedTime = _formatTime(room.Chat_Time);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          widget.onRoomTap(room, myUserId);
                          _refreshChatRooms();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // 프로필 이미지
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: room.Chat_AvatarUrl.isNotEmpty
                                        ? NetworkImage(room.Chat_AvatarUrl)
                                        : null,
                                    child: room.Chat_AvatarUrl.isEmpty
                                        ? Icon(Icons.person, color: Colors.grey[600], size: 28)
                                        : null,
                                  ),
                                  if (hasUnread)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // 채팅 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room.opponentName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: hasUnread ? Colors.black87 : Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room.Chat_LastMessage,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (hasUnread) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              room.Chat_UnreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('채팅방이 없습니다.'));
          }
        },
      ),
    );
  }
}
