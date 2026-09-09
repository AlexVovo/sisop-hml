import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/service/showsnackbar.dart';
import 'package:regsitroweb/service/tools/auth/authCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final FirebaseAuth _auth;

  AuthenticationService(this._auth);

  Future<void> signIn(String email, String password, context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Após o login bem-sucedido, atualize a UI para mostrar a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthCheck()),
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-credential' || e.code == 'unknown') {
        // Trate os erros de autenticação aqui sem redirecionamento
        ShowSnackBar(context,
            'Parece que algo deu errado. Verifique seu e-mail e senha e tente novamente.');
      }
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }

      if (!context.mounted) return true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthCheck()),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return false;
      final mensagem = switch (e.code) {
        'popup-closed-by-user' ||
        'cancelled-popup-request' =>
          'Login com Google cancelado.',
        'popup-blocked' =>
          'O navegador bloqueou a janela do Google. Permita pop-ups e tente novamente.',
        'account-exists-with-different-credential' =>
          'Este e-mail já usa outra forma de login. Entre com e-mail e senha.',
        'network-request-failed' =>
          'Não foi possível conectar ao Google. Verifique sua internet.',
        'operation-not-allowed' =>
          'O login com Google ainda não foi habilitado no Firebase.',
        _ => e.message ?? 'Não foi possível entrar com o Google.',
      };
      ShowSnackBar(context, mensagem);
      return false;
    } catch (_) {
      if (context.mounted) {
        ShowSnackBar(context, 'Não foi possível entrar com o Google.');
      }
      return false;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Limpar SharedPreferences ao fazer logout
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isVerified'); // Limpa a flag de verificação

      await _auth.signOut().then((value) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()),
          (route) => false, // Remove todas as rotas anteriores
        );
      });
    } on FirebaseAuthException catch (e) {
      ShowSnackBar(context, e.message!);
    }
  }

  String? getUid() {
    return _auth.currentUser?.uid;
  }

  String? getName() {
    return _auth.currentUser?.email;
  }

  Future<void> resetPassword(
    String email,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de redefinição enviado!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro ao enviar e-mail. Verifique o e-mail digitado!')),
      );
    }
  }
}
