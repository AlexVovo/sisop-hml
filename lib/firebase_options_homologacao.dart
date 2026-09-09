import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Configuração exclusiva do projeto Firebase de homologação.
///
/// Os valores são fornecidos com `--dart-define-from-file` para impedir que
/// esta branch use acidentalmente o banco de produção.
class HomologacaoFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase de homologação não configurado para esta plataforma.',
        );
      default:
        throw UnsupportedError('Plataforma não suportada pelo Firebase.');
    }
  }

  static String _required(String name, String value) {
    if (value.isEmpty) {
      throw StateError(
        'Configuração de homologação ausente: $name. '
        'Execute com --dart-define-from-file=config/homologacao.json.',
      );
    }
    return value;
  }

  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _required(
          'FIREBASE_WEB_API_KEY',
          const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
        ),
        appId: _required(
          'FIREBASE_WEB_APP_ID',
          const String.fromEnvironment('FIREBASE_WEB_APP_ID'),
        ),
        messagingSenderId: _required(
          'FIREBASE_MESSAGING_SENDER_ID',
          _messagingSenderId,
        ),
        projectId: _required('FIREBASE_PROJECT_ID', _projectId),
        authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        storageBucket: _storageBucket,
        measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _required(
          'FIREBASE_ANDROID_API_KEY',
          const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
        ),
        appId: _required(
          'FIREBASE_ANDROID_APP_ID',
          const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
        ),
        messagingSenderId: _required(
          'FIREBASE_MESSAGING_SENDER_ID',
          _messagingSenderId,
        ),
        projectId: _required('FIREBASE_PROJECT_ID', _projectId),
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _required(
          'FIREBASE_IOS_API_KEY',
          const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
        ),
        appId: _required(
          'FIREBASE_IOS_APP_ID',
          const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
        ),
        messagingSenderId: _required(
          'FIREBASE_MESSAGING_SENDER_ID',
          _messagingSenderId,
        ),
        projectId: _required('FIREBASE_PROJECT_ID', _projectId),
        storageBucket: _storageBucket,
        iosBundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: _required(
          'FIREBASE_MACOS_API_KEY',
          const String.fromEnvironment('FIREBASE_MACOS_API_KEY'),
        ),
        appId: _required(
          'FIREBASE_MACOS_APP_ID',
          const String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
        ),
        messagingSenderId: _required(
          'FIREBASE_MESSAGING_SENDER_ID',
          _messagingSenderId,
        ),
        projectId: _required('FIREBASE_PROJECT_ID', _projectId),
        storageBucket: _storageBucket,
        iosBundleId: const String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID'),
      );
}
