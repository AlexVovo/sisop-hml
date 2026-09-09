import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/adminPage.dart';

class HospitalServicer {
  // Cache simples em memória (por sessão)
  static String? _cachedHospitalId; // ex.: "HCPA"
  static String?
      _cachedHospitalNome; // ex.: "Hospital de Clínicas de Porto Alegre"

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // =========================================================
  // ------------------------- CRUD --------------------------
  // =========================================================

  /// Cadastra hospital (docId = id_hospital). Faz checagem de duplicidade.
  Future<void> salvarHospital(
    BuildContext context, {
    required String? id_hospital,
    required String token_hospital,
    required String nome_hospital,
  }) async {
    try {
      if (id_hospital == null || id_hospital.trim().isEmpty) {
        throw Exception('id_hospital inválido.');
      }
      final idTrim = id_hospital.trim();

      final doc = await _db.collection('hospitais').doc(idTrim).get();
      if (doc.exists) {
        AnimatedSnackBar.material(
          'Hospital já cadastrado!',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
        return;
      }

      final email = _auth.currentUser?.email;
      final record = {
        'id_hospital': idTrim,
        'nome_hospital': nome_hospital.trim(),
        'token_hospital': token_hospital.trim(),
        'user_email': email,
        // recomendado para buscas case-insensitive/prefixo
        'nome_hospital_lower': nome_hospital.trim().toLowerCase(),
      };

      await _db.collection('hospitais').doc(idTrim).set(record);

      AnimatedSnackBar.material(
        'Hospital cadastrado com sucesso no Firebase!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Adminpage()),
      );
    } catch (error) {
      AnimatedSnackBar.material(
        'Erro ao cadastrar hospital: $error',
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    }
  }

  /// Lista todos os hospitais.
  Future<List<Map<String, dynamic>>> buscarHospitais() async {
    try {
      final snapshot = await _db.collection('hospitais').get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (error) {
      return [];
    }
  }

  /// Busca um hospital pelo docId (normalmente igual ao id_hospital).
  Future<Map<String, dynamic>?> buscarHospitalPorId(String idHospital) async {
    try {
      final doc =
          await _db.collection('hospitais').doc(idHospital.trim()).get();
      if (doc.exists) return doc.data();

      return null;
    } catch (error) {
      return null;
    }
  }

  /// Edita dados do hospital (por docId).
  Future<void> editarHospital(
    BuildContext context, {
    required String id_hospital,
    required String nome_hospital,
    required String token_hospital,
  }) async {
    try {
      final ref = _db.collection('hospitais').doc(id_hospital.trim());
      final doc = await ref.get();

      if (!doc.exists) {
        AnimatedSnackBar.material(
          'Hospital não encontrado!',
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
        return;
      }

      await ref.update({
        'nome_hospital': nome_hospital.trim(),
        'token_hospital': token_hospital.trim(),
        'nome_hospital_lower': nome_hospital.trim().toLowerCase(),
      });

      AnimatedSnackBar.material(
        'Hospital atualizado com sucesso!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    } catch (error) {
      AnimatedSnackBar.material(
        'Erro ao editar hospital: $error',
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    }
  }

  /// Deleta hospital (por docId).
  Future<void> deletarHospital(
    BuildContext context, {
    required String id_hospital,
  }) async {
    try {
      final ref = _db.collection('hospitais').doc(id_hospital.trim());
      final doc = await ref.get();

      if (!doc.exists) {
        AnimatedSnackBar.material(
          'Hospital não encontrado!',
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
        return;
      }

      await ref.delete();

      AnimatedSnackBar.material(
        'Hospital excluído com sucesso!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    } catch (error) {
      AnimatedSnackBar.material(
        'Erro ao excluir hospital: $error',
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    }
  }

  // =========================================================
  // -------------------- Buscas utilitárias -----------------
  // =========================================================

  /// Busca token tentando: docId -> id_hospital -> nome_hospital (exato).
  Future<String?> buscarTokenSmart(String selecionadoRaw) async {
    final selecionado = selecionadoRaw.trim();
    try {
      final col = _db.collection('hospitais');

      // 1) docId
      final byId = await col.doc(selecionado).get();
      if (byId.exists) {
        final data = byId.data();
        final token = data?['token_hospital'] as String?;
        if (token != null && token.isNotEmpty) return token;
      }

      // 2) id_hospital
      final q1 =
          await col.where('id_hospital', isEqualTo: selecionado).limit(1).get();
      if (q1.docs.isNotEmpty) {
        final token = q1.docs.first.data()['token_hospital'] as String?;
        if (token != null && token.isNotEmpty) return token;
      }

      // 3) nome_hospital
      final q2 = await col
          .where('nome_hospital', isEqualTo: selecionado)
          .limit(1)
          .get();
      if (q2.docs.isNotEmpty) {
        final token = q2.docs.first.data()['token_hospital'] as String?;
        if (token != null && token.isNotEmpty) return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca um token por trecho do ID ou nome, ignorando maiúsculas/minúsculas.
  /// Deve ser usado apenas em telas administrativas autenticadas.
  Future<String?> buscarTokenPorTermo(String termo) async {
    try {
      final termoNormalizado = termo.trim().toLowerCase();
      final snapshot = await _db.collection('hospitais').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final id = (data['id_hospital'] ?? doc.id).toString().toLowerCase();
        final nome = (data['nome_hospital'] ?? '').toString().toLowerCase();
        if (!id.contains(termoNormalizado) &&
            !nome.contains(termoNormalizado)) {
          continue;
        }

        final token = data['token_hospital']?.toString().trim();
        if (token != null && token.isNotEmpty) return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca token diretamente por id_hospital (ou docId).
  Future<String?> buscarTokenPorId(String idHospital) async {
    try {
      final col = _db.collection('hospitais');
      final id = idHospital.trim();

      // 1) docId
      final byId = await col.doc(id).get();
      if (byId.exists) {
        final data = byId.data();
        return data?['token_hospital'] as String?;
      }

      // 2) id_hospital
      final q = await col.where('id_hospital', isEqualTo: id).limit(1).get();
      if (q.docs.isNotEmpty) {
        return q.docs.first.data()['token_hospital'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Retorna o id_hospital a partir do nome (usa também campo lower/prefixo se existir).
  Future<String?> buscarIdHospitalPorNome(String nome) async {
    try {
      final col = _db.collection('hospitais');
      final nomeTrim = nome.trim();

      // 1) Exato
      final q1 =
          await col.where('nome_hospital', isEqualTo: nomeTrim).limit(1).get();
      if (q1.docs.isNotEmpty) {
        final doc = q1.docs.first;
        final data = doc.data();
        return (data['id_hospital'] as String?) ?? doc.id;
      }

      // 2) Case-insensitive (se houver campo)
      final q2 = await col
          .where('nome_hospital_lower', isEqualTo: nomeTrim.toLowerCase())
          .limit(1)
          .get();
      if (q2.docs.isNotEmpty) {
        final doc = q2.docs.first;
        final data = doc.data();
        return (data['id_hospital'] as String?) ?? doc.id;
      }

      // 3) Prefix search (opcional; requer índice)
      try {
        final q3 = await col
            .orderBy('nome_hospital_lower')
            .startAt([nomeTrim.toLowerCase()])
            .endAt(['${nomeTrim.toLowerCase()}\uf8ff'])
            .limit(1)
            .get();
        if (q3.docs.isNotEmpty) {
          final doc = q3.docs.first;
          final data = doc.data();
          return (data['id_hospital'] as String?) ?? doc.id;
        }
      } catch (_) {}

      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // ----------- Usuário com múltiplos hospitais -------------
  // =========================================================

  /// Resolve o doc do usuário mesmo quando o documentId não é o UID.
  /// Ordem: users/{uid} -> where uid==<uid> -> where email==<email>
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDoc() async {
    final uid = _auth.currentUser?.uid;
    final email = _auth.currentUser?.email;
    if (uid == null) {
      throw Exception('Usuário não autenticado.');
    }

    final users = _db.collection('users');

    // 1) users/{uid}
    final byId = await users.doc(uid).get();
    if (byId.exists && byId.data() != null) return byId;

    // 2) where uid == uid
    final qUid = await users.where('uid', isEqualTo: uid).limit(1).get();
    if (qUid.docs.isNotEmpty) return qUid.docs.first;

    // 3) where email == email
    if (email != null) {
      final qEmail =
          await users.where('email', isEqualTo: email).limit(1).get();
      if (qEmail.docs.isNotEmpty) return qEmail.docs.first;
    }

    throw Exception(
        'Documento do usuário não encontrado em users/{uid} nem por uid/email.');
  }

  /// Helper: encontra hospital por docId, id_hospital ou nome_hospital (e opcionalmente *_lower*).
  Future<Map<String, dynamic>?> _findHospitalByAny(String any) async {
    final key = any.trim();
    if (key.isEmpty) return null;

    final col = _db.collection('hospitais');

    // 1) nome_hospital (exato). Usuários registradores chegam aqui pelo nome
    // associado ao seu cadastro; consultar primeiro pelo nome também permite
    // que as regras do Firestore comprovem o vínculo com o hospital.
    final q2 = await col.where('nome_hospital', isEqualTo: key).limit(1).get();
    if (q2.docs.isNotEmpty) {
      final d = q2.docs.first;
      return {...d.data(), '_docId': d.id};
    }

    // 2) docId
    final byId = await col.doc(key).get();
    if (byId.exists) {
      final data = byId.data();
      if (data != null) return {...data, '_docId': byId.id};
    }

    // 3) id_hospital
    final q1 = await col.where('id_hospital', isEqualTo: key).limit(1).get();
    if (q1.docs.isNotEmpty) {
      final d = q1.docs.first;
      return {...d.data(), '_docId': d.id};
    }

    // 4) case-insensitive, se houver o campo
    try {
      final q3 = await col
          .where('nome_hospital_lower', isEqualTo: key.toLowerCase())
          .limit(1)
          .get();
      if (q3.docs.isNotEmpty) {
        final d = q3.docs.first;
        return {...d.data(), '_docId': d.id};
      }
    } catch (_) {}

    return null;
  }

  /// Retorna o **id_hospital** do hospital **ativo** do usuário.
  /// Se `hospitalAtivo` não existir ou for inválido, percorre `hospitaisSelecionados`
  /// e escolhe o primeiro que existir na coleção `hospitais`. Persiste o nome oficial.
  Future<String> getActiveHospitalId() async {
    // 🔴 REMOVEI o cache aqui
    // if (_cachedHospitalId != null) return _cachedHospitalId!;

    final userSnap = await _getUserDoc();
    final data = userSnap.data()!;

    String? hospitalAtivo = (data['hospitalAtivo'] as String?)?.trim();
    final List<String> selecionados =
        ((data['hospitaisSelecionados'] as List?) ?? [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // Lista de candidatos: primeiro o ativo, depois os selecionados
    final List<String> candidatos = {
      if (hospitalAtivo != null && hospitalAtivo.isNotEmpty) hospitalAtivo,
      ...selecionados,
    }.toList();

    Map<String, dynamic>? hospitalData;
    for (final c in candidatos) {
      hospitalData = await _findHospitalByAny(c);

      if (hospitalData != null) break;
    }

    if (hospitalData == null) {
      throw Exception(
        'Nenhum dos hospitais do usuário foi encontrado na coleção "hospitais". '
        'Candidatos: ${candidatos.isEmpty ? '[vazio]' : candidatos.join(", ")}. '
        'Cadastre o hospital correto (ex.: HCPA/ICI) ou ajuste "hospitalAtivo".',
      );
    }

    final idHospital = (hospitalData['id_hospital'] as String?) ??
        (hospitalData['_docId'] as String);
    final nomeHospital = (hospitalData['nome_hospital'] as String?) ?? '';

    // Se o ativo diverge do nome oficial, persiste o oficial
    if (nomeHospital.isNotEmpty && hospitalAtivo != nomeHospital) {
      await userSnap.reference.update({'hospitalAtivo': nomeHospital});
    }

    // Aqui ainda deixo em cache só como "último resolvido",
    // mas NÃO uso mais pra pular a leitura do Firestore
    _cachedHospitalId = idHospital;
    _cachedHospitalNome = nomeHospital;

    return idHospital;
  }

  /// Define o hospital ativo aceitando **id_hospital**, **docId** ou **nome_hospital**.
  Future<void> setActiveHospitalByIdOrName(String any) async {
    final userSnap = await _getUserDoc();

    final hospitalData = await _findHospitalByAny(any);
    if (hospitalData == null) {
      throw Exception('Hospital "$any" não encontrado na coleção "hospitais".');
    }

    final idHospital = (hospitalData['id_hospital'] as String?) ??
        (hospitalData['_docId'] as String);
    final nomeHospital =
        (hospitalData['nome_hospital'] as String?) ?? any.trim();

    await userSnap.reference.update({'hospitalAtivo': nomeHospital});

    _cachedHospitalId = idHospital;
    _cachedHospitalNome = nomeHospital;
  }

  /// Token do hospital ativo.
  Future<String?> getActiveHospitalToken() async {
    final id = await getActiveHospitalId();
    final hospital = await _db.collection('hospitais').doc(id).get();
    if (!hospital.exists) return null;
    return hospital.data()?['token_hospital'] as String?;
  }

  /// Nome do hospital ativo em cache (se já resolvido).
  String? get cachedHospitalNome => _cachedHospitalNome;

  /// Limpa o cache (ex.: no logout).
  void clearCache() {
    _cachedHospitalId = null;
    _cachedHospitalNome = null;
  }
}
