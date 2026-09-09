import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/updatepage/WidgetUpdatepacient.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/tools/size/sizescreen.dart';
import '../../model/patient_model.dart';

class UpdatePatientPage extends StatelessWidget {
  final Patient patient;
  final String? token;

  final GlobalKey<WidgetUpdatePacienteFormState> _updateFormKey =
      GlobalKey<WidgetUpdatePacienteFormState>();

  UpdatePatientPage({super.key, required this.patient, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //testetetsstttetetet
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.update,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Atualizar informações',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-atualizar-paciente',
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.black,
        onPressed: () {
          _updateFormKey.currentState?.triggerAtualizarCadastro();
        },
        icon: const Icon(Icons.update_outlined),
        label: const Text('Atualizar'),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 350, vertical: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetUpdatePacienteForm(
                        key: _updateFormKey,
                        patient: patient,
                        token: token,
                      ),
                    ],
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
                      children: [
                        WidgetUpdatePacienteForm(
                          key: _updateFormKey,
                          patient: patient,
                          token: token,
                        ),
                      ],
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
