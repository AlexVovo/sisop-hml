import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RedcapService {
  static const _apiUrl = 'https://redcap.redcapbrasil.com.br/api/';

  static const Map<String, String> _estabelecimentos = {
    '1': 'HCPA - Hospital de Clínicas de Porto Alegre',
    '2':
        'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre',
    '3': 'GHC - Grupo Hospitalar Conceição',
    '4': 'HSVP - Hospital São Vicente de Paulo',
    '5': 'HGCS - Hospital Geral de Caxias do Sul',
    '6': 'HUSM - Hospital Universitário de Santa Maria',
    '7': 'Outro',
  };

  static const Map<String, List<Map<String, String>>> _areas = {
    'Identificação': [
      {'campo': 'nome_do_paciente', 'rotulo': 'Nome do paciente'},
      {'campo': 'nome_da_m_e_do_paciente', 'rotulo': 'Nome da mãe do paciente'},
      {'campo': 'cpf', 'rotulo': 'CPF'},
      {'campo': 'cns', 'rotulo': 'Cartão SUS (CNS)'},
      {'campo': 'municio_residencia', 'rotulo': 'Município de residência'},
      {'campo': 'uf_procedencia', 'rotulo': 'UF de procedência'},
      {'campo': 'data_de_nascimento', 'rotulo': 'Data de nascimento'},
      {'campo': 'idade_do_paciente', 'rotulo': 'Idade do paciente'},
      {'campo': 'sexo', 'rotulo': 'Sexo'},
      {'campo': 'etnia', 'rotulo': 'Etnia'},
      {
        'campo': 'info_socio_complete',
        'rotulo': 'Formulário de identificação completo'
      },
    ],
    'Atendimento': [
      {'campo': 'local_de_tratamento', 'rotulo': 'Local de tratamento'},
      {'campo': 'local_diagnostico', 'rotulo': 'Local de diagnóstico'},
      {
        'campo': 'data_dos_primeiros_sintoma',
        'rotulo': 'Data dos primeiros sintomas'
      },
      {
        'campo': 'data_da_pimeira_consulta',
        'rotulo': 'Data da primeira consulta'
      },
      {
        'campo': 'especialidade_do_m_dica_do',
        'rotulo': 'Especialidade médica do primeiro encaminhamento'
      },
      {
        'campo': 'data_do_encontro_com_o_ped',
        'rotulo': 'Data do encontro com oncologista pediátrico'
      },
      {'campo': 'data_diagnostico', 'rotulo': 'Data do diagnóstico'},
      {'campo': 'classifica_o_molecular', 'rotulo': 'Classificação molecular'},
    ],
    'Diagnóstico': [
      {'campo': 'diagn_stico', 'rotulo': 'Diagnóstico'},
      {'campo': 'diagn_stico_detalhado', 'rotulo': 'Diagnóstico detalhado'},
      {'campo': 'estadiamento_do_tumor', 'rotulo': 'Estadiamento do tumor'},
      {'campo': 'diagn_stico_descritivo', 'rotulo': 'Diagnóstico descritivo'},
      {'campo': 'diagn_stico_morfol_gico', 'rotulo': 'Diagnóstico morfológico'},
      {'campo': 'meta_stase', 'rotulo': 'Metástase'},
      {'campo': 'local_do_tumor', 'rotulo': 'Local do tumor'},
      {
        'campo': 'especialidade_medica_2',
        'rotulo': 'Especialidade médica do segundo encaminhamento'
      },
      {'campo': 'arquivo_exame', 'rotulo': 'Arquivo de exames'},
    ],
    'Tratamento': [
      {'campo': 'data_tratamento', 'rotulo': 'Data do tratamento'},
      {'campo': 'inicio_tratamento', 'rotulo': 'Local de início do tratamento'},
      {'campo': 'tipo_de_tratamento', 'rotulo': 'Tipo de tratamento'},
      {'campo': 'nome_do_protocolo_de_trata', 'rotulo': 'Nome do protocolo'},
      {
        'campo': 'primeira_linha_de_tratamen',
        'rotulo': 'Primeira linha de tratamento'
      },
      {
        'campo': 'segunda_linha_de_tratament',
        'rotulo': 'Segunda linha de tratamento'
      },
      {
        'campo': 'terceira_linha_de_tratamen',
        'rotulo': 'Terceira linha de tratamento'
      },
      {
        'campo': 'quarta_linha_de_tratamento',
        'rotulo': 'Quarta linha de tratamento'
      },
      {
        'campo': 'data_do_ltimo_tratamento',
        'rotulo': 'Data do último tratamento'
      },
    ],
    'Acompanhamento': [
      {'campo': 'paciente_est_vivo', 'rotulo': 'Paciente está vivo'},
      {'campo': 'houve_refratariedade', 'rotulo': 'Houve refratariedade'},
      {'campo': 'houve_reca_da', 'rotulo': 'Houve recaída'},
      {'campo': 'houve_bito', 'rotulo': 'Houve óbito'},
      {'campo': 'data_obito', 'rotulo': 'Data do óbito'},
    ],
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchIndicadoresPublicos() async {
    final snapshot =
        await _firestore.collection('dashboard_public').doc('completude').get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception(
          'O dashboard ainda não foi atualizado pelo administrador.');
    }
    return snapshot.data()!;
  }

  Future<Map<String, dynamic>> atualizarIndicadoresPublicos(
      String token) async {
    final body = <String, String>{
      'token': token,
      'content': 'record',
      'format': 'json',
      'type': 'flat',
    };
    final response = await http.post(Uri.parse(_apiUrl), body: body);
    if (response.statusCode != 200) {
      throw Exception(
        'REDCap recusou a consulta (código ${response.statusCode}). '
        'Verifique se o token cadastrado pertence ao projeto correto.',
      );
    }

    final registros = (json.decode(response.body) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final resultado = <String, dynamic>{
      'areas': _calcular(registros),
      'estabelecimentos': _calcularPorEstabelecimento(registros),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('dashboard_public')
        .doc('completude')
        .set(resultado);
    return fetchIndicadoresPublicos();
  }

  List<Map<String, dynamic>> _calcular(List<Map<String, dynamic>> registros) {
    return _areas.entries.map((area) {
      final indicadores = area.value.map((definicao) {
        final campo = definicao['campo']!;
        final aplicaveis = campo == 'data_obito'
            ? registros
                .where((registro) => registro['houve_bito'] == 'Sim')
                .toList()
            : registros;
        final preenchidas =
            aplicaveis.where((registro) => _preenchido(registro[campo])).length;
        return <String, dynamic>{
          ...definicao,
          'preenchidas': preenchidas,
          'total': aplicaveis.length,
        };
      }).toList();
      return {
        'nome': area.key,
        'preenchidas': indicadores.fold<int>(
          0,
          (soma, item) => soma + item['preenchidas'] as int,
        ),
        'total': indicadores.fold<int>(
          0,
          (soma, item) => soma + item['total'] as int,
        ),
        'campos': indicadores,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _calcularPorEstabelecimento(
      List<Map<String, dynamic>> registros) {
    final agrupados = <String, List<Map<String, dynamic>>>{};
    for (final registro in registros) {
      final codigo = registro['local_de_tratamento']?.toString().trim() ?? '';
      agrupados.putIfAbsent(codigo, () => []).add(registro);
    }

    final codigos = agrupados.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.compareTo(b);
      });
    return codigos.map((codigo) {
      return <String, dynamic>{
        'codigo': codigo,
        'nome': codigo.isEmpty
            ? 'Não informado'
            : (_estabelecimentos[codigo] ?? 'Estabelecimento $codigo'),
        'areas': _calcular(agrupados[codigo]!),
      };
    }).toList();
  }

  bool _preenchido(dynamic valor) {
    return valor != null && valor.toString().trim().isNotEmpty;
  }
}
