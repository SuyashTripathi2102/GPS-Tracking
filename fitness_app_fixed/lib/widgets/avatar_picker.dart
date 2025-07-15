import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AvatarPicker extends StatefulWidget {
  final String? currentUrl;
  final Function(String) onUploadComplete;

  const AvatarPicker({
    super.key,
    this.currentUrl,
    required this.onUploadComplete,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() => _imageFile = File(pickedFile.path));
    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      widget.onUploadComplete(downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Avatar upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _imageFile != null
              ? FileImage(_imageFile!)
              : (widget.currentUrl != null && widget.currentUrl!.isNotEmpty
                    ? NetworkImage(widget.currentUrl!) as ImageProvider
                    : null),
          child:
              _imageFile == null &&
                  (widget.currentUrl == null || widget.currentUrl!.isEmpty)
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickImage,
          icon: _isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload),
          label: const Text('Change Avatar'),
        ),
      ],
    );
  }
}
