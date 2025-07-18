import 'package:flutter/material.dart';
import 'theme_screen.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final iconBg = isDark ? Colors.white10 : Colors.grey[100];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(3, (index) {
                  bool isActive = index == 0; // This is step 1
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.new_releases,
                size: 64,
                color: Color(0xFF7A5CF5),
              ),
              const SizedBox(height: 24),
              const Text(
                "What's New in GPS Tracker",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover the latest features and improvements',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconBg,
                        child: Icon(
                          Icons.security,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'New Tracker Account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Helps secure your activity with sync',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconBg,
                        child: Icon(Icons.sync, color: Colors.blue),
                      ),
                      title: Text(
                        'Faster Syncing',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Real-time activity data with your device',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconBg,
                        child: Icon(Icons.analytics, color: Colors.green),
                      ),
                      title: Text(
                        'Enhanced Analytics',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Better insights into your fitness journey',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/theme');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5CF5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
