class ChatRoom {
  final String id;
  final String buyerId;
  final String farmerId;
  final String lastMessage;
  final DateTime updatedAt;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.lastMessage,
    required this.updatedAt,
    required this.createdAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'],
      buyerId: map['buyer_id'],
      farmerId: map['farmer_id'],
      lastMessage: map['last_message'] ?? '',
      updatedAt: DateTime.parse(map['updated_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyer_id': buyerId,
      'farmer_id': farmerId,
      'last_message': lastMessage,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      roomId: map['room_id'],
      senderId: map['sender_id'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'message': message,
    };
  }
}
