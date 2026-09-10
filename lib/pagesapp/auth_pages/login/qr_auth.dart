import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/selectHospital/selectpage.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class QrPage extends StatefulWidget {
  final String email;
  const QrPage({super.key, required this.email});

  @override
  State<QrPage> createState() => _QrPage();
}

class _QrPage extends State<QrPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: 'TOTP removido');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive.isDesktop(context)
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(
                right: 550.0,
                left: 550.0,
                top: 200.0,
                bottom: 100.0,
              ),
              child: _buildQrContent(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: _buildQrContent(),
            ),
    );
  }

  Widget _buildQrContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      
       Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        "Seja bem-vindo ao Registro de câncer infantojuvenil!",
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        textAlign: TextAlign.center,
      ),
    ),
     const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        "Observação: Para acessar o aplicativo de registro, é necessário que o horário do computador esteja sincronizado com o seu celular. Ambos os dispositivos devem estar configurados com o mesmo horário.",
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Text(
        "O fluxo de verificação TOTP foi removido. Acesso direto ao registro liberado.",
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    const SizedBox(height: 20),
    ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HospitalSelectionPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      child: const Text(
        'Continuar',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    ),
  ],
)

      ],
    );
  }

}
