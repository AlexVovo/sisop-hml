import 'package:flutter/material.dart';
import 'package:regsitroweb/service/user_servicer.dart';

class WidgetAlterarSenha extends StatefulWidget {
  const WidgetAlterarSenha({super.key});

  @override
  _WidgetAlterarSenhaState createState() => _WidgetAlterarSenhaState();
}

class _WidgetAlterarSenhaState extends State<WidgetAlterarSenha> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Senha Atual'),
          TextFormField(
            controller: _senhaAtualController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Senha Atual',
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
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('Nova Senha'),
          TextFormField(
            controller: _senhaController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Nova Senha',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite sua nova senha';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Confirmar Senha'),
          TextFormField(
            controller: _confirmarSenhaController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Confirmar Senha',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme sua senha';
              }
              if (value != _senhaController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                UserServicer().atualizarSenha(
                    _senhaController.text, _senhaAtualController.text, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 69, 78, 128), // Cor de fundo laranja pastel
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(3.0), // Bordas arredondadas
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Ajuste do tamanho do botão
              ),
              child: const Text(
                '🔒 Atualizar Senha',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
