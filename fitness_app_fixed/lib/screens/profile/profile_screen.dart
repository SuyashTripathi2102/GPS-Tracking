import 'package:flutter/material.dart';
import '../../data/sqlite_helper.dart';
import '../../widgets/avatar_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SQLiteHelper().getUserProfile();
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _updateAvatar(String url) async {
    if (_profile == null) return;
    final updated = Map<String, dynamic>.from(_profile!);
    updated['avatarUrl'] = url;
    await SQLiteHelper().saveUserProfile(updated);
    setState(() {
      _profile = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AvatarPicker(
              currentUrl: _profile!['avatarUrl'],
              onUploadComplete: _updateAvatar,
            ),
            const SizedBox(height: 20),
            Text(
              _profile!['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _profile!['email'] ?? 'No Email',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-profile',
                ).then((_) => _loadProfile());
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
