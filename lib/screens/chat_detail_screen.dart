import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';

// 메시지 모델 클래스 (간단 예시)
class ChatMessage {
  final String content; // 메시지 내용
  final bool isMe;      // 내가 보낸 메시지인지 여부
  ChatMessage({required this.content, required this.isMe});
}

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom; // 채팅방 정보
  const ChatDetailScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController(); // 입력창 컨트롤러
  List<ChatMessage> _messages = []; // 화면에 표시할 메시지 목록
  bool _isLoading = false; // 메시지 전송 중 여부

  @override
  void initState() {
    super.initState();
    _loadMessages(); // 화면이 열릴 때 메시지 목록 불러오기
  }

  // (실제 앱에서는 서버에서 메시지 목록을 받아와야 함)
  void _loadMessages() {
    // 예시용 더미 데이터 (실제로는 서버에서 받아와야 함)
    setState(() {
      _messages = [
        ChatMessage(content: "안녕하세요!", isMe: false),
        ChatMessage(content: "네, 안녕하세요!", isMe: true),
        ChatMessage(content: "상품 아직 있나요?", isMe: false),
        ChatMessage(content: "네, 있습니다.", isMe: true),
      ];
    });
  }

  // 메시지 전송 함수
  void _sendMessage() async {
    final text = _controller.text.trim(); // 입력값 앞뒤 공백 제거
    if (text.isEmpty) return; // 입력이 없으면 무시
    setState(() { _isLoading = true; });
    await ApiService.sendMessage(
      chatRoomId: widget.chatRoom.Chat_Number, // 채팅방 번호
      senderId: 1, // 실제 로그인 유저 id 사용
      message: text,
    );
    setState(() {
      _messages.add(ChatMessage(content: text, isMe: true)); // 내 메시지 추가
      _isLoading = false;
    });
    _controller.clear(); // 입력창 비우기
    // 실제 앱에서는 서버에서 최신 메시지 목록을 다시 받아와야 함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatRoom.name)), // 상단에 채팅방 이름 표시
      body: Column(
        children: [
          // 메시지 목록 영역
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // 내가 보낸 메시지는 오른쪽, 상대방 메시지는 왼쪽에 표시
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
          // 메시지 입력창 + 전송 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '메시지 입력'),
                    onSubmitted: (_) => _sendMessage(), // 엔터로도 전송 가능
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage, // 전송 중엔 버튼 비활성화
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
