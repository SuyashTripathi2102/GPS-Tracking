import 'package:flutter/material.dart';
import '../../data/sqlite_helper.dart';
import '../../widgets/avatar_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic> _profile = {
    'name': '',
    'email': '',
    'gender': 'Male',
    'theme': 'System',
    'avatarUrl': null,
  };
  final _genders = ['Male', 'Female', 'Other'];
  final _themes = ['Light', 'Dark', 'System'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SQLiteHelper().getUserProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
      });
    }
  }

  Future<void> _saveProfile() async {
    await SQLiteHelper().saveUserProfile(_profile);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _updateAvatar(String url) {
    setState(() {
      _profile['avatarUrl'] = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AvatarPicker(
              currentUrl: _profile['avatarUrl'],
              onUploadComplete: _updateAvatar,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (val) => setState(() => _profile['name'] = val),
              controller: TextEditingController(text: _profile['name']),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Gender:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._genders.map(
              (gender) => RadioListTile<String>(
                title: Text(gender),
                value: gender,
                groupValue: _profile['gender'],
                onChanged: (val) => setState(() => _profile['gender'] = val),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Theme:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _profile['theme'],
              isExpanded: true,
              items: _themes
                  .map(
                    (theme) =>
                        DropdownMenuItem(value: theme, child: Text(theme)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _profile['theme'] = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
