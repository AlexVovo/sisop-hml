import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/hospital/Hospitalpagewidget.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class Hospitalpage extends StatefulWidget {
  const Hospitalpage({super.key});

  @override
  State<Hospitalpage> createState() => _HospitalpageState();
}

class _HospitalpageState extends State<Hospitalpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 20,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isDesktop(context) ? 500.0 : 20.0,
                      vertical: Responsive.isDesktop(context) ? 50.0 : 20.0,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hospitalpagewidget(),
                      ],
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }
}
