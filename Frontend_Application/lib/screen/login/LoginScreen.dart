// 필요한 패키지들을 불러오기
import 'package:Nostalgianavi/screen/login/provider/login_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

// StatefulWidget을 상속받아 로그인 화면을 구성 상태 변화가 가능한 위젯
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// _LoginScreenState 클래스는 로그인 화면의 상태를 관리
class _LoginScreenState extends State<LoginScreen> {
  // 폼의 상태를 관리하기 위한 GlobalKey를 선언
  final _formKey = GlobalKey<FormState>();

  // 이메일과 비밀번호 입력을 위한 TextEditingController 객체를 생성
  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  // 이메일과 비밀번호를 사용하여 Firebase에 로그인하는 함수
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      // FirebaseAuth를 사용하여 이메일과 비밀번호로 로그인을 시도
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // 로그인 성공 시 사용자 정보를 Firestore의 `users` 컬렉션에 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': email,
        // 추가적인 사용자 정보를 저장할 수 있습니다.
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException 발생 시 에러 코드에 따라 다른 처리
      if (e.code == "user-not-found") {
        print(e.toString());
      } else if (e.code == "wrong-password") {
        print(e.toString());
      }
    } catch (e) {
      // 그 외 예외 처리
      print(e.toString());
    }
    return null;
  }

  // Google 계정을 사용하여 로그인하는 함수
  Future<UserCredential?> signInWithGoogle() async {
    // GoogleSignIn을 사용하여 Google 계정으로 로그인을 시도
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    // Google 로그인 인증 정보를 사용하여 Firebase 인증 정보를 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // 생성된 Firebase 인증 정보로 Firebase에 로그인
    final userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    // 로그인 성공 시 사용자 정보를 Firestore의 `users` 컬렉션에 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': userCredential.user!.email,
      // 추가적인 사용자 정보를 저장할 수 있습니다.
    });

    return userCredential;
  }

  // 로그인 화면 UI를 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 화면을 가리지 않도록 조정
      body: SafeArea(
        child: SingleChildScrollView(
          // 스크롤 가능하게 만듬
          child: Padding(
            padding: const EdgeInsets.all(24.0), // 내부 여백을 설정
            child: Column(
              // 세로로 위젯들을 나열
              mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
              children: [
                // 로고 이미지를 표시
                Image.asset(
                  "assets/images/nostalgianavi_logo.png",
                  width: 200,
                  height: 200,
                ),
                const Text(
                  "Nostalgianavi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                    fontFamily: 'Caveat', // 영문 폰트 적용
                    // 화면 타이틀을 표시
                  ),
                ),
                // 여백을 추가
                const SizedBox(
                  height: 10,
                ),
                // 입력 폼을 생성 이메일과 비밀번호 입력 필드가 포함
                Form(
                  key: _formKey, // 폼의 상태를 관리하기 위한 key를 설정
                  child: Column(
                    children: [
                      // 이메일 입력 필드
                      TextFormField(
                        controller: emailTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "이메일",
                          labelStyle: TextStyle(
                            fontFamily: 'GmarketSansTTFMedium', // 한글 폰트 적용
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "이메일 주소를 입력하세요.";
                          }
                          return null; // 에러가 없을 경우 null 반환
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      // 비밀번호 입력 필드
                      TextFormField(
                        controller: pwdTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "비밀번호",
                          labelStyle: TextStyle(
                            fontFamily: 'GmarketSansTTFMedium', // 한글 폰트 적용
                          ),
                        ),
                        obscureText: true,
                        // 비밀번호 가리기
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "비밀번호를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // 로그인 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Consumer(builder: (context, ref, child) {
                    return MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          final result = await signIn(
                              emailTextController.text.trim(),
                              pwdTextController.text.trim());

                          if (result == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("로그인 실패"),
                                ),
                              );
                            }
                            return;
                          }

                          // 로그인 성공 시 상태를 업데이트
                          ref
                              .watch(userCredentialProvider.notifier)
                              .state = result;

                          // 로그인 성공 후 HomeScreen으로 이동
                          if (context.mounted) {
                            context.go("/home");
                          }
                        }
                      },
                      height: 48,
                      minWidth: double.infinity,
                      color: Colors.red,
                      child: const Text(
                        "로그인",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'GmarketSansTTFBold', // 영문 폰트 적용
                        ),
                      ),
                    );
                  }),
                ),
                // 회원가입 페이지로 이동하는 버튼
                TextButton(
                  onPressed: () => context.push("/sign_up"),
                  child: const Text("계정이 없나요? 회원가입",
                      style: TextStyle(
                          fontFamily: 'GmarketSansTTFMedium')), // 한글 폰트 적용
                ),
                const Divider(),
                // 구글 로그인 버튼
                InkWell(
                  onTap: () async {
                    final userCredit = await signInWithGoogle();

                    if (userCredit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("구글 로그인 실패"),
                      ));
                      return;
                    }
                    if (context.mounted) {
                      context.go("/home");
                    }
                  },
                  child:
                  Image.asset("assets/images/btn_google_signin_light.png"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}