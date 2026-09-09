import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/login_screen.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';

class Widgetresetpass extends StatefulWidget {
  const Widgetresetpass({super.key});

  @override
  _WidgetresetpassState createState() => _WidgetresetpassState();
}

class _WidgetresetpassState extends State<Widgetresetpass> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite seu e-mail para redefinir sua senha.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu e-mail';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final authService =
                    AuthenticationService(FirebaseAuth.instance);
                await authService.resetPassword(_emailController.text, context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Enviar Link de Redefinição'),
            ),
          ],
        ),
      ),
    );
  }
}
