import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/authentication/email_auth/sign_up_screen.dart';
import 'package:note_app/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void logIn() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email == "" || password == "") {
      log("Please provide all the details");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        log("logged in");

        //if logged in then go to homescreen
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
      } on FirebaseAuthException catch (e) {
        log(e.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Please log in"),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    hintText: "email here",
                    hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                    hintText: "password here",
                    hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                logIn();
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text(
                "Let's go",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8,),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SignUpScreen();
              },));
            }, child: const Text("You are new? Create an account"))
          ],
        ));
  }
}
