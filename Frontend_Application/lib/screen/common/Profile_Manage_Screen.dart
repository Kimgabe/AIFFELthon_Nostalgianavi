import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileManageScreen extends StatefulWidget {
  @override
  _ProfileManageScreenState createState() => _ProfileManageScreenState();
}

class _ProfileManageScreenState extends State<ProfileManageScreen> {
  String _userName = '';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId != null) {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          _userName = userData['displayName'] as String? ?? '';
        });
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  Future<void> _saveProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('users/$userId/profileImage.jpg');
        await storageRef.putFile(_profileImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await userRef.update({'profileImageUrl': imageUrl});
      }

      await userRef.update({'displayName': _userName});
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필 관리',
          style: TextStyle(
            fontFamily: 'GmarketSansTTFBold',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/images/user_profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _userName,
              onChanged: _updateUserName,
              decoration: const InputDecoration(
                labelText: '유저명',
                labelStyle: TextStyle(
                  fontFamily: 'GmarketSansTTFMedium',
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'GmarketSansTTFMedium',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontFamily: 'GmarketSansTTFMedium',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}