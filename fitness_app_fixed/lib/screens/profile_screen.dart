import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../db/profile_db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  int weeklySteps = 45280;
  double progress = 0.75;
  List<String> achievements = [];
  String selectedTheme = 'system'; // 'light' | 'dark' | 'system'
  String gender = 'Not set';
  File? _avatarImage;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFirebaseUser();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileDBHelper().getProfile();
    String loadedGender = 'Not set';
    if (data != null) {
      setState(() {
        // Do NOT set name or email here; always use Firebase user for those
        weeklySteps = data['weeklySteps'] ?? 0;
        achievements = (data['achievements'] as String?)?.split(',') ?? [];
        selectedTheme = data['theme'] ?? 'system';
        loadedGender = data['gender'] ?? 'Not set';
        _avatarPath = data['avatarPath'];
        if (_avatarPath != null && _avatarPath!.isNotEmpty) {
          _avatarImage = File(_avatarPath!);
        }
      });
    }
    print('ProfileScreen: loadedGender from profile DB: $loadedGender');
    if (loadedGender == 'Not set' || loadedGender.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final prefGender = prefs.getString('gender_${user.uid}') ?? '';
        print(
          'ProfileScreen: loadedGender from shared_preferences: $prefGender',
        );
        if (prefGender.isNotEmpty) {
          setState(() {
            gender = prefGender;
          });
          await ProfileDBHelper().updateGender(user.uid, prefGender);
        } else {
          final dbPath = await getDatabasesPath();
          final db = await openDatabase(p.join(dbPath, 'app.db'));
          final result = await db.query(
            'user_profile',
            where: 'uid = ?',
            whereArgs: [user.uid],
          );
          if (result.isNotEmpty && result.first['gender'] != null) {
            final onboardingGender = result.first['gender'] as String;
            print(
              'ProfileScreen: loadedGender from onboarding DB: $onboardingGender',
            );
            setState(() {
              gender = onboardingGender;
            });
            await ProfileDBHelper().updateGender(user.uid, onboardingGender);
          }
        }
      }
    } else {
      setState(() {
        gender = loadedGender;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user != null &&
          loadedGender != 'Not set' &&
          loadedGender.isNotEmpty) {
        await ProfileDBHelper().updateGender(user.uid, loadedGender);
      }
    }
    // Capitalize gender for display
    if (gender.isNotEmpty && gender != 'Not set') {
      setState(() {
        gender = gender[0].toUpperCase() + gender.substring(1);
      });
    }
  }

  String _capitalizeGender(String g) {
    if (g.isEmpty) return g;
    final lower = g.toLowerCase();
    if (lower == 'male' || lower == 'female' || lower == 'other') {
      return lower[0].toUpperCase() + lower.substring(1);
    }
    return g;
  }

  void _loadFirebaseUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? '';
      // Generate name: use displayName if available, else from email (before @, capitalize, remove numbers/special chars)
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        name = user.displayName!;
      } else if (email.isNotEmpty) {
        final base = email.split('@')[0];
        final clean = base.replaceAll(RegExp(r'[^a-zA-Z]'), ' ');
        name = clean
            .split(' ')
            .map(
              (w) => w.isNotEmpty
                  ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                  : '',
            )
            .join(' ')
            .replaceAll(RegExp(r' +'), ' ')
            .trim();
      } else {
        name = 'User';
      }
      setState(() {});
    }
  }

  void _saveProfileToDB() async {
    await ProfileDBHelper().insertOrUpdateProfile(
      name: name,
      email: email,
      weeklySteps: weeklySteps,
      achievements: achievements,
      theme: selectedTheme,
      gender: gender,
      avatarPath: _avatarPath ?? '',
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              setState(() {
                name = nameController.text;
                email = emailController.text;
              });
              _saveProfileToDB();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGenderEditDialog() {
    final genderOptions = ['Male', 'Female', 'Other'];
    if (!genderOptions.contains(gender)) {
      gender = 'Male';
    }
    showDialog(
      context: context,
      builder: (context) {
        String newGender = gender;
        return AlertDialog(
          title: const Text("Select Gender"),
          content: DropdownButton<String>(
            value: newGender,
            isExpanded: true,
            items: genderOptions
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => gender = value);
                Navigator.pop(context);
                _saveProfileToDB();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickAvatar(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickAvatar(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Reset to Initials"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _avatarImage = null;
                _avatarPath = null;
              });
              _saveProfileToDB();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final saved = await File(picked.path).copy(path);
      setState(() {
        _avatarImage = saved;
        _avatarPath = saved.path;
      });
      _saveProfileToDB();
    }
  }

  Widget _buildProfileHeader() {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : "?";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.12),
            Theme.of(context).colorScheme.primary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAvatarPickerDialog,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
              backgroundImage: _avatarImage != null
                  ? FileImage(_avatarImage!)
                  : null,
              child: _avatarImage == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, // always from Firebase
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  email, // always from Firebase
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.transgender,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Gender: $gender",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _editProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySteps() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This Week's Steps",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$weeklySteps",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "~6,468 steps/day",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 45,
              lineWidth: 8.0,
              percent: progress,
              center: Text("${(progress * 100).round()}%"),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        "title": "Step Starter",
        "icon": Icons.directions_walk,
        "color": Colors.blueAccent,
      },
      {
        "title": "7-Day Streak",
        "icon": Icons.local_fire_department,
        "color": Colors.deepOrangeAccent,
      },
      {"title": "CO₂ Saver", "icon": Icons.eco, "color": Colors.green},
      {"title": "Top 10", "icon": Icons.emoji_events, "color": Colors.amber},
      {
        "title": "Power User",
        "icon": Icons.flash_on,
        "color": Colors.purpleAccent,
      },
      {
        "title": "Goal Master",
        "icon": Icons.flag_outlined,
        "color": Colors.pinkAccent,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
        children: achievements.map((a) {
          final Color iconColor = a["color"] as Color;
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(isDark ? 0.18 : 0.15),
                radius: 24,
                child: Icon(a["icon"] as IconData, color: iconColor, size: 28),
              ),
              const SizedBox(height: 6),
              Text(
                a["title"] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    // Assign a unique color for each setting type
    final Map<String, Color> iconColors = {
      'Theme': Colors.deepPurple,
      'Gender': Colors.pinkAccent,
      'Notifications': Colors.orangeAccent,
      'Paired Device': Colors.blueAccent,
      'Change Password': Colors.teal,
      'Support': Colors.green,
      'Log Out': Colors.red,
      'Restart Onboarding': Colors.indigo,
    };
    final Color iconColor =
        iconColors[title] ?? Theme.of(context).colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(isDark ? 0.18 : 0.13),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsTile(
          Icons.color_lens,
          "Theme",
          trailing: DropdownButton<String>(
            value: Provider.of<ThemeProvider>(context).selectedTheme.name,
            items: AppTheme.values.map((theme) {
              return DropdownMenuItem<String>(
                value: theme.name,
                child: Text(
                  theme.name[0].toUpperCase() + theme.name.substring(1),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                final appTheme = AppTheme.values.firstWhere(
                  (e) => e.name == newValue,
                  orElse: () => AppTheme.system,
                );
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).setTheme(appTheme);
                setState(() {
                  selectedTheme = newValue;
                });
                _saveProfileToDB();
              }
            },
          ),
        ),
        _buildSettingsTile(
          Icons.transgender,
          "Gender",
          trailing: Text(
            gender,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: _showGenderEditDialog,
        ),
        _buildSettingsTile(
          Icons.notifications,
          "Notifications",
          trailing: Switch(value: true, onChanged: (v) {}),
        ),
        _buildSettingsTile(
          Icons.devices,
          "Paired Device",
          trailing: const Text("Tracker 01"),
        ),
        _buildSettingsTile(
          Icons.lock_outline,
          "Change Password",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
        _buildSettingsTile(
          Icons.support_agent,
          "Support",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
        _buildSettingsTile(
          Icons.logout,
          "Log Out",
          color: Colors.red,
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            if (shouldLogout == true) {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Logged Out',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text('You have been logged out successfully.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
        ),
        _buildSettingsTile(
          Icons.refresh,
          "Restart Onboarding",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('onboarded_${user.uid}');
              // Optionally clear theme and gender flags too:
              await prefs.remove('theme_${user.uid}');
              await prefs.remove('gender_${user.uid}');
              // Navigate to onboarding without logging out
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/onboarding',
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: ListView(
        children: [
          _buildProfileHeader(),
          _buildWeeklySteps(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Your Achievements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          _buildAchievements(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          _buildSettingsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
