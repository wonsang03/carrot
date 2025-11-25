// lib/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart';
import '../main.dart'; // dapaGreen 상수를 사용하기 위해 import

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final String currentUserId;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoom,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    setState(() { _isLoadingMessages = true; });

    try {
      final messages = await ApiService.fetchMessages(widget.chatRoom.Chat_Number, widget.currentUserId);
      ApiService.markChatAsRead(widget.chatRoom.Chat_Number);

      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      print('=====================================================');
      print('🚨🚨 CHAT ROOM LOAD EXCEPTION 🚨🚨');
      print('Error Details: $e');
      print('=====================================================');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingMessages = false; });
      }
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() { _isSendingMessage = true; });

    try {
      await ApiService.sendMessage(
        chatRoomId: widget.chatRoom.Chat_Number,
        senderId: widget.currentUserId,
        message: text,
      );

      setState(() {
        _messages.add(ChatMessage(Message_Text: text, Message_User: true));
      });
      _controller.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송에 실패했습니다: $e'))
      );
    } finally {
      setState(() { _isSendingMessage = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 테마 색상 정의 (DapaGreen 사용)
    final Color myBubbleColor = dapaGreen[300]!; // 밝은 초록색
    final Color opponentBubbleColor = Colors.white; // 상대방 메시지는 흰색
    final Color myTextColor = Colors.black87; // 내 메시지 글자색
    final Color opponentTextColor = Colors.black87; // 상대방 메시지 글자색


    return Scaffold(
      // AppBar 배경색은 main.dart의 dapaGreen을 따름
      appBar: AppBar(title: Text(widget.chatRoom.opponentName)),
      // 채팅 배경색을 미세하게 조정하여 메시지 버블이 돋보이게 함
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('대화를 시작해보세요!'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // ✅ 전체 리스트 패딩
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isCurrentUser = msg.Message_User;

                return Padding( // ✅ 메시지 버블 간의 수직 간격 확보
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      // ✅ 카카오톡처럼 최대 너비를 제한하여 짧은 메시지가 너무 길어지는 것을 방지
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // ✅ 내부 패딩 증가
                      decoration: BoxDecoration(
                        color: isCurrentUser ? myBubbleColor : opponentBubbleColor, // ✅ 배경색 적용
                        borderRadius: BorderRadius.only( // ✅ 말풍선 모양 경계선 설정
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: Radius.circular(isCurrentUser ? 15 : 4), // 내 메시지는 왼쪽 아래 둥글게
                          bottomRight: Radius.circular(isCurrentUser ? 4 : 15), // 상대 메시지는 오른쪽 아래 둥글게
                        ),
                        // ✅ 그림자 추가 (선택 사항, 카카오톡 느낌을 위해 제거 가능)
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.05),
                        //     blurRadius: 1,
                        //     offset: const Offset(0, 1),
                        //   ),
                        // ],
                      ),
                      child: Text(
                        msg.Message_Text,
                        style: TextStyle(
                          fontSize: 15, // ✅ 폰트 크기 조정
                          color: isCurrentUser ? myTextColor : opponentTextColor, // ✅ 폰트 색상 적용
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 메시지 입력창
          Container( // ✅ 입력창 영역에 경계선과 배경색을 추가하여 분리
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지 입력...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // ✅ 입력창 둥글게
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100], // ✅ 입력창 배경색
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onSubmitted: _isSendingMessage ? null : (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // 전송 버튼은 테마의 primaryColor(초록색)을 따름
                IconButton(
                  icon: _isSendingMessage
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: _isSendingMessage ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}