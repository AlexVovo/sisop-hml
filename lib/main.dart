import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:regsitroweb/firebase_options_homologacao.dart';
import 'package:regsitroweb/pagesapp/adminPage/dashboardPage/PublicDashboardPage.dart';
import 'package:regsitroweb/service/tools/auth/authCheck.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: HomologacaoFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue, // Botões em azul
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/dashboard-completude': (context) => const PublicDashboardPage(),
      },
    );
  }
}
