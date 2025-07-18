import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'whats_new_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app_fixed/db/profile_db_helper.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'app.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS user_profile(uid TEXT PRIMARY KEY, gender TEXT, theme TEXT, onboarded INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS user_profile(uid TEXT PRIMARY KEY, gender TEXT, theme TEXT, onboarded INTEGER)',
        );
      },
    );
  }

  void goNext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (selectedGender != null && user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gender_${user.uid}', selectedGender!);
      // Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'gender': selectedGender!,
      }, SetOptions(merge: true));
      // SQLite (onboarding DB)
      final db = await getDatabase();
      await db.insert('user_profile', {
        'uid': user.uid,
        'gender': selectedGender!,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      // Also update main profile DB for profile screen
      try {
        await ProfileDBHelper().updateGender(user.uid, selectedGender!);
        print(
          'GenderScreen: Updated main profile DB with gender ${selectedGender!} for user ${user.uid}',
        );
      } catch (e) {
        print('GenderScreen: Failed to update main profile DB: $e');
      }
      print(
        'GenderScreen: Saved gender ${selectedGender!} for user ${user.uid}',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WhatsNewScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress indicator row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(3, (index) {
                    bool isActive = index == 0; // This is step 0
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
                  Icons.person_outline,
                  size: 64,
                  color: Color(0xFF7A5CF5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select your gender',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gender determines how your body burns calories',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGenderCard(
                      context: context,
                      gender: 'male',
                      icon: Icons.male,
                      label: 'Male',
                      selected: selectedGender == 'male',
                      onTap: () => setState(() => selectedGender = 'male'),
                    ),
                    const SizedBox(width: 24),
                    _buildGenderCard(
                      context: context,
                      gender: 'female',
                      icon: Icons.female,
                      label: 'Female',
                      selected: selectedGender == 'female',
                      onTap: () => setState(() => selectedGender = 'female'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedGender != null ? goNext : null,
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
      ),
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required String gender,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
              width: selected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
