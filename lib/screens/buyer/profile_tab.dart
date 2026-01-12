import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../common/edit_profile_screen.dart';
import '../common/feedback_screen.dart';

class BuyerProfileTab extends StatelessWidget {
  const BuyerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Center(child: Text('Login to view profile'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('profile')),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
            // Premium Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppConstants.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            user.phone,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Menu Options
            Align(
              alignment: Alignment.centerLeft,
              child: Text(langProvider.translate('language'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: langProvider.currentLocale,
                    onChanged: (val) => langProvider.setLanguage(val!),
                    activeColor: AppConstants.primaryColor,
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('हिंदी (Hindi)'),
                    value: 'hi',
                    groupValue: langProvider.currentLocale,
                    onChanged: (val) => langProvider.setLanguage(val!),
                    activeColor: AppConstants.primaryColor,
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('मराठी (Marathi)'),
                    value: 'mr',
                    groupValue: langProvider.currentLocale,
                    onChanged: (val) => langProvider.setLanguage(val!),
                    activeColor: AppConstants.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(langProvider.translate('dark_mode'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppConstants.primaryColor,
                ),
                title: Text(themeProvider.isDarkMode ? 'Midnight On' : 'Midnight Off'),
                subtitle: const Text('Enhanced premium dark aesthetics'),
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(),
                activeColor: AppConstants.primaryColor,
              ),
            ),

            const SizedBox(height: 30),
            
             _buildMenuTile(context, Icons.location_on_outlined, 'My Address', user.address ?? 'Add Address', onTap: () {}),
             _buildMenuTile(context, Icons.shopping_bag_outlined, langProvider.translate('orders'), 'Check order history', onTap: () {}),
             _buildMenuTile(
               context, 
               Icons.rate_review_outlined, 
               'Feedback & Rating', 
               'Help us improve our service', 
               onTap: () {
                 Navigator.push(
                   context, 
                   MaterialPageRoute(
                     builder: (_) => FeedbackScreen(
                       initialName: user.name, 
                       initialEmail: user.email
                     )
                   )
                 );
               }
             ),
            
            const SizedBox(height: 20),
            
            ListTile(
              onTap: () => userProvider.signOut(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.red.withOpacity(0.1),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(langProvider.translate('logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 40),
              Center(child: Text(AppConstants.developedBy, style: const TextStyle(color: Colors.grey, fontSize: 12))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      ),
    );
  }
}
