import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TcleService {
  final _requests = FirebaseFirestore.instance.collection('tcleRequests');

  Future<String> createRequest({
    required String patientName,
    required String responsibleName,
    required String whatsapp,
    required String hospital,
    String? patientDraftId,
  }) async {
    final random = Random.secure();
    final token = base64Url
        .encode(List<int>.generate(24, (_) => random.nextInt(256)))
        .replaceAll('=', '');
    final user = FirebaseAuth.instance.currentUser!;

    await _requests.doc(token).set({
      'patientName': patientName.trim(),
      'responsibleName': responsibleName.trim(),
      'whatsapp': whatsapp.replaceAll(RegExp(r'\D'), ''),
      'hospital': hospital,
      'patientDraftId': patientDraftId,
      'status': 'pending',
      'consentVersion': 'TCLE-RHCICI-HML-2026-09',
      'createdBy': user.uid,
      'createdByEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 7)),
      ),
    });
    return token;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String token) {
    return _requests.doc(token).snapshots();
  }

  Future<void> sign({
    required String token,
    required String signerName,
    required List<List<double?>> signaturePoints,
  }) async {
    await _requests.doc(token).update({
      'signerName': signerName.trim(),
      'accepted': true,
      'signaturePoints': signaturePoints,
      'status': 'signed',
      'signedAt': FieldValue.serverTimestamp(),
      'signedUserAgent': 'flutter-web-hml',
    });
  }
}
