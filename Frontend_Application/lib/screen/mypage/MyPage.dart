import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';
import 'package:Nostalgianavi/screen/common/Profile_Manage_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    return Scaffold(
      appBar: AppBarBasic(
        title: 'Nostalgianavi',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImageUrl = userData['profileImageUrl'] as String?;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<String>(
                  future: profileImageUrl != null
                      ? FirebaseStorage.instance.ref(profileImageUrl).getDownloadURL()
                      : Future.value(''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/user_profile.png'),
                      );
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/user_profile.png'),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  userData['displayName'] as String? ?? '',
                  style: const TextStyle(
                    fontFamily: 'GmarketSansTTFBold',
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text(
                    '프로필 관리',
                    style: TextStyle(
                      fontFamily: 'GmarketSansTTFMedium',
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileManageScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    '설정',
                    style: TextStyle(
                      fontFamily: 'GmarketSansTTFMedium',
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    // 설정 페이지로 이동
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text(
                    '도움말 & 지원',
                    style: TextStyle(
                      fontFamily: 'GmarketSansTTFMedium',
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    // 도움말 & 지원 페이지로 이동
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}