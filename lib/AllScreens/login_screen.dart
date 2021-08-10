import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber/AllScreens/main_screen.dart';
import 'package:uber/AllScreens/register_screen.dart';
import 'package:uber/AllWidgets/progress_dialog.dart';
import 'package:uber/main.dart';
import 'package:uber/utils/util.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 65),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1),
              Text(
                "Login as a Rider",
                style: TextStyle(fontSize: 24, fontFamily: "Brand-Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 1),
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 1),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: Util.getBorderRadius(24),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.yellow),
                      ),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displayToastMessage("이메일 형식을 확인해주세요");
                        }
                        if (passwordTextEditingController.text.length < 7) {
                          displayToastMessage("비밀번호를 6자 이상 입력해주세요");
                        } else {
                          loginAndAuthenticateUser(context);
                        }
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Brand-Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.idScreen);
                },
                child: Text("Do not Have an Account? Register Here"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  loginAndAuthenticateUser(BuildContext context) async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return ProgressDialog(message: "로그인 진행중");
    });
    final UserCredential firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(
            email: emailTextEditingController.text,
            password: passwordTextEditingController.text)
        .catchError((errMsg) {
          Navigator.pop(context);//다이얼로그 실행 상태에서 pop호출하면 dialog dismiss
      displayToastMessage("Error : $errMsg");
    }));

    if (firebaseUser.user != null) {
      usersRef.child(firebaseUser.user!.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("로그인에 성공했습니다");
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("no Record");
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage("에러 발생");
    }
  }
}
