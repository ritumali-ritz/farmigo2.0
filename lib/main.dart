import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/theme.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Replace with your Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://rnquphlufdbcavpgmdph.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJucXVwaGx1ZmRiY2F2cGdtZHBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcxNzAzNzIsImV4cCI6MjA4Mjc0NjM3Mn0.GAZyelU_DI943t9l6TUYDTc0BlUxaSB6UazcPI1yUGI',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const FarmigoApp(),
    ),
  );
}

class FarmigoApp extends StatelessWidget {
  const FarmigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmigo 2.0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainWrapper(),
    );
  }
}
