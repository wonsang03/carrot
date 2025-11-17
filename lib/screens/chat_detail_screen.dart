import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart'; // ✨ [추가] 분리된 ChatMessage 모델을 import 합니다.

// 채팅 상세 화면 위젯
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
  bool _isLoadingMessages = true; // 메시지 로딩 상태
  bool _isSendingMessage = false;  // 메시지 전송 중 상태

  @override
  void initState() {
    super.initState();
    _loadMessages(); // 위젯이 생성될 때 메시지 목록을 불러옵니다.
  }

  // 서버에서 메시지 목록을 불러오는 함수
  void _loadMessages() async {
    setState(() { _isLoadingMessages = true; });

    try {
      final messages = await ApiService.fetchMessages(widget.chatRoom.Chat_Number, widget.currentUserId);

      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
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

  // 입력된 메시지를 서버로 전송하는 함수
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // 내용이 없으면 전송하지 않음

    setState(() { _isSendingMessage = true; });

    try {
      await ApiService.sendMessage(
        chatRoomId: widget.chatRoom.Chat_Number,
        senderId: widget.currentUserId,
        message: text,
      );

      // 메시지 전송 성공 시, 화면에 바로 추가하여 사용자 경험을 향상시킵니다.
      setState(() {
        _messages.add(ChatMessage(Message_Text: text, Message_User: true));
      });
      _controller.clear(); // 입력창 비우기

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송에 실패했습니다: $e'))
      );
    } finally {
      setState(() { _isSendingMessage = false; });
    }
  }

  //디자인 부분
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatRoom.Chat_Owner)),
      body: Column(
        children: [
          // 메시지 목록 영역
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('대화를 시작해보세요!'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.Message_User ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.Message_User ? Colors.orange[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.Message_Text),
                  ),
                );
              },
            ),
          ),
          // 메시지 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메시지 입력...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _isSendingMessage ? null : (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
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
