import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber/AllScreens/login_screen.dart';
import 'package:uber/AllScreens/main_screen.dart';
import 'package:uber/AllWidgets/progress_dialog.dart';
import 'package:uber/main.dart';
import 'package:uber/utils/util.dart';

class RegisterScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
              SizedBox(height: 30),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1),
              Text(
                "Register as a Rider",
                style: TextStyle(fontSize: 24, fontFamily: "Brand-Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 1),
                    TextFormField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                        if (nameTextEditingController.text.length < 3) {
                          displayToastMessage("이름을 3글자 이상 입력해주세요");
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayToastMessage("이메일 형식을 확인해주세요");
                        } else if (phoneTextEditingController.text.isEmpty) {
                          displayToastMessage("전화번호를 입력해주세요");
                        } else if (passwordTextEditingController.text.length <
                            7) {
                          displayToastMessage("비밀번호를 6자 이상 입력해주세요");
                        } else {
                          registerNewUser(context);
                        }
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            "Create Account",
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
                  Navigator.pushNamed(context, LoginScreen.idScreen);
                  print("회원가입 클릭");
                },
                child: Text("Already Have an Account? Login Here"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "회원가입 진행중");
        });

    final UserCredential firebaseUser = (await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailTextEditingController.text,
            password: passwordTextEditingController.text)
        .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error : $errMsg");
    }));

    if (firebaseUser != null && firebaseUser.user != null) {
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      usersRef.child(firebaseUser.user!.uid).set(userDataMap);
      displayToastMessage("회원가입을 축하드립니다");
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage("New user account has not been created");
    }
  }
}

displayToastMessage(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0);
}
