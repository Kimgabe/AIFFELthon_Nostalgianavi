import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';
import 'package:Nostalgianavi/screen/common/ImageUploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Album extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  Album({Key? key, this.arguments}) : super(key: key);

  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  List<Map<String, dynamic>> travelRecords = [];
  bool isLoading = false;

  void updateRecordsWithArguments(Map<String, dynamic> args) {
    int index = travelRecords.indexWhere((record) => record['travelId'] == args['travelId']);

    Map<String, dynamic> newRecord = {
      'travelId': args['travelId'],
      'imageUrl': args['imagePath'] ?? args['imageFile']?.path ?? '',
      'title': args['poiDetails']['title'] ?? 'New Travel',
      'date': DateFormat('yyyy-MM-dd').format(args['selectedDate']),
      'diaryText': args['diaryText'],
      'starRating': args['starRating'],
    };

    setState(() {
      if (index != -1) {
        travelRecords[index] = newRecord;
      } else {
        travelRecords.add(newRecord);
      }
      travelRecords.sort((a, b) => b['date'].compareTo(a['date']));
    });

    // Firestore에 여행 기록 업데이트
    FirebaseFirestore.instance
        .collection('travelLogs')
        .doc(args['travelId'])
        .set(newRecord);
  }

  @override
  void initState() {
    super.initState();
    fetchTravelRecords();
  }

  Future<void> fetchTravelRecords() async {
    setState(() {
      isLoading = true;
    });

    // Firestore에서 현재 사용자의 모든 여행 기록을 가져옴
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('travelLogs')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<Map<String, dynamic>> records = [];
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String imageUrl = await FirebaseStorage.instance
          .ref(data['imagePath'])
          .getDownloadURL();

      records.add({
        'travelId': doc.id,
        'title': data['title'] ?? '',
        'imageUrl': imageUrl,
        'date': DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate()),
        'diaryText': data['diaryText'] ?? '',
        'starRating': data['starRating'] ?? 0,
      });
    }

    setState(() {
      travelRecords = records;
      travelRecords.sort((a, b) => b['date'].compareTo(a['date']));
      isLoading = false;
    });
  }

  void _onContainerTapped(String travelId, String imageUrl, DateTime date) async {
    // Firestore에서 선택한 여행 기록의 상세 정보를 가져옴
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('travelLogs')
        .doc(travelId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> poiDetails = snapshot.data() as Map<String, dynamic>;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploadPage(
            poiDetails: poiDetails,
            imageFile: null,
            starRating: poiDetails['starRating'],
            diaryText: poiDetails['diaryText'],
            imagePath: imageUrl,
            selectedDate: date,
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        updateRecordsWithArguments(result);
      }
    }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: ((travelRecords.length + 1) / 2).ceil(),
        itemBuilder: (context, rowIndex) {
          return Row(
            children: List.generate(2, (colIndex) {
              final index = rowIndex * 2 + colIndex;
              if (index < travelRecords.length) {
                final record = travelRecords[index];
                final date = record['date'] != null && record['date'].isNotEmpty
                    ? DateFormat('yyyy-MM-dd').parse(record['date'])
                    : DateTime.now();
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onContainerTapped(record['travelId'], record['imageUrl'], date),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(record['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record['title'],
                                  style: const TextStyle(
                                    fontFamily: 'GmarketSansTTFBold',
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record['date'],
                                  style: const TextStyle(
                                    fontFamily: 'GmarketSansTTFMedium',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Expanded(child: SizedBox());
              }
            }),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}