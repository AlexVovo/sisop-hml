import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/adminPage.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/login_screen.dart';
import 'package:regsitroweb/service/user_servicer.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<IdTokenResult>(
              future: user!.getIdTokenResult(true),
              builder: (context, tokenSnapshot) {
                if (tokenSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tokenSnapshot.data?.claims?['admin'] == true) {
                  return const Adminpage();
                }

                UserServicer().handleRedirection(context, user);
                return const SizedBox();
              },
            );
          } else {
            return const LoginScreen(); // Redireciona para a tela de login
          }
        },
      ),
    );
  }
}
