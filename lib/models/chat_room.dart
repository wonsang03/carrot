// lib/models/chat_room.dart

/// 💬 서버에서 받아오는 채팅방 정보를 담는 클래스입니다.
class ChatRoom {
  final int Chat_Number;         // 채팅방 고유 번호
  final String name;            // 상대방 이름 또는 채팅방 이름//이 친구는 뭐지
  final String lastMessage;     // 마지막 메시지
  final String time;            // 마지막 메시지 시간
  final int unreadCount;        // 읽지 않은 메시지 수
  final String avatarUrl;       // 상대방 프로필 이미지 URL

  ChatRoom({
    required this.Chat_Number,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });

  /// 서버에서 받은 JSON 데이터를 ChatRoom 객체로 변환
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      Chat_Number: json['Chat_Number'] ?? 0,
      name: json['name'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      time: json['time'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  /// ChatRoom 객체를 JSON으로 변환 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'Chat_Number': Chat_Number,
      'name': name,
      'lastMessage': lastMessage,
      'time': time,
      'unreadCount': unreadCount,
      'avatarUrl': avatarUrl,
    };
  }
}
