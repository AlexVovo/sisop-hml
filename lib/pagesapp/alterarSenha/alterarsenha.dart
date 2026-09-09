import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/alterarSenha/widgetAlterarSenha.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/tools/size/sizescreen.dart';

class Alterarsenha extends StatelessWidget {
  const Alterarsenha({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Alterar Senha',
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 20,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      right: 350.0, left: 350.0, top: 100, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [WidgetAlterarSenha()],
                  ),
                ),
              ),
            if (!Responsive.isDesktop(context))
              Expanded(
                flex: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.screenHeight,
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [WidgetAlterarSenha()],
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
