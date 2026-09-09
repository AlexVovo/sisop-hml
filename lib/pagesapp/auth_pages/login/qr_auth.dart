import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:otp/otp.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/totp_screen.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/user_servicer.dart';

class QrPage extends StatefulWidget {
  String email;
  QrPage({super.key, required this.email});

  @override
  State<QrPage> createState() => _QrPage();
}

class _QrPage extends State<QrPage> {
  late String secret;
  late TextEditingController _textController;
  String appName = "RegistroICI"; // Nome do seu app

  @override
  void initState() {
    super.initState();
    // Gera uma chave secreta aleatória
    secret = OTP.randomSecret();
    // Inicializa o controlador com o valor da chave secreta
    _textController = TextEditingController(text: secret);
  }

  @override
  void dispose() {
    // Libera o controlador quando o widget for removido
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // URL compatível com o padrão otpauth para ser escaneado
    String otpAuthUrl =
        "otpauth://totp/$appName?secret=$secret&issuer=RegistroICI";

    return Scaffold(
     
      body: Responsive.isDesktop(context)
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(
                right: 550.0,
                left: 550.0,
                top: 200.0,
                bottom: 100.0,
              ),
              child: _buildQrContent(otpAuthUrl),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: _buildQrContent(otpAuthUrl),
            ),
    );
  }

  // Conteúdo do QR code e do botão "Verificar"
  Widget _buildQrContent(String otpAuthUrl) {
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
        "Primeiro, abra seu autenticador preferido. Caso não saiba qual usar, recomendamos o Google Authenticator!",
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    const SizedBox(height: 20),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Text(
        "Escaneie o QR Code abaixo para inserir o código gerado pelo seu autenticador:",
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    const SizedBox(height: 20),
    QrImageView(
      data: otpAuthUrl,
      version: QrVersions.auto,
      size: 200.0,
    ),
    const SizedBox(height: 20),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelText: 'Código Secreto',
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        readOnly: true,
      ),
    ),
    const SizedBox(height: 20),
    ElevatedButton(
      onPressed: () async {
        _salvar();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      child: const Text(
        'Verificar',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    ),
  ],
)

      ],
    );
  }

  void _salvar() {
    UserServicer userServicer = UserServicer();
    userServicer.saveChaveAuthToUser(
        secret, widget.email); // Chama a função para salvar no Firestore
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => TotpScreen(
                secret: secret,
              )),
    );
  }
}
