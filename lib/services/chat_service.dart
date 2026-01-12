import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all chat rooms for the current user with details
  Stream<List<Map<String, dynamic>>> getChatRooms(String userId) {
    // Note: PostgrestStream doesn't support complex .or syntax directly.
    // We stream all relevant updates and filter in the app or use a simpler filter.
    return _supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => data.where((room) => 
            room['buyer_id'] == userId || room['farmer_id'] == userId
        ).toList());
  }

  // Fetch user name by ID
  Future<String> getUserName(String userId) async {
    final data = await _supabase
        .from('users')
        .select('name')
        .eq('uid', userId)
        .maybeSingle();
    return data?['name'] ?? 'User';
  }

  // Get or create a chat room between a buyer and a farmer
  Future<ChatRoom> getOrCreateRoom(String buyerId, String farmerId) async {
    final existing = await _supabase
        .from('chat_rooms')
        .select()
        .eq('buyer_id', buyerId)
        .eq('farmer_id', farmerId)
        .maybeSingle();

    if (existing != null) {
      return ChatRoom.fromMap(existing);
    }

    final data = await _supabase.from('chat_rooms').insert({
      'buyer_id': buyerId,
      'farmer_id': farmerId,
    }).select().single();

    return ChatRoom.fromMap(data);
  }

  // Get messages for a specific room
  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) => data.map((map) => ChatMessage.fromMap(map)).toList());
  }

  // Send a message
  Future<void> sendMessage(String roomId, String senderId, String message) async {
    await _supabase.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': senderId,
      'message': message,
    });

    // Update last message in the room
    await _supabase.from('chat_rooms').update({
      'last_message': message,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', roomId);
  }
}
