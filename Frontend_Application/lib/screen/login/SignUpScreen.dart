import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Field Controller 설정
  TextEditingController emailTextController = TextEditingController(); // 이메일 입력 컨트롤러
  TextEditingController pwdTextController = TextEditingController(); // 비밀번호 입력 컨트롤러

  // 회원가입 함수
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      // FirebaseAuth를 사용하여 이메일과 비밀번호로 회원가입을 시도
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 회원가입 성공 시 사용자 정보를 Firestore의 `users` 컬렉션에 저장
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
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      // 그 외 예외 처리
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 키보드 팝업 시 스크롤 가능하도록 설정
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              children: [
                const Text(
                  "기억의 지도\n가입을 환영합니다😀",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 42,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "이메일",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "이메일 주소를 입력해주세요.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: pwdTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "비밀번호",
                        ),
                        obscureText: true, // 비밀번호 입력 시 *로 표시되도록 설정
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "비밀번호를 입력해주세요.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final email = emailTextController.text;
                      final pwd = pwdTextController.text;

                      final result = await signUp(email, pwd);

                      if (result == null) {
                        // 회원가입 실패 시 에러 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("회원가입 실패"),
                          ),
                        );
                        return;
                      }

                      // 회원가입 성공 시 로그인 화면으로 이동
                      if (context.mounted) {
                        context.go("/login");
                      }
                    }
                  },
                  height: 48,
                  minWidth: double.infinity,
                  color: Colors.red,
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}