import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Nostalgianavi/screen/common/AppBarBasic.dart';
import 'package:Nostalgianavi/screen/common/BottomNavigationBarWidget.dart';

class TouristSpotDetailScreen extends StatelessWidget {
  final String spotName;
  final String imageUrl;
  final String overview;
  final String address;
  final String contact;
  final String homepageUrl;
  final String parkingInfo;
  final String operatingHours;
  final String closedDays;

  const TouristSpotDetailScreen({
    super.key,
    required this.spotName,
    required this.imageUrl,
    required this.overview,
    required this.address,
    required this.contact,
    required this.homepageUrl,
    required this.parkingInfo,
    required this.operatingHours,
    required this.closedDays,
  });

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
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: FirebaseStorage.instance
                        .ref('touristSpots/$spotName/image.jpg')
                        .getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading image'),
                        );
                      }
                      final imageUrl = snapshot.data!;
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(imageUrl),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spotName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GmarketSansTTFBold',
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('touristSpots')
                              .doc(spotName)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Error loading tourist spot details'),
                              );
                            }
                            final touristSpotData = snapshot.data!.data() as Map<String, dynamic>;
                            final overview = touristSpotData['overview'] as String;
                            return Text(
                              overview,
                              style: const TextStyle(
                                fontFamily: 'GmarketSansTTFMedium',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '기본 정보',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GmarketSansTTFBold',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('touristSpots')
                            .doc(spotName)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading tourist spot details'),
                            );
                          }
                          final touristSpotData = snapshot.data!.data() as Map<String, dynamic>;
                          final address = touristSpotData['address'] as String;
                          final contact = touristSpotData['contact'] as String;
                          final homepageUrl = touristSpotData['homepageUrl'] as String;
                          final parkingInfo = touristSpotData['parkingInfo'] as String;
                          final operatingHours = touristSpotData['operatingHours'] as String;
                          final closedDays = touristSpotData['closedDays'] as String;
                          return Column(
                            children: [
                              _buildInfoRow(Icons.location_on, '주소', address),
                              const Divider(),
                              _buildInfoRow(Icons.phone, '연락처', contact),
                              const Divider(),
                              _buildInfoRow(Icons.language, '홈페이지', homepageUrl),
                              const Divider(),
                              _buildInfoRow(Icons.local_parking, '주차시설', parkingInfo),
                              const Divider(),
                              _buildInfoRow(Icons.schedule, '이용/영업 시간', operatingHours),
                              const Divider(),
                              _buildInfoRow(Icons.hotel, '쉬는날', closedDays),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'GmarketSansTTFBold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  info,
                  style: const TextStyle(
                    fontFamily: 'GmarketSansTTFMedium',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}