import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/alterarSenha/alterarsenha.dart';
import 'package:regsitroweb/pagesapp/homePage/widgetHome.dart';
import 'package:regsitroweb/service/tools/auth/authCheck.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.hospital});
  final String hospital;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Para fechar o teclado ao tocar fora de um campo de texto
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: PopupMenuButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: const Text('alterar o hospital'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthCheck()),
                        );
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Alterar Senha'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Alterarsenha()),
                        );
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sair'),
                      onTap: () {
                        AuthenticationService(FirebaseAuth.instance)
                            .signOut(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Conteúdo principal
              _buildMainContent(context),

              // Texto "Confidencial" no canto superior esquerdo
              _buildConfidentialLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 20,
          child: SingleChildScrollView(
            padding: Responsive.isDesktop(context)
                ? const EdgeInsets.only(right: 400, left: 400, top: 50)
                : const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHome(
                  hospital: hospital,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Positioned _buildConfidentialLabel() {
    return Positioned(
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
    );
  }
}
