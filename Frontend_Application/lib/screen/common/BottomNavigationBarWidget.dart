import 'package:Nostalgianavi/screen/album/Album.dart';
import 'package:Nostalgianavi/screen/home/HomeScreen.dart';
import 'package:Nostalgianavi/screen/mypage/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Nostalgianavi/screen/common/ImageUploadPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0; // 현재 선택된 인덱스를 저장할 변수
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // 사용자가 선택한 이미지를 Firebase Storage에 업로드
      String imagePath = 'travelLogs/${DateTime.now().millisecondsSinceEpoch}/image.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(imagePath);
      UploadTask uploadTask = ref.putFile(File(photo.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploadPage(
            imageFile: photo,
            poiDetails: {},
            starRating: 0,
            diaryText: '',
            imagePath: imagePath,
            selectedDate: DateTime.now(),
            downloadUrl: downloadUrl, // 다운로드 URL 전달
          ),
        ),
      );
    }
  }

  Future<void> _uploadFromAlbum(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // 사용자가 선택한 이미지를 Firebase Storage에 업로드
      String imagePath = 'travelLogs/${DateTime.now().millisecondsSinceEpoch}/image.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(imagePath);
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploadPage(
            imageFile: image,
            poiDetails: {},
            starRating: 0,
            diaryText: '',
            imagePath: imagePath,
            selectedDate: DateTime.now(),
            downloadUrl: downloadUrl, // 다운로드 URL 전달
          ),
        ),
      );
    } else {
      print('이미지를 선택하지 않았습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF303742),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_album),
          label: 'Album',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'My Page',
        ),
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()));
            break;
          case 1:
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _takePhoto(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        fixedSize: const Size(160, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Take a Photo',
                        style: TextStyle(
                          fontFamily: 'GmarketSansTTFBold',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _uploadFromAlbum(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        fixedSize: const Size(170, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Upload from Album',
                        style: TextStyle(
                          fontFamily: 'GmarketSansTTFBold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            break;
          case 2:
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Album()));
            break;
          case 3:
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyPage()));
            break;
        }
      },
    );
  }
}