// lib/models/chat_room.dart
import 'package:flutter/foundation.dart';

/// 💬 서버에서 받아오는 채팅방 정보를 담는 클래스입니다.
class ChatRoom {
  final String Chat_Number;         // 채팅방 고유 번호
  final String Chat_Owner;          // 상품 판매자 이름
  final String Chat_LastMessage;     // 마지막 메시지
  final String Chat_Time;            // 마지막 메시지 시간
  final int Chat_UnreadCount;        // 읽지 않은 메시지 수
  final String Chat_AvatarUrl;       // 상대방 프로필 이미지 URL

  ChatRoom({
    required this.Chat_Number,
    required this.Chat_Owner,
    required this.Chat_LastMessage,
    required this.Chat_Time,
    required this.Chat_UnreadCount,
    required this.Chat_AvatarUrl,
  });

  /// 서버에서 받은 JSON 데이터를 ChatRoom 객체로 변환
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      // [수정] String 타입인 Chat_Number에 int(0)가 들어가는 버그를 수정합니다.
      //chat_nuber을 선언할때 int값으로 바꿔버리는 방법
      Chat_Number: json['Chat_Number']?.toString() ?? '',
      //name -> chat_Owner로 교체
      Chat_Owner: json['Chat_Owner'] ?? '',
      Chat_LastMessage: json['Chat_LastMessage'] ?? '', // 마지막 채팅
      //time -> chat_Time으로 교체
      Chat_Time: json['Chat_Time'] ?? '',
      Chat_UnreadCount: json['Chat_UnreadCount'] ?? 0, // 읽지 않은 메시지 수
      Chat_AvatarUrl: json['Chat_AvatarUrl'] ?? '', // 프로필 이미지 URL
    );
  }

  /// ChatRoom 객체를 JSON으로 변환 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'Chat_Number': Chat_Number,
      'Chat_Owner': Chat_Owner,
      'Chat_LastMessage': Chat_LastMessage,
      'Chat_Time': Chat_Time,
      'Chat_UnreadCount': Chat_UnreadCount,
      'Chat_AvatarUrl': Chat_AvatarUrl,
    };
  }
}
