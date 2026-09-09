import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/qr_auth.dart';
import 'package:regsitroweb/pagesapp/selectHospital/selectpage.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

class TotpScreen extends StatefulWidget {
  final String secret;

  const TotpScreen({super.key, required this.secret});

  @override
  State<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends State<TotpScreen> {
  void _verifyTOTP(BuildContext context) async {
    final code = _controllers.map((controller) => controller.text).join();
    final now = DateTime.now();
    timezone.initializeTimeZones();
    final pacificTimeZone = timezone.getLocation('America/Sao_Paulo');
    final date = timezone.TZDateTime.from(now, pacificTimeZone);

    if (code.length != 6) {
      AnimatedSnackBar.material(
        'Por favor, insira o código completo',
        type: AnimatedSnackBarType.warning,
      ).show(context);
      return;
    }

    bool isCodeValid = OTP.generateTOTPCodeString(
            widget.secret, date.millisecondsSinceEpoch,
            algorithm: Algorithm.SHA1, isGoogle: true) ==
        code;

    if (isCodeValid) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isVerified', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HospitalSelectionPage()),
      );
    } else {
      AnimatedSnackBar.material(
        'Código incorreto',
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }

  String timeMessage = "Verificando horário...";

  Future<void> _checkTime() async {
    DateTime? serverTime;

    try {
      // Primeira tentativa: Usar NTP (Google)
      serverTime = await NTP.now();
      print("Usando NTP: $serverTime");
    } catch (e) {
      print("Erro ao obter horário via NTP: $e");
    }

    // Se NTP falhar, tenta API HTTP (WorldTimeAPI)
    if (serverTime == null) {
      try {
        final response = await http.get(Uri.parse(
            "http://worldtimeapi.org/api/timezone/America/Sao_Paulo"));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          serverTime = DateTime.parse(data['datetime']);
          print("Usando WorldTimeAPI: $serverTime");
        } else {
          print("Erro na WorldTimeAPI, código: ${response.statusCode}");
        }
      } catch (e) {
        print("Erro ao obter horário via WorldTimeAPI: $e");
      }
    }

    // Se ambas falharem, tenta TimeZoneDB
    if (serverTime == null) {
      try {
        final response = await http.get(Uri.parse(
            "http://api.timezonedb.com/v2.1/get-time-zone?key=OSUB7NH4IJU5&format=json&by=zone&zone=America/Sao_Paulo"));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          serverTime = DateTime.parse(data['formatted']);
          print("Usando TimeZoneDB: $serverTime");
        } else {
          print("Erro no TimeZoneDB, código: ${response.statusCode}");
        }
      } catch (e) {
        print("Erro ao obter horário via TimeZoneDB: $e");
      }
    }

    // Se todas as opções falharem, exibe erro
    if (serverTime == null) {
      setState(() {
        timeMessage = "Erro ao verificar o horário. Nenhuma fonte disponível.";
      });
      return;
    }

    // Comparação com a hora local
    DateTime localTime = DateTime.now();
    int differenceInSeconds = serverTime.difference(localTime).inSeconds;

    setState(() {
      if (differenceInSeconds.abs() <= 5) {
        timeMessage = "Horário correto.";
      } else {
        timeMessage =
            "Horário incorreto. Ajuste o relógio do seu dispositivo e atualize a pagina(F5).";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkTime();
  }

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: Responsive.isDesktop(context)
            ? const EdgeInsets.only(
                right: 500.0,
                left: 500.0,
                top: 100,
                bottom: 100,
              )
            : const EdgeInsets.only(
                bottom: 50, right: 15.0, left: 15.0, top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "Insira o código TOTP gerado no Google Authenticator",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (timeMessage ==
                'Horário incorreto. Ajuste o relógio do seu dispositivo e atualize a pagina(F5).')
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "Observação: Para acessar o aplicativo de registro, é necessário que o horário do computador esteja sincronizado com o horário de Brasília.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (timeMessage ==
                'Horário incorreto. Ajuste o relógio do seu dispositivo e atualize a pagina(F5).')
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Status do horário: $timeMessage",
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSubmitted: (_) {
                      _verifyTOTP(context);
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _verifyTOTP(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Verificar",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    AuthenticationService(FirebaseAuth.instance)
                        .signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                for (var controller in _controllers) {
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text(
                "Limpar Código",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                String? email =
                    AuthenticationService(FirebaseAuth.instance).getName();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrPage(email: email!),
                  ),
                );
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "Não conseguiu acessar o aplicativo? Clique aqui!",
                  style: TextStyle(
                    color: Colors.blue, // Azul para parecer um link
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
