import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogin = false;

  Map<String, dynamic>? facebookData;

  _facebookLogin() async {
    final LoginResult loginResult =
        await FacebookAuth.instance.login(permissions: [
      'email',
      'public_profile',
    ]);
    if (loginResult.status == LoginStatus.success) {
      FacebookAuth.instance.getUserData().then((fbData) {
        setState(() {
          facebookData = fbData;
        });
        sendDataToFirebase(loginResult);
      });
    }
  }

  sendDataToFirebase(LoginResult loginResult) async {
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    var credential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    /// Perform other actions.....
  }

  _facebookLogout() async {
    FacebookAuth.instance.logOut().then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("logout")));
      setState(() {
        facebookData = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _facebookLogin();
                },
                child: const Center(child:  Text("Login with facebook")),
              ),
              facebookData != null
                  ? Image.network(
                      facebookData?["picture"]["data"]["url"],
                      height: 100,
                      width: 100,
                    )
                  : const SizedBox(
                      height: 24,
                      width: 24,
                      child: Icon(Icons.image_not_supported),
                    ),
              Text(facebookData?["name"] ?? ""),
              TextButton(
                onPressed: () {
                  _facebookLogout();
                },
                child: const Center(child: const Text("Logout")),
              )
            ]),
      ),
    );
  }
}
