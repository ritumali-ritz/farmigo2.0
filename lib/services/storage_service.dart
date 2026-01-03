import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadProductImage(File file, String farmerId) async {
    try {
      String fileName = '${path.basename(file.path)}_${DateTime.now().millisecondsSinceEpoch}';
      // User requested "product images folder" inside "images" bucket.
      // Assuming folder name is 'product_images' or 'product' (User said "product images folder").
      // Let's use 'product_images' for clarity.
      final String pathStr = 'product_images/$farmerId/$fileName';
      
      // Using 'images' bucket
      await _supabase.storage.from('images').upload(pathStr, file);
      
      final String publicUrl = _supabase.storage.from('images').getPublicUrl(pathStr);
      return publicUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      // Using 'images' bucket, 'profiles' folder.
      final String pathStr = 'profiles/$userId';
      
      await _supabase.storage.from('images').upload(
        pathStr, 
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final String publicUrl = _supabase.storage.from('images').getPublicUrl(pathStr);
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      // Bucket is 'images'. Path starts after /images/.
      if (url.contains('/images/')) {
        final List<String> parts = url.split('/images/');
        if (parts.length > 1) {
          String storagePath = parts.last;
          if (storagePath.contains('?')) {
            storagePath = storagePath.split('?').first;
          }
          await _supabase.storage.from('images').remove([storagePath]);
        }
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
