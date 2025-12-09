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
    final Color myBubbleColor = dapaGreen[500]!; // 초록색
    final Color opponentBubbleColor = Colors.white; // 상대방 메시지는 흰색
    final Color myTextColor = Colors.white; // 내 메시지 글자색 (흰색)
    final Color opponentTextColor = Colors.black87; // 상대방 메시지 글자색

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatRoom.opponentName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(dapaGreen[500]!),
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              '대화를 시작해보세요!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        reverse: false,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isCurrentUser = msg.Message_User;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: isCurrentUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isCurrentUser) ...[
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? myBubbleColor
                                          : opponentBubbleColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isCurrentUser ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isCurrentUser ? 4 : 16,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      msg.Message_Text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isCurrentUser
                                            ? myTextColor
                                            : opponentTextColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // 메시지 입력창
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            hintText: '메시지를 입력하세요...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _isSendingMessage ? null : (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _isSendingMessage
                            ? Colors.grey[400]
                            : dapaGreen[500],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isSendingMessage
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isSendingMessage ? null : _sendMessage,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}