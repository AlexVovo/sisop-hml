import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/dashboardPage/DashboardpageWidget.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class PublicDashboardPage extends StatelessWidget {
  const PublicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = snapshot.data?.email == 'projetobioinfo@ici.ong';
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 100.0 : 20.0,
              vertical: Responsive.isDesktop(context) ? 50.0 : 20.0,
            ),
            child: Center(
              child: Dashboardpagewidget(modoAdministrativo: isAdmin),
            ),
          );
        },
      ),
    );
  }
}
