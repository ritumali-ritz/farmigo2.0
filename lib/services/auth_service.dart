import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<User?> get user => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  Future<UserModel?> getUserData(String uid) async {
    try {
      print('DEBUG: Fetching user data for $uid');
      final data = await _supabase.from('users').select().eq('uid', uid).maybeSingle();
      
      print('DEBUG: Data found: ${data != null}');
      if (data != null) {
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('DEBUG: Error in getUserData: $e');
      return null;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          'role': role,
        },
      );
      
      final User? user = response.user;

      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.id,
          email: email,
          name: name,
          phone: phone,
          address: address,
          role: role,
        );
        
        await _supabase.from('users').upsert(userModel.toMap());
        
        // If farmer, also add to farmers table for easier queries/rules
        if (role == 'farmer') {
          await _supabase.from('farmers').upsert(userModel.toMap());
        }
      }
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.farmigo://reset-password/',
    );
  }

  Future<void> updateProfile(UserModel user) async {
    await _supabase.from('users').update(user.toMap()).eq('uid', user.uid);
    if (user.role == 'farmer') {
      await _supabase.from('farmers').update(user.toMap()).eq('uid', user.uid);
    }
  }
}

