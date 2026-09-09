import 'dart:convert';
import 'package:http/http.dart' as http;

class EstadoService {
  Future<void> fetchMunicipios(
      String? estado, Function(List<String>) onMunicipiosFetched) async {
    var uri = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$estado/municipios');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var municipios = json.decode(response.body);
      var municipiosList = List<String>.from(municipios.map((x) => x['nome']));
      onMunicipiosFetched(municipiosList);
    } else {
      throw Exception('Failed to load municipios');
    }
  }
}
