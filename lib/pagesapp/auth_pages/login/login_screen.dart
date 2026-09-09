import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/auth_pages/resetpass/resetpass.dart';

import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart'
    as size; // Prefixo 'size'
// Certifique-se de que o caminho para a tela TOTP está correto

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Altere para true quando o acesso por Google puder ser liberado novamente.
  static const bool _googleAuthenticationEnabled = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _obscureText = true;
  bool _autenticando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: size.Responsive.isDesktop(
              context) // Use 'utils.Responsive' para o arquivo utils/responsive.dart
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(
                right: 550.0,
                left: 550.0,
                top: 200,
                bottom: 100,
              ),
              child: _buildLoginForm(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: _buildLoginForm(),
            ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _senhaController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Senha',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          obscureText: _obscureText,
          onSubmitted: (_) {
            _loginAndRedirectToTOTP(context);
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Resetpass()),
            );
          },
          child: const Text("Esqueci minha senha"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _autenticando
              ? null
              : () {
                  _loginAndRedirectToTOTP(context);
                },
          child: const Text('Entrar'),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _autenticando || !_googleAuthenticationEnabled
                ? null
                : _entrarComGoogle,
            icon: _autenticando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4),
                    ),
                  ),
            label: const Text('Entrar com Google'),
          ),
        ),
        const SizedBox(height: 30),
        Image.asset('assets/parceiros.png'),
      ],
    );
  }

  Future<void> _entrarComGoogle() async {
    setState(() => _autenticando = true);
    await AuthenticationService(FirebaseAuth.instance)
        .signInWithGoogle(context);
    if (mounted) setState(() => _autenticando = false);
  }

  Future<void> _loginAndRedirectToTOTP(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String senha = _senhaController.text.trim();

    if (email.isNotEmpty && senha.isNotEmpty) {
      setState(() => _autenticando = true);
      final authService = AuthenticationService(FirebaseAuth.instance);
      await authService.signIn(email, senha, context);
      if (mounted) setState(() => _autenticando = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos")),
      );
    }
  }
}
