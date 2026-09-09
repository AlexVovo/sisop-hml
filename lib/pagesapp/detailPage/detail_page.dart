import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/detailPage/widgetdetailpage.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/tools/size/sizescreen.dart';
import '../../model/patient_model.dart';

class PatientDetailsPage extends StatelessWidget {
  final Patient patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    print(patient.toString());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Informações do paciente',
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 20,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 350, vertical: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [widgetPatientDetailsPage(patient: patient)],
                  ),
                ),
              ),
            if (!Responsive.isDesktop(context))
              Expanded(
                flex: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.screenHeight,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [widgetPatientDetailsPage(patient: patient)],
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
