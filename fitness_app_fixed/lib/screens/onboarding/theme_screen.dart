import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS user_profile(uid TEXT PRIMARY KEY, gender TEXT, theme TEXT, onboarded INTEGER)',
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final themeModeString = themeProvider.themeMode == ThemeMode.light
        ? 'light'
        : themeProvider.themeMode == ThemeMode.dark
        ? 'dark'
        : 'system';

    void selectTheme(String? theme) {
      if (theme != null) {
        themeProvider.setTheme(theme);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progress indicator row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(3, (index) {
                    bool isActive = index == 1; // This is step 2
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
                const Icon(Icons.palette, size: 64, color: Color(0xFF7A5CF5)),
                const SizedBox(height: 24),
                const Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select your preferred app appearance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 40),
                // Animated mobile mockup preview
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 200,
                  height: 400,
                  decoration: BoxDecoration(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.black
                        : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(width: 4, color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: List.generate(
                            3,
                            (index) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Theme color selection row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => themeProvider.setTheme('light'),
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color:
                                    themeProvider.themeMode == ThemeMode.light
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Light mode',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () => themeProvider.setTheme('dark'),
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dark Mode',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () => themeProvider.setTheme('system'),
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                              border: Border.all(
                                color:
                                    themeProvider.themeMode == ThemeMode.system
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Follow button',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'theme_${user.uid}',
                          themeProvider.themeMode == ThemeMode.light
                              ? 'light'
                              : themeProvider.themeMode == ThemeMode.dark
                              ? 'dark'
                              : 'system',
                        );
                        await prefs.setBool('onboarded_${user.uid}', true);
                        // Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                              'theme':
                                  themeProvider.themeMode == ThemeMode.light
                                  ? 'light'
                                  : themeProvider.themeMode == ThemeMode.dark
                                  ? 'dark'
                                  : 'system',
                              'onboarded': true,
                            }, SetOptions(merge: true));
                        // SQLite
                        final db = await getDatabase();
                        await db.insert(
                          'user_profile',
                          {
                            'uid': user.uid,
                            'theme': themeProvider.themeMode == ThemeMode.light
                                ? 'light'
                                : themeProvider.themeMode == ThemeMode.dark
                                ? 'dark'
                                : 'system',
                            'onboarded': 1,
                          },
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A5CF5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
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
      ),
    );
  }
}
