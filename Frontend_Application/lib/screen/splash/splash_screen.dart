import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // 로그인 상태를 확인하는 함수
    bool isLoggedIn = await _checkLoginStatus();

    Timer(const Duration(seconds: 2), () {
      if (isLoggedIn) {
        // 로그인 상태면 홈 화면으로 이동
        context.go('/home');
      } else {
        // 로그인 상태가 아니면 로그인 화면으로 이동
        context.go('/home');
      }
    });
  }

  Future<bool> _checkLoginStatus() async {
    // 로그인 상태 확인 로직 구현, 예시로는 항상 false를 반환
    return false; // 이 부분을 실제 로그인 상태 확인 로직으로 대체필요
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303742),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nostalgianavi_logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nostalgianavi',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}