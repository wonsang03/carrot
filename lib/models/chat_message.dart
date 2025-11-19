// lib/models/chat_message.dart

// 메시지 데이터의 구조를 정의하는 모델 클래스
class ChatMessage {
  final String Message_Text; // 메시지 내용
  final bool Message_User;      // 내가 보낸 메시지인지 여부

  ChatMessage({
    required this.Message_Text,
    required this.Message_User
  });

  // 서버에서 받은 JSON 데이터를 ChatMessage 객체로 변환하는 로직
  // 서버 응답의 필드명('Message_Text', 'Message_User')과 일치해야 합니다.
  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    //[디버깅용] DB에서 수신받는 값 확인
    //print(' [ChatMessage.fromJson] 수신된 데이터: $json');
    return ChatMessage(
      Message_Text: json['Message_Text'] ?? '내용 없음',
      Message_User: json['Message_User'] == currentUserId, // 메시지 발신자 ID와 현재 내 ID를 비교
    );
  }
}
