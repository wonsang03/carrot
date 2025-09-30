import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';

// 메시지 데이터의 구조를 정의하는 모델 클래스
class ChatMessage {
  final String content; // 메시지 내용
  final bool isMe;      // 내가 보낸 메시지인지 여부

  ChatMessage({required this.content, required this.isMe});

  // 서버에서 받은 JSON 데이터를 ChatMessage 객체로 변환하는 로직
  // 서버 응답의 필드명('Message_Text', 'Message_User')과 일치해야 합니다.
  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatMessage(
      content: json['Message_Text'] ?? '내용 없음',
      isMe: json['Message_User'] == currentUserId, // 메시지 발신자 ID와 현재 내 ID를 비교
    );
  }
}

// 채팅 상세 화면 위젯
class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  // ✨ [추가] 외부(ChatListScreen)에서 현재 사용자 ID를 전달받기 위한 변수
  final String currentUserId;

  // ✨ [수정] 생성자에서 chatRoom 정보와 함께 currentUserId를 필수로 받도록 수정
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
      // ✨ 생성자를 통해 전달받은 widget.currentUserId를 사용합니다.
      final messages = await ApiService.fetchMessages(widget.chatRoom.Chat_Number, widget.currentUserId);

      // 비동기 작업 후 위젯이 여전히 화면에 있는지 확인하고 상태를 업데이트합니다.
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
      // ✨ 생성자를 통해 전달받은 widget.currentUserId를 발신자 ID로 사용합니다.
      await ApiService.sendMessage(
        chatRoomId: widget.chatRoom.Chat_Number,
        senderId: widget.currentUserId,
        message: text,
      );

      // 메시지 전송 성공 시, 화면에 바로 추가하여 사용자 경험을 향상시킵니다.
      setState(() {
        _messages.add(ChatMessage(content: text, isMe: true));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatRoom.name)),
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
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.orange[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.content),
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

