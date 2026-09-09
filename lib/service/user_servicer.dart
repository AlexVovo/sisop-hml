import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/qr_auth.dart';
import 'package:regsitroweb/pagesapp/auth_pages/login/totp_screen.dart';
import 'package:regsitroweb/pagesapp/selectHospital/selectpage.dart';
import 'package:regsitroweb/service/showsnackbar.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserServicer {
  String? email = AuthenticationService(FirebaseAuth.instance).getName();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> cadastrarUser(
    String email,
    String password,
    BuildContext context,
    String? iduser,
    List<dynamic> hospitaisSelecionados,
  ) async {
    FirebaseApp? userCreationApp;
    try {
      userCreationApp = await Firebase.initializeApp(
        name: 'user-creation-${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final userCreationAuth = FirebaseAuth.instanceFor(app: userCreationApp);
      final credential = await userCreationAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        'uid': uid,
        'id_usuario': iduser,
        'email': email.trim(),
        'hospitaisSelecionados': hospitaisSelecionados,
        // 👇 define hospitalAtivo como o primeiro hospital selecionado, se existir
        'hospitalAtivo':
            hospitaisSelecionados.isNotEmpty ? hospitaisSelecionados.first : '',
        'chaveauth': '',
        'acessos': [],
      });

      AnimatedSnackBar.material(
        'Usuário cadastrado com sucesso!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        AnimatedSnackBar.material(
          'Email já cadastrado',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      } else if (e.code == 'weak-password') {
        AnimatedSnackBar.material(
          'Senha Fraca',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
      return false;
    } finally {
      if (userCreationApp != null) {
        await FirebaseAuth.instanceFor(app: userCreationApp).signOut();
        await userCreationApp.delete();
      }
    }
  }

  Future<void> saveChaveAuthToUser(String secret, String email) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot =
          await users.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'chaveauth': secret});
      } else {}
    } catch (e) {
      print('Erro ao salvar chaveauth: $e');
      rethrow;
    }
  }

  Future<void> registrarAcesso(String email) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        List acessos = userDoc['acessos'] ?? [];

        // Obtém a data do último acesso registrado
        DateTime? ultimaData;
        if (acessos.isNotEmpty) {
          acessos.sort((a, b) =>
              (b['data'] as Timestamp).compareTo(a['data'] as Timestamp));
          ultimaData = (acessos.first['data'] as Timestamp).toDate();
        }

        DateTime hoje = DateTime.now();
        bool mesmoDia = ultimaData != null &&
            ultimaData.year == hoje.year &&
            ultimaData.month == hoje.month &&
            ultimaData.day == hoje.day;

        if (!mesmoDia) {
          // Só registra se ainda não houve um acesso hoje
          await userDoc.reference.update({
            'acessos': FieldValue.arrayUnion([
              {'data': Timestamp.now()}
            ]),
          });
          print('Acesso registrado com sucesso.');
        } else {
          print('Acesso já registrado hoje.');
        }
      } else {
        print('Usuário não encontrado para registrar o acesso.');
      }
    } catch (e) {
      print('Erro ao registrar acesso: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarUltimosAcessos() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> acessos = [];

      for (var doc in usersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List acessosList = data['acessos'] ?? [];

        if (acessosList.isNotEmpty) {
          acessosList.sort((a, b) =>
              (b['data'] as Timestamp).compareTo(a['data'] as Timestamp));
          Timestamp ultimoAcesso = acessosList.first['data'];

          acessos.add({
            'email': data['email'] ?? 'Desconhecido',
            'ultimoAcesso': ultimoAcesso,
          });
        }
      }

      return acessos;
    } catch (e) {
      print('Erro ao buscar acessos: $e');
      return [];
    }
  }

  Future<void> handleRedirection(BuildContext context, User? user) async {
    if (user == null) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isVerified = prefs.getBool('isVerified') ?? false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        await registrarAcesso(user.email!);

        if (isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HospitalSelectionPage()),
          );
        } else if (userDoc['chaveauth'] != null &&
            userDoc['chaveauth'].isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TotpScreen(secret: userDoc['chaveauth'])),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => QrPage(
                      email: user.email!,
                    )),
          );
        }
      } else {
        ShowSnackBar(context, 'Usuário não encontrado no banco de dados');
      }
    } catch (e) {
      print('Erro ao redirecionar: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarTodosUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      rethrow;
    }
  }

  Future<void> deletarUser(String email, BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário deletado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado.')),
        );
      }
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar usuário.')),
      );
    }
  }

  Future<void> atualizarUser(Map<String, dynamic> usuario) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario['uid'])
          .update({
        'email': usuario['email'],
        'chaveauth': usuario['chaveauth'],
        'hospitaisSelecionados': usuario['hospitaisSelecionados'],
        'nome': usuario['nome'] ?? '',
      });

      print('Usuário atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar o usuário: $e');
      rethrow;
    }
  }

  Future<void> atualizarSenha(
      String senha, String senhaAtual, BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Solicitar reautenticação
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: senhaAtual, // Você precisa obter a senha atual do usuário
        );

        await user.reauthenticateWithCredential(credential);

        // Agora podemos atualizar a senha
        await user.updatePassword(senha);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atualizada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar senha: $e')),
      );
    }
  }
}
