// lib/screens/chat_detail_screen.dart
// 💬 채팅 상세 화면 위젯
// ApiService.sendMessage 메서드를 호출하도록 수정한 완전한 코드입니다.

import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/global_state.dart';

/// ChatDetailScreen: 선택한 채팅방의 메시지를 보여주고
/// 새 메시지를 전송할 수 있는 화면입니다.
class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom; // 채팅방 정보

  const ChatDetailScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController(); // 입력창 컨트롤러
  List<ChatMessage> _messages = []; // 화면에 표시할 메시지 목록
  bool _isSending = false;        // 메시지 전송 중 여부

  @override
  void initState() {
    super.initState();
    _loadMessages(); // 화면이 열릴 때 더미 메시지 목록 불러오기
  }

  /// 더미 메시지 로드 함수 (실제 앱에서는 서버에서 받아와야 함)
  void _loadMessages() {
    setState(() {
      _messages = [
        ChatMessage(text: "안녕하세요!", isMe: false, timestamp: DateTime.now().subtract(Duration(minutes: 5))),
        ChatMessage(text: "네, 안녕하세요!", isMe: true, timestamp: DateTime.now().subtract(Duration(minutes: 4))),
        ChatMessage(text: "상품 아직 있나요?", isMe: false, timestamp: DateTime.now().subtract(Duration(minutes: 3))),
        ChatMessage(text: "네, 있습니다.", isMe: true, timestamp: DateTime.now().subtract(Duration(minutes: 2))),
      ];
    });
  }

  /// 메시지 전송 함수
  Future<void> _sendMessage() async {
    final text = _controller.text.trim(); // 입력값 앞뒤 공백 제거
    if (text.isEmpty) return;             // 입력이 없으면 무시

    setState(() { _isSending = true; });  // 전송 중 표시

    try {
      // ApiService.sendMessage 호출
      final success = await ApiService.sendMessage(
        chatNumber: widget.chatRoom.Chat_Number,  // 채팅방 번호 (String)
        senderId: GlobalState.User_Number,        // 전송자 ID (개발용으로 1)
        content: text,                            // 메시지 내용
      );

      if (success) {
        // 전송 성공: 내 메시지를 목록에 추가
        setState(() {
          _messages.add(ChatMessage(
            text: text,
            isMe: true,
            timestamp: DateTime.now(),
          ));
        });
        _controller.clear(); // 입력창 비우기
      } else {
        // 전송 실패: 스낵바로 오류 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송에 실패했습니다')),
        );
      }
    } catch (e) {
      // 예외 발생 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 오류: $e')),
      );
    } finally {
      setState(() { _isSending = false; }); // 전송 완료 표시
    }

    // 실제 앱에서는 서버에서 최신 메시지 목록을 다시 받아와야 합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.name), // 상단에 채팅방 이름 표시
      ),
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
                    child: Text(msg.text),
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
                // 입력창
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '메시지 입력'),
                    onSubmitted: (_) => _sendMessage(), // 엔터로도 전송 가능
                  ),
                ),
                // 전송 버튼 또는 로딩 인디케이터
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage, // 전송 중엔 버튼 비활성화
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
