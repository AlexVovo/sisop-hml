import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/auth_pages/resetpass/widgetresetpass.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class Resetpass extends StatelessWidget {
  const Resetpass({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Para fechar o teclado ao tocar fora de um campo de texto
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 30,
              ),
              SizedBox(width: 8),
              Text(
                'Redefinir senha',
              ),
            ],
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Conteúdo principal
              _buildMainContent(context),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Widgetresetpass(),
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
