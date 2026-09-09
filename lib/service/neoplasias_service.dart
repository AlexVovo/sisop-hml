import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:regsitroweb/model/neoplasias_model.dart';

class NeoplasiasService {
  /// Lê o JSON local `assets/neoplasias.json` e converte para uma lista de objetos `Neoplasia`.
  Future<void> fetchNeoplasias(
      Function(List<Neoplasia>) onNeoplasiasFetched) async {
    try {
      // Carrega o conteúdo do arquivo JSON localizado em assets
      final String response =
          await rootBundle.loadString('assets/neoplasias.json');

      // Decodifica o JSON para uma lista dinâmica
      final List<dynamic> neoplasiasJson = json.decode(response);

      // Mapeia cada item para o modelo Neoplasia
      final List<Neoplasia> neoplasias =
          neoplasiasJson.map((json) => Neoplasia.fromJson(json)).toList();

      // Retorna os dados via callback
      onNeoplasiasFetched(neoplasias);
    } catch (e) {
      print('❌ Erro ao carregar neoplasias dos assets: $e');
      throw Exception('Falha ao carregar neoplasias dos assets');
    }
  }
}
