import 'package:flutter/material.dart';
import 'package:regsitroweb/model/patient_model.dart';
import 'package:regsitroweb/pagesapp/detailPage/detail_page.dart';
import 'package:regsitroweb/pagesapp/updatepage/updatepacient.dart';

class widgetPatientListPage extends StatelessWidget {
  final Patient patient;
  final String? token;

  const widgetPatientListPage(
      {super.key, required this.patient, required this.token});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: patient.needsReview
          ? const Color.fromARGB(255, 252, 196, 196).withValues(alpha: 0.7)
          : const Color.fromARGB(255, 248, 244, 252),
      child: Column(
        children: [
          ListTile(
            leading: patient.needsReview
                ? const Icon(Icons.warning_rounded,
                    color: Color.fromARGB(255, 211, 16, 3), size: 40)
                : null,
            title: Text(patient.nomepac),
            subtitle:
                Text('Data de atualização: ${patient.dataatualizacaocad}'),
            trailing: patient.needsReview
                ? const Text(
                    'Revisão necessária',
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          OverflowBar(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientDetailsPage(patient: patient),
                    ),
                  );
                },
                child: const Text('Informações do paciente'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdatePatientPage(patient: patient, token: token),
                    ),
                  );
                },
                child: const Text('Atualizar informações'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
