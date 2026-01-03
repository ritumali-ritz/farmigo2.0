import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppConstants {
  static const String appName = 'Farmigo 2.0';
  static const String developedBy = 'Developed by Ritex Studios';

  // Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Deep Green
  static const Color accentColor = Color(0xFF81C784);  // Light Green
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color subTextColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF1FDF1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Categories
  static const List<String> categories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Grains',
    'Poultry',
    'Other'
  ];

  // Order Statuses
  static const List<String> orderStatuses = [
    'Pending',
    'Accepted',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  // WhatsApp Utility
  static Future<void> launchWhatsApp({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    try {
      final rawPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (rawPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid phone number')),
        );
        return;
      }

      final formattedPhone = rawPhone.length == 10 ? '91$rawPhone' : rawPhone;
      final encodedMsg = Uri.encodeComponent(message);
      
      // Schemes to try
      final schemes = [
        'whatsapp://send?phone=$formattedPhone&text=$encodedMsg',
        'https://wa.me/$formattedPhone?text=$encodedMsg',
      ];

      bool launched = false;
      for (final scheme in schemes) {
        final uri = Uri.parse(scheme);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      }

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Please ensure it is installed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
