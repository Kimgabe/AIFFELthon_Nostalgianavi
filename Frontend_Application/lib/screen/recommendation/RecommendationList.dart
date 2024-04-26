import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';
import 'package:Nostalgianavi/screen/travel_info/TouristSpotDetailScreen.dart';

class RecommendationList extends StatelessWidget {
  const RecommendationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBasic(
        title: 'Nostalgianavi',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recommendedPlaces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recommended places found.'));
          }
          final recommendedPlaces = snapshot.data!.docs;

          return ListView.builder(
            itemCount: (recommendedPlaces.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(2, (colIndex) {
                  final index = rowIndex * 2 + colIndex;
                  if (index < recommendedPlaces.length) {
                    final placeData = recommendedPlaces[index].data() as Map<String, dynamic>;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TouristSpotDetailScreen(
                                spotName: placeData['name'] ?? '',
                                address: placeData['address'] ?? '',
                                imageUrl: placeData['imageUrl'] ?? '',
                                overview: placeData['overview'] ?? '',
                                contact: placeData['contact'] ?? '',
                                homepageUrl: placeData['homepageUrl'] ?? '',
                                parkingInfo: placeData['parkingInfo'] ?? '',
                                operatingHours: placeData['operatingHours'] ?? '',
                                closedDays: placeData['closedDays'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FutureBuilder<String>(
                                future: FirebaseStorage.instance
                                    .ref('recommendedPlaces/${recommendedPlaces[index].id}/image.jpg')
                                    .getDownloadURL(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return const SizedBox(height: 150);
                                  }
                                  final imageUrl = snapshot.data!;
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      placeData['name'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'GmarketSansTTFBold',
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      placeData['recommendationReason'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'GmarketSansTTFMedium',
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
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
                    return const Spacer();
                  }
                }),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}