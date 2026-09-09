import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/dashboardPage/DashboardpageWidget.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard de completude dos dados RHC ICI'),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 500.0 : 20.0,
              vertical: Responsive.isDesktop(context) ? 50.0 : 20.0,
            ),
            child: const Center(
              child: Dashboardpagewidget(modoAdministrativo: true),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Confidencial',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
