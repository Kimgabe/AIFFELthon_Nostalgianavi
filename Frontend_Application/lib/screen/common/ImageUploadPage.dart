import 'dart:io';

import 'package:Nostalgianavi/screen/album/Album.dart';
import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ImageUploadPage extends StatefulWidget {
  final Map<String, dynamic> poiDetails;
  final XFile? imageFile;
  final int starRating;
  final String? diaryText;
  final String? imagePath;
  final DateTime selectedDate;
  final String? downloadUrl;

  const ImageUploadPage({
    super.key,
    required this.poiDetails,
    this.imageFile,
    required this.starRating,
    required this.diaryText,
    required this.imagePath,
    required this.selectedDate,
    this.downloadUrl,
  });

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final TextEditingController _controller = TextEditingController();
  String _text = '';
  int _starRating = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _starRating = widget.starRating;
    _text = widget.diaryText!;
    _controller.text = widget.diaryText!;
    _isEditing = widget.diaryText!.isEmpty && widget.starRating == 0;
    _selectedDate = widget.selectedDate;
    _isLoading = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange(String value) {
    setState(() {
      _text = value;
    });
  }

  Future<void> _uploadImage() async {
    // 이미지 업로드
    if (widget.imageFile != null) {
      // Firebase Storage에 이미지 업로드
      String imagePath = 'travelLogs/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child(imagePath);
      UploadTask uploadTask = storageReference.putFile(File(widget.imageFile!.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Firestore에 이미지 URL과 여행 기록 정보 저장
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('travelLogs').add({
        'userId': uid,
        'title': widget.poiDetails['title'] ?? '',
        'date': Timestamp.fromDate(_selectedDate),
        'imageUrl': downloadUrl,
        'starRating': _starRating,
        'diaryText': _text,
        'imagePath': imagePath,
      });
    } else if (widget.downloadUrl != null) {
      // 기존 이미지를 사용하는 경우
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('travelLogs').add({
        'userId': uid,
        'title': widget.poiDetails['title'] ?? '',
        'date': Timestamp.fromDate(_selectedDate),
        'imageUrl': widget.downloadUrl!,
        'starRating': _starRating,
        'diaryText': _text,
        'imagePath': widget.imagePath,
      });
    }
  }

  void _submitDiary() async {
    // 일기 저장
    await _uploadImage();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Album(),
        settings: RouteSettings(
          arguments: {
            'imageFile': widget.imageFile,
            'imagePath': widget.imagePath,
            'diaryText': _text,
            'starRating': _starRating,
            'selectedDate': _selectedDate,
            'poiDetails': widget.poiDetails,
            'travelId': '',
          },
        ),
      ),
    );
  }

  void _editDiary() {
    setState(() {
      _isEditing = true;
    });
  }

  void _setStarRating(int rating) {
    if (_isEditing) {
      setState(() {
        _starRating = rating;
      });
    }
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).size.height / 3,
            child: CupertinoDatePicker(
              initialDateTime: _selectedDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
              maximumYear: DateTime.now().year,
              mode: CupertinoDatePickerMode.date,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBasic(
        title: 'Nostalgianavi',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: widget.imageFile != null
                        ? Image.file(File(widget.imageFile!.path), fit: BoxFit.cover)
                        : widget.downloadUrl != null
                        ? Image.network(widget.downloadUrl!, fit: BoxFit.cover)
                        : Container(
                      height: 200,
                      color: Colors.grey,
                      child: Center(
                        child: Text('이미지가 없습니다'),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: Future.delayed(Duration(seconds: 2)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.poiDetails['title'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'GmarketSansTTFBold',
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                widget.poiDetails['description'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'GmarketSansTTFMedium',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: TextStyle(
                        fontFamily: 'GmarketSansTTFMedium',
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Write Diary',
              style: TextStyle(
                fontFamily: 'GmarketSansTTFBold',
                fontSize: 24,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controller,
              onChanged: _handleTextChange,
              decoration: InputDecoration(
                hintText: '여행에 대한 추억을 간단한 일기로 남겨보세요!📝',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'GmarketSansTTFMedium',
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
              enabled: _isEditing,
            ),
            SizedBox(height: 10),
            Text(
              'Choose Star Rating',
              style: TextStyle(
                fontFamily: 'GmarketSansTTFBold',
                fontSize: 24,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => _setStarRating(index + 1),
                  child: Icon(
                    index < _starRating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 40,
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
            Center(
              child: _isEditing
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitDiary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      '저 장',
                      style: TextStyle(
                        fontFamily: 'GmarketSansTTFMedium',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _editDiary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      '수 정',
                      style: TextStyle(
                        fontFamily: 'GmarketSansTTFMedium',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitDiary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      '저 장',
                      style: TextStyle(
                        fontFamily: 'GmarketSansTTFMedium',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}