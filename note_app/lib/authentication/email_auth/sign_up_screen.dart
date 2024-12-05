import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/authentication/email_auth/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordreController = TextEditingController();

  void createAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String passwordre = passwordreController.text.trim();

    if(email == "" || password == "" || passwordre == "") {
      log("Please fill all details");
    } else if(password != passwordre) {
      log("passwords do not match");
    } else {
      //create the account here
      try{
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        log("user created");

        if(userCredential.user != null) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch(ex) {
        log(ex.code.toString());
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register here"), centerTitle: true, backgroundColor: Colors.deepPurple,),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "enter email", hintStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(hintText: "enter password", hintStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                controller: passwordreController,
                decoration: const InputDecoration(hintText: "confirm password", hintStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(onPressed: () {
              createAccount();
            }, child: const Text("Sign  up", style: TextStyle(color: Colors.white)), style:
            ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent)),
            const SizedBox(height: 8,),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const LoginScreen();
              },));
            }, child: const Text("Already registered? Log in here"))
          ],
        ),
      ),
    );
  }
}
