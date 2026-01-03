import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;

  UserProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _authService.user.listen((user) async {
      print('DEBUG: Auth State Changed. User: ${user?.id}');
      if (user != null) {
        if (_userModel == null) {
          _isLoading = true;
          notifyListeners();
        }
        
        _userModel = await _authService.getUserData(user.id);
        
        if (_userModel == null) {
          print('DEBUG: User model is null after fetch. Profile not found for ${user.id}');
        } else {
          print('DEBUG: User profile loaded successfully for ${user.id}');
          _notificationService.initializeNotification(user.id);
        }
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print('DEBUG: Auth stream error: $err');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('DEBUG: Attempting signIn for $email');
      await _authService.signIn(email, password);
      
      // The listener in _init() will pick up the auth change.
      // We just need to wait a bit to see if _userModel gets populated.
      
      int retries = 0;
      while (_userModel == null && retries < 4) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }
      
      if (_userModel == null) {
        print('DEBUG: Login success but profile fetch failed/timed out.');
        await _authService.signOut();
        throw Exception('Account found but profile details are missing. Please contact support.');
      }
      
      print('DEBUG: signIn process completed successfully');
    } catch (e) {
      print('DEBUG: signIn error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
        role: role,
      );
      // Stream listener in _init() will handle _isLoading = false post-profile fetch.
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> updateProfile(UserModel upatedUser) async {
    await _authService.updateProfile(upatedUser);
    _userModel = upatedUser;
    notifyListeners();
  }
}
