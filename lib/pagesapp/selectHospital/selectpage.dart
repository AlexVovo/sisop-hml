import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:regsitroweb/pagesapp/homePage/home.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class HospitalSelectionPage extends StatefulWidget {
  const HospitalSelectionPage({super.key});

  @override
  State<HospitalSelectionPage> createState() => _HospitalSelectionPageState();
}

class _HospitalSelectionPageState extends State<HospitalSelectionPage> {
  String? _selectedHospital;
  List<String> _hospitais = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) return;

    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot =
          await users.where('email', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        List<dynamic> hospitaisSelecionados =
            userData['hospitaisSelecionados'] ?? [];

        setState(() {
          _hospitais = hospitaisSelecionados.cast<String>();
        });
      }
    } catch (e) {
      print('Erro ao buscar hospitais: $e');
    }
  }

  void _confirmHospitalSelection() {
    if (_selectedHospital == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar hospital"),
          content: Text(
            "Você selecionou o hospital $_selectedHospital. Deseja confirmar?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo sem ação
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo

                try {
                  // 👇 AQUI É O PONTO PRINCIPAL:
                  // Salva no Firestore qual é o hospital ativo do usuário
                  await HospitalServicer()
                      .setActiveHospitalByIdOrName(_selectedHospital!);

                  // Agora navega pra HomePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(hospital: _selectedHospital!),
                    ),
                  );
                } catch (e) {
                  print('Erro ao definir hospital ativo: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Erro ao definir o hospital ativo. Tente novamente.',
                      ),
                    ),
                  );
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _hospitais.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: Responsive.isDesktop(context)
                  ? const EdgeInsets.symmetric(
                      horizontal: 500,
                      vertical: 50) // Ajuste do padding para desktop
                  : const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50), // Ajuste para mobile/tablet
              child: Column(
                children: [
                  const Text(
                    'Selecione o Hospital:',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _hospitais.length,
                      itemBuilder: (context, index) {
                        String hospital = _hospitais[index];
                        return RadioListTile<String>(
                          title: Text(hospital),
                          value: hospital,
                          groupValue: _selectedHospital,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedHospital = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: Responsive.isDesktop(context)
                        ? const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10) // Mais espaçamento para desktop
                        : const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16), // Menos espaçamento para mobile
                    child: ElevatedButton(
                      onPressed: _selectedHospital != null
                          ? () {
                              _confirmHospitalSelection(); // Chama o popup de confirmação
                            }
                          : null,
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
