import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/adminpagewidget.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({super.key});

  @override
  State<Adminpage> createState() => _AdminpageState();
}

class _AdminpageState extends State<Adminpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin Page',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              AuthenticationService(FirebaseAuth.instance).signOut(context);
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Sair'),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isDesktop(context) ? 500.0 : 20.0,
            vertical: 70.0,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Adminpagewidget(),
            ],
          ),
        ),
      ),
    );
  }
}
