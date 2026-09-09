// import 'package:animated_snack_bar/animated_snack_bar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:regsitroweb/pagesapp/adminPage/adminPage.dart';

// class LogServicer {
//   // Obtém o email do usuário autenticado
//   String? email = FirebaseAuth.instance.currentUser?.email;

//   Future<void> salvarHospital(
//     BuildContext context, {
//     required String id_hospital,
//     required String nome_paciente,
//   }) async {
//     try {
//       // Verifica se o hospital já está cadastrado
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('loga')
//           .doc(id_hospital)
//           .get();

//       if (doc.exists) {
//         // Se o hospital já está cadastrado, exibe uma mensagem de erro
//         AnimatedSnackBar.material(
//           'Hospital já cadastrado!',
//           type: AnimatedSnackBarType.warning,
//           mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//           desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//         ).show(context);
//       } else {
//         // Se não existe, salva o novo hospital
//         var record = {
//           'id_hospital': id_hospital,
//           'nome_hospital': nome_hospital,
//           'token_hospital': token_hospital,
//           'user_email': email,
//         };

//         await FirebaseFirestore.instance
//             .collection('hospitais')
//             .doc(id_hospital)
//             .set(record);

//         // Exibe mensagem de sucesso
//         AnimatedSnackBar.material(
//           'Hospital cadastrado com sucesso no Firebase!',
//           type: AnimatedSnackBarType.success,
//           mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//           desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//         ).show(context);

//         // Redireciona para a página de administração
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Adminpage()),
//         ); // Garante que a rota exista
//       }
//     } catch (error) {
//       // Tratamento de erro
//       AnimatedSnackBar.material(
//         'Erro ao cadastrar hospital: $error',
//         type: AnimatedSnackBarType.error,
//         mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//         desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//       ).show(context);
//       print('Erro ao salvar no Firestore: $error');
//     }
//   }


//   Future<void> deletarLog(BuildContext context, {required String idlog}) async {
//     try {
//       // Verifica se o hospital existe antes de tentar excluir
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('hospitais')
//           .doc(id_hospital)
//           .get();

//       if (doc.exists) {
//         // Exclui o hospital
//         await FirebaseFirestore.instance
//             .collection('hospitais')
//             .doc(id_hospital)
//             .delete();

//         // Exibe mensagem de sucesso
//         AnimatedSnackBar.material(
//           'Hospital excluído com sucesso!',
//           type: AnimatedSnackBarType.success,
//           mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//           desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//         ).show(context);
//       } else {
//         // Caso o hospital não seja encontrado
//         AnimatedSnackBar.material(
//           'Hospital não encontrado!',
//           type: AnimatedSnackBarType.error,
//           mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//           desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//         ).show(context);
//       }
//     } catch (error) {
//       // Tratamento de erro
//       AnimatedSnackBar.material(
//         'Erro ao excluir hospital: $error',
//         type: AnimatedSnackBarType.error,
//         mobileSnackBarPosition: MobileSnackBarPosition.bottom,
//         desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
//       ).show(context);
//       print('Erro ao excluir hospital no Firestore: $error');
//     }
//   }

// }
