import 'package:flutter/material.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:validatorless/validatorless.dart'; // Adicionando validatorless

class Hospitalpagewidget extends StatefulWidget {
  const Hospitalpagewidget({super.key});

  @override
  State<Hospitalpagewidget> createState() => _HospitalpagewidgetState();
}

class _HospitalpagewidgetState extends State<Hospitalpagewidget> {
  final TextEditingController _idHospitalController = TextEditingController();
  final TextEditingController _nomeHospitalController = TextEditingController();
  final TextEditingController _tokenHospitalController =
      TextEditingController();

  final _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Cadastro Hospital',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Preto
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de ID do hospital
                TextFormField(
                  controller: _idHospitalController,
                  decoration: const InputDecoration(
                    labelText: 'ID do hospital',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      Validatorless.required('O ID do hospital é obrigatório'),
                ),
                const SizedBox(height: 15),

                // Campo de Nome do hospital
                TextFormField(
                  controller: _nomeHospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do hospital',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validatorless.required(
                      'O nome do hospital é obrigatório'),
                ),
                const SizedBox(height: 15),

                // Campo de Token do hospital
                TextFormField(
                  controller: _tokenHospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Token do hospital',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validatorless.required(
                      'O token do hospital é obrigatório'),
                ),
                const SizedBox(height: 30),

                // Campo de ID do usuário

                ElevatedButton(
                  onPressed: () {
                    if (_formKey2.currentState!.validate()) {
                      _doCadastrarHospital(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _doCadastrarHospital(BuildContext context) {
    HospitalServicer().salvarHospital(context,
        id_hospital: _idHospitalController.text,
        token_hospital: _tokenHospitalController.text,
        nome_hospital: _nomeHospitalController.text);
    // Implementar o serviço para cadastrar hospital
  }
}
