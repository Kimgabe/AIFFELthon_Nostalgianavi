import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';
import 'package:Nostalgianavi/screen/mypage/MyPage.dart';
import 'package:Nostalgianavi/screen/recommendation/RecommendationList.dart';
import 'package:Nostalgianavi/screen/album/Album.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? latestTravel;
  bool isAlbumLoaded = false;
  Album album = Album();

  @override
  void initState() {
    super.initState();
    print("initState: 초기 정보 로드");
    loadLatestTravelInfo();
    loadRecommendedPlaces();
  }

  void loadLatestTravelInfo() async {
    // 현재 사용자의 UID 가져오기
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    // Firestore에서 현재 사용자의 최근 여행 기록 가져오기
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('travelLogs')
        .where('userId', isEqualTo: currentUserUid)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // 최근 여행 기록이 있는 경우
      Map<String, dynamic> travelData =
      snapshot.docs.first.data() as Map<String, dynamic>;

      // Firebase Storage에서 이미지 다운로드 URL 가져오기
      String imageUrl = await FirebaseStorage.instance
          .ref('travelLogs/${snapshot.docs.first.id}/image.jpg')
          .getDownloadURL();

      setState(() {
        latestTravel = {
          'title': travelData['title'],
          'date': DateFormat('yyyy년 M월').format(travelData['date'].toDate()),
          'imageUrl': imageUrl,
          'starRating': travelData['starRating'],
          'diaryText': travelData['diaryText'],
        };
        isAlbumLoaded = true;
      });
    } else {
      // 최근 여행 기록이 없는 경우
      setState(() {
        isAlbumLoaded = true;
      });
    }
  }

  List<Map<String, dynamic>> recommendedPlaces = [];

  void loadRecommendedPlaces() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('recommendedPlaces')
        .limit(2)
        .get();

    List<Map<String, dynamic>> places = [];

    for (var doc in snapshot.docs) {
      final placeData = doc.data() as Map<String, dynamic>;
      final imageUrl = await FirebaseStorage.instance
          .ref('recommendedPlaces/${doc.id}/image.jpg')
          .getDownloadURL();

      places.add({
        'title': placeData['name'],
        'starRating': placeData['starRating'],
        'preferenceMatch': placeData['preferenceMatch'],
        'imageUrl': imageUrl,
        'isTopRecommendation': placeData['isTopRecommendation'],
      });
    }

    setState(() {
      recommendedPlaces = places;
    });
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyPage()));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RecommendationList()));
        break;
    }
  }

  Widget buildStarRating(int rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(Icons.star, color: Colors.yellow));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.grey));
      }
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBarBasic(
        title: 'Nostalgianavi',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '🖼가장 최근에 다녀온 여행지에요~!😎',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GmarketSansTTFBold',
                    fontSize: 18.0,
                  ),
                ),
              ),
              if (isAlbumLoaded && latestTravel != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${latestTravel!['title']}, ${latestTravel!['date']}',
                    style: const TextStyle(
                      fontFamily: 'GmarketSansTTFBold',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              if (isAlbumLoaded && latestTravel != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          latestTravel!['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/images/user_profile.png'),
                                ),
                                const SizedBox(width: 10.0),
                                const Text(
                                  'Gabe',
                                  style: TextStyle(
                                    fontFamily: 'GmarketSansTTFBold',
                                    fontSize: 18.0,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _onItemTapped(context, 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          '프로필 보기',
                                          style: TextStyle(
                                            fontFamily: 'GmarketSansTTFMedium',
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 10.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            buildStarRating(latestTravel!['starRating']),
                            const SizedBox(height: 8.0),
                            Text(
                              latestTravel!['diaryText'],
                              style: const TextStyle(
                                fontFamily: 'GmarketSansTTFLight',
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (isAlbumLoaded && latestTravel == null)
                const Center(
                  child: Text(
                    '최근 여행 기록이 없습니다.',
                    style: TextStyle(
                      fontFamily: 'GmarketSansTTFMedium',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              const SizedBox(height: 30.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '다음 여행은 여기 어떠세요?!😎',
                        style: TextStyle(
                          fontFamily: 'GmarketSansTTFBold',
                          fontSize: 16.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onItemTapped(context, 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'View More',
                                style: TextStyle(
                                  fontFamily: 'GmarketSansTTFMedium',
                                  fontSize: 14.0,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 12.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: recommendedPlaces.map((place) {
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                    child: Image.network(
                                      place['imageUrl'],
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                    ),
                                  ),
                                  if (place['isTopRecommendation'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Top Recommendation',
                                        style: TextStyle(
                                          fontFamily: 'GmarketSansTTFMedium',
                                          fontSize: 12.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['title'],
                                      style: const TextStyle(
                                        fontFamily: 'GmarketSansTTFBold',
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow, size: 16.0),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          place['starRating'].toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontFamily: 'GmarketSansTTFMedium',
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      '${place['preferenceMatch']}% 일치',
                                      style: const TextStyle(
                                        fontFamily: 'GmarketSansTTFMedium',
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}