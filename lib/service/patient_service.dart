import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hashlib/hashlib.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import '../model/patient_model.dart';

class PatientService {
  String? email = AuthenticationService(FirebaseAuth.instance).getName();
  String? token;

  PatientService(this.token);
  Future<String> getInitialId() async {
    final idHospital = await HospitalServicer().getActiveHospitalId();
    return '${idHospital}00';
  }

  Future<String> fetchLastPatientRecordId() async {
    final response = await http.post(
      Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
      body: {
        'token': token,
        'content': 'record',
        'format': 'json',
        'type': 'flat'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) {
        // Se não houver dados de pacientes, retorne o ID inicial com o prefixo correto
        return getInitialId();
      }

      // Ordenar os registros com base no record_id
      data.sort((a, b) =>
          (a['record_id'] as String).compareTo(b['record_id'] as String));
      var lastPatient = data.last;
      String lastRecordId = lastPatient['record_id'];

      // Extrair a parte numérica do ID do registro
      final regex = RegExp(r'(\d+)$');
      final match = regex.firstMatch(lastRecordId);

      if (match != null) {
        // Incrementar a parte numérica
        int numericPart = int.parse(match.group(0)!);
        numericPart++;

        // Gerar o novo ID de registro com o mesmo prefixo e a parte numérica incrementada
        String newRecordId = lastRecordId.replaceFirst(
            regex, numericPart.toString().padLeft(match.group(0)!.length, '0'));

        return newRecordId;
      } else {
        throw Exception('Formato de ID de registro inválido');
      }
    } else {
      throw Exception('Falha ao carregar os pacientes');
    }
  }

  Future<List<Patient>> fetchPatients() async {
    final response = await http.post(
      Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
      body: {
        'token': token,
        'content': 'record',
        'format': 'json',
        'type': 'flat'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Patient.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar os pacientes');
    }
  }

  Future<void> enviarRegistroParaAPI(
    BuildContext context, {
    required String? ultimoId,
    required String nomePaciente,
    required String dataNascimento,
    required String idadePaciente,
    required String? sexoPaciente,
    required String? etniaPaciente,
    required String cpfPaciente,
    required String cartaoSus,
    required String? cidadeProc,
    required String? estadoProc,
    required String? estadoObito,
    required String? localDiag,
    required String? localTrat,
    required String dataPriSintomas,
    required String dataPriConsulta,
    required String dataDoDiagnostico,
    required String dataDoEncOncoPed,
    required String? diagnostico,
    required String? diagnosticoDetalhado,
    required String? estadiamento,
    required String diagnosticoDescritivo,
    required String? metastase,
    required String? localDoTumor,
    required List<String> examesDiagnosticoSelecionado,
    required String dataInicioDoTrat,
    required String? localInicioDoTrat,
    required String? tipoTratamentoPac,
    String? tipotmo,
    required String? vivo,
    required String? refratariedade,
    required String? recaida,
    required String dataDaRecaida,
    required String? obito,
    required String dataDoObito,
    required String? motivoObitoPac,
    required String nomeDoProtocolo,
    required String? classificacaoMolecular,
    required String dadosMolecular,
    required DateTime? dataAtualizacaoCadastro,
    required String nomeDaMae,
    required String dataUltimoTrat,
    PlatformFile? selectedPdfFile,
    PlatformFile? selectedTcleFile,
    required String? cidadedoobito,
    String? estadiamentodotumor,
    required String outrohospitaldiag,
    required String outrolocaltratamento,
    required String outrolocaliniciotratamento,
    required String primeiraLinha,
    required String segundaLinha,
    required String terceiraLinha,
    required String quartaLinha,
    required String? especialidadePaciente,
    required String? especialidadePaciente2,
  }) async {
    final email = AuthenticationService(FirebaseAuth.instance).getName();
    final examesString = examesDiagnosticoSelecionado.join(', ');

    // Se não houver um ID, gera um novo hash SHA1 de 16 caracteres
    final idGerado = ultimoId ??
        sha1
            .convert(utf8.encode(DateTime.now().toString()))
            .toString()
            .substring(0, 16);

    final record = {
      'record_id': ultimoId,
      'nome_do_paciente': nomePaciente,
      'nome_da_m_e_do_paciente': nomeDaMae,
      'cpf': cpfPaciente,
      'cns': cartaoSus,
      'municio_residencia': cidadeProc,
      'uf_procedencia': estadoProc,
      'data_de_nascimento': dataNascimento,
      'sexo': sexoPaciente,
      'etnia': etniaPaciente,
      'especialidade_do_m_dica_do': especialidadePaciente,
      'local_de_tratamento': localTrat,
      'local_diagnostico': localDiag,
      'mudou_de_hospital_durante': outrolocaltratamento,
      'data_dos_primeiros_sintoma': dataPriSintomas,
      'data_da_primeira_consulta': dataPriConsulta,
      'data_diagnostico': dataDoDiagnostico,
      'data_do_encontro_com_o_ped': dataDoEncOncoPed,
      'diagn_stico': diagnostico,
      'diagn_stico_detalhado': diagnosticoDetalhado,
      'estadiamento_do_tumor': estadiamento,
      'diagn_stico_descritivo': diagnosticoDescritivo,
      'met_stase': metastase,
      'local_do_tumor': localDoTumor,
      'exame_que_realizou_o_diagn': examesString,
      'data_tratamento': dataInicioDoTrat,
      'inicio_tratamento': localInicioDoTrat,
      'tipo_de_tratamento': tipoTratamentoPac,
      'tipotmo': tipotmo,
      'paciente_est_vivo': vivo,
      'houve_refratariedade': refratariedade,
      'houve_reca_da': recaida,
      'data_da_reca_da': dataDaRecaida,
      'houve_bito': obito,
      'data_de_bito': dataDoObito,
      'motivo_do_bito': motivoObitoPac,
      'nome_do_protocolo_de_trata': nomeDoProtocolo,
      'classifica_o_molecular': classificacaoMolecular,
      'dadosmolecular': dadosMolecular,
      'dt_atualizacao': dataAtualizacaoCadastro.toString(),
      'cidade_de_bito': cidadedoobito,
      'estado_obito': estadoObito,
      'data_do_ltimo_tratamento': dataUltimoTrat,
      'outrohospitaldiag': outrohospitaldiag,
      'outro_local_de_inicio_de_t': outrolocaliniciotratamento,
      'primeira_linha_de_tratamen': primeiraLinha,
      'segunda_linha_de_tratament': segundaLinha,
      'terceira_linha_de_tratamen': terceiraLinha,
      'quarta_linha_de_tratamento': quartaLinha,
      'especialidade_medica_2': especialidadePaciente2,
    };

    final data = jsonEncode([record]);

    final response = await http.post(
      Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'token': token!,
        'content': 'record',
        'format': 'json',
        'type': 'flat',
        'data': data,
        'returnFormat': 'json',
      },
    );

    if (response.statusCode == 200) {
      AnimatedSnackBar.material(
        'Paciente cadastrado com sucesso!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);

      await FirebaseFirestore.instance.collection('logs').add({
        'tipo': 'cadastro',
        'id_paciente': idGerado,
        'nome_paciente': nomePaciente,
        'usuario': email,
        'data': FieldValue.serverTimestamp(),
      });

      // Envia o PDF após o sucesso do cadastro
      if (selectedPdfFile != null && selectedPdfFile.size != 0) {
        await enviarArquivoParaAPI(context, token!, idGerado, selectedPdfFile);
      }
      if (selectedTcleFile != null && selectedTcleFile.size != 0) {
        await enviarTcleParaAPI(token!, idGerado, selectedTcleFile);
      }
    } else {
      AnimatedSnackBar.material(
        'Erro ao cadastrar novo paciente! (${response.statusCode})',
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      ).show(context);
    }
  }

  Future<void> enviarArquivoParaAPI(BuildContext context, String token,
      String ultimoId, selectedPdfFile) async {
    if (selectedPdfFile == null || selectedPdfFile.bytes == null) {
      throw Exception('Nenhum arquivo PDF foi selecionado.');
    }

    var uri = Uri.parse('https://redcap.redcapbrasil.com.br/api/');

    var request = http.MultipartRequest('POST', uri)
      ..fields['token'] = token
      ..fields['content'] = 'file'
      ..fields['action'] = 'import'
      ..fields['record'] = ultimoId
      ..fields['field'] = 'arquivo_exame' // Nome do campo de arquivo no REDCap
      ..fields['event'] = 'event_1_arm_1'
      ..fields['returnFormat'] = 'json';

    var multipartFile = http.MultipartFile.fromBytes(
      'file', // Nome do campo de arquivo
      selectedPdfFile.bytes,
      filename: selectedPdfFile.name,
      contentType: MediaType('application', 'pdf'),
    );

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      print('HTTP Status (file upload): ${response.statusCode}');
      if (response.statusCode == 200) {
        print(responseBody.body);
      } else {
        print('Erro ao enviar o arquivo: ${responseBody.body}');
        throw Exception('Erro ao enviar o arquivo: ${responseBody.body}');
      }
    } catch (error) {
      print('Erro ao enviar o arquivo: $error');
    }
  }

  Future<void> enviarTcleParaAPI(
    String token,
    String recordId,
    PlatformFile selectedTcleFile,
  ) async {
    if (selectedTcleFile.bytes == null) {
      throw Exception('Não foi possível ler o arquivo do TCLE.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
    )
      ..fields['token'] = token
      ..fields['content'] = 'file'
      ..fields['action'] = 'import'
      ..fields['record'] = recordId
      ..fields['field'] = 'arquivo_tcle'
      ..fields['event'] = 'event_1_arm_1'
      ..fields['returnFormat'] = 'json'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedTcleFile.bytes!,
          filename: selectedTcleFile.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao enviar o TCLE ao REDCap (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> updatedadosparaapi(
    BuildContext context, {
    required String recordid,
    required List<String> examesDiagnosticoSelecionado,
    required String nomeController,
    required String dataNascimentoController,
    required String idadeController,
    required String? sexoSelecionado,
    required String? etniapacSelecionado,
    required String? especialidadeSelecionado,
    required String? especialidadeSelecionado2,
    required String cpfPac,
    required String cartaoSus,
    required String? cidadeProc,
    required String? estadoSelecionado,
    required String? estadoSelecionado2,
    required String? localDiag,
    required String? localTrat,
    required String dataPriSintomas,
    required String dataPriConsulta,
    required String dataDoDiagnostico,
    required String dataDoEncOncoPed,
    required String? diagnostico,
    required String? houvenovodiagnostico,
    required String? novoDiagnostico,
    required String? diagnosticoDetalhado,
    required String? estadiamento,
    required String? estadiamento2,
    required String? diagnosticoDetalhado2,
    required String? diagnosticoDescritivo,
    required String? metastase,
    required String? localDoTumor,
    required String dataInicioDoTrat,
    required String? localInicioDoTrat,
    required String? tipoTratamentoPac,
    String? tipotmo,
    required String? vivo,
    required String? refratariedadepacSelecionado,
    required String? recaidapacSelecionado,
    required String dataDaRecaida,
    required String? obito,
    required String dataDoObito,
    required String? motivoObitoPac,
    required String nomeDoProtocolo,
    required String primeiraLinha,
    required String segundaLinha,
    required String terceiraLinha,
    required String quartaLinha,
    required String? classificacaoMolecular,
    required String dadosmolecular,
    required String nomeDaMaeController,
    required String? cidadeDoObito,
    required String dataUltimoTrat,
    required String outrohospitaldiag,
    required String outrolocaltratamento,
    required String outrolocaliniciotratamento,
    required DateTime? dataAtualizacaoCadastro,
    required String? especialidadePaciente2,
  }) async {
    String examesString = examesDiagnosticoSelecionado.join(', ');

    // Buscando dados antigos do paciente na API REDCap
    var response = await http.post(
      Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'token': token, // Substitua com o token da API
        'content': 'record',
        'format': 'json',
        'type': 'flat',
        'records': recordid,
      },
    );

    if (response.statusCode == 200) {
      var oldData = jsonDecode(response.body);
      var oldRecord = oldData[0];

      final Map<String, dynamic> changes = {};

      if (oldRecord['nomepac'] != nomeController) {
        changes['nome_do_paciente'] = nomeController;
      }
      if (oldRecord['nomedamae'] != nomeDaMaeController) {
        changes['nome_da_m_e_do_paciente'] = nomeDaMaeController;
      }
      if (oldRecord['cpfpac'] != cpfPac) {
        changes['cpf'] = cpfPac;
      }
      if (oldRecord['cartaosus'] != cartaoSus) {
        changes['cns'] = cartaoSus;
      }
      if (oldRecord['cidadeproc'] != cidadeProc) {
        changes['municio_residencia'] = cidadeProc;
      }
      if (oldRecord['estadoproc'] != estadoSelecionado) {
        changes['uf_procedencia'] = estadoSelecionado;
      }
      if (oldRecord['datanascpac'] != dataNascimentoController) {
        changes['data_de_nascimento'] = dataNascimentoController;
      }

      if (oldRecord['sexopac'] != sexoSelecionado) {
        changes['sexo'] = sexoSelecionado;
      }

      if (oldRecord['etniapac'] != etniapacSelecionado) {
        changes['etnia'] = etniapacSelecionado;
      }

// Informações clínicas
      if (oldRecord['localtrat'] != localTrat) {
        changes['local_de_tratamento'] = localTrat; // 1..7
      }
      if (oldRecord['localdiag'] != localDiag) {
        changes['local_diagnostico'] = localDiag; // 1..7
      }
      if (oldRecord['outrohospitaldiag'] != outrohospitaldiag) {
        changes['outrohospitaldiag'] =
            outrohospitaldiag; // campo 15 existe no codebook
      }
      if (oldRecord['dataprisintomas'] != dataPriSintomas) {
        changes['data_dos_primeiros_sintoma'] = dataPriSintomas;
      }
      if (oldRecord['datapriconsulta'] != dataPriConsulta) {
        changes['data_da_primeira_consulta'] = dataPriConsulta;
      }
      if (oldRecord['especialidadepaciente'] != especialidadeSelecionado) {
        changes['especialidade_do_m_dica_do'] = especialidadeSelecionado;
      }
      if (oldRecord['datadodiagnostico'] != dataDoDiagnostico) {
        changes['data_diagnostico'] = dataDoDiagnostico;
      }
      if (oldRecord['data_do_encontro_com_o_ped'] != dataDoEncOncoPed) {
        changes['data_do_encontro_com_o_ped'] = dataDoEncOncoPed;
      }
      if (oldRecord['diagnostico'] != diagnostico) {
        changes['diagn_stico'] = diagnostico;
      }
      if (oldRecord['diagnosticodetalhado'] != diagnosticoDetalhado) {
        changes['diagn_stico_detalhado'] = diagnosticoDetalhado;
      }
      if (oldRecord['estadiamentodotumor'] != estadiamento) {
        changes['estadiamento_do_tumor'] = estadiamento;
      }
      if (oldRecord['diagnosticodescritivo'] != diagnosticoDescritivo) {
        changes['diagn_stico_descritivo'] = diagnosticoDescritivo;
      }
// Se você usa "diagnosticodetalhado2" como morfológico:
      if (oldRecord['diagnosticodetalhado2'] != diagnosticoDetalhado2) {
        changes['diag_morfologico'] = diagnosticoDetalhado2;
      }
      if (oldRecord['localdotumor'] != localDoTumor) {
        changes['diagn_stico_topol_gico'] =
            localDoTumor; // ou 'local_do_tumor' conforme seu significado
        changes['local_do_tumor'] =
            localDoTumor; // mantenho ambos se você usava os dois conceitos
      }
      if (oldRecord['metastase'] != metastase) {
        changes['met_stase'] = metastase;
      }
// Corrige espaço no nome do campo do exame:
      if (oldRecord['exame_que_realizou_o_diagn'] != examesString) {
        changes['exame_que_realizou_o_diagn'] = examesString;
      }
// Se houver data do exame em alguma variável sua:
// if (oldRecord['data_do_exame'] != dataDoExame) changes['data_do_exame'] = dataDoExame;

      if (oldRecord['classificacaomolecular'] != classificacaoMolecular) {
        changes['classifica_o_molecular'] = classificacaoMolecular;
      }
      if (oldRecord['dadosmolecular'] != dadosmolecular) {
        changes['dadosmolecular'] = dadosmolecular;
      }

// Informações de tratamento 1
      if (oldRecord['datainiciodotrat'] != dataInicioDoTrat) {
        changes['data_tratamento'] = dataInicioDoTrat;
      }
      if (oldRecord['localiniciodotrat'] != localInicioDoTrat) {
        changes['inicio_tratamento'] = localInicioDoTrat; // 1..7
      }
      if (oldRecord['outrolocaliniciodotrat'] != outrolocaliniciotratamento) {
        changes['outro_local_de_inicio_de_t'] = outrolocaliniciotratamento;
      }
      if (oldRecord['nomedoprotocolo'] != nomeDoProtocolo) {
        changes['nome_do_protocolo_de_trata'] = nomeDoProtocolo;
      }
      if (oldRecord['primeira_linha'] != primeiraLinha) {
        changes['primeira_linha_de_tratamen'] = primeiraLinha;
      }
      if (oldRecord['segunda_linha'] != segundaLinha) {
        changes['segunda_linha_de_tratament'] = segundaLinha;
      }
      if (oldRecord['terceira_linha'] != terceiraLinha) {
        changes['terceira_linha_de_tratamen'] = terceiraLinha;
      }
      if (oldRecord['quarta_linha'] != quartaLinha) {
        changes['quarta_linha_de_tratamento'] = quartaLinha;
      }
      if (oldRecord['tipotratamentopac'] != tipoTratamentoPac) {
        changes['tipo_de_tratamento'] = tipoTratamentoPac;
      }

      if (oldRecord['tipotmo'] != tipotmo) {
        changes['tipotmo'] = tipotmo;
      }

      if (oldRecord['dataultimotrat'] != dataUltimoTrat) {
        changes['data_do_ltimo_tratamento'] = dataUltimoTrat;
      }
      if (oldRecord['vivo'] != vivo) {
        changes['paciente_est_vivo'] =
            vivo; // padronize '0/1' ou 'Sim/Não' conforme o instrumento
      }

// Informações de tratamento 2 (segmento)
      if (oldRecord['estadiamento2'] != estadiamento2) {
        changes['estadiamento_2'] = estadiamento2;
      }
      if (oldRecord['novodiagnostico'] != novoDiagnostico) {
        changes['novo_diagn_stico_segmento'] = novoDiagnostico;
      }
      if (oldRecord['houvenovodiagnostico'] != houvenovodiagnostico) {
        changes['houve_novo_diagn_stico_seg'] = houvenovodiagnostico;
      }
      if (oldRecord['refratariedade'] != refratariedadepacSelecionado) {
        changes['houve_refratariedade'] = refratariedadepacSelecionado;
      }
      if (oldRecord['recaida'] != recaidapacSelecionado) {
        changes['houve_reca_da'] = recaidapacSelecionado;
      }
      if (oldRecord['datadarecaida'] != dataDaRecaida) {
        changes['data_da_reca_da'] = dataDaRecaida;
      }
      if (oldRecord['obito'] != obito) {
        changes['houve_bito'] = obito;
      }
      if (oldRecord['datadoobito'] != dataDoObito) {
        changes['data_de_bito'] = dataDoObito;
      }
      if (oldRecord['cidadedoobito'] != cidadeDoObito) {
        changes['cidade_de_bito'] = cidadeDoObito;
      }
      if (oldRecord['estadodoobito'] != estadoSelecionado2) {
        changes['estado_obito'] = estadoSelecionado2;
      }
      if (oldRecord['motivoobitopac'] != motivoObitoPac) {
        changes['motivo_do_bito'] = motivoObitoPac;
      }
      if (oldRecord['dt_atualizacao'] != dataAtualizacaoCadastro.toString()) {
        changes['dt_atualizacao'] = dataAtualizacaoCadastro.toString();
      }
      if (oldRecord['especialidade_medica_2'] != especialidadePaciente2) {
        changes['especialidade_medica_2'] = especialidadePaciente2;
      }

      // Registrando as alterações no Firebase
      if (changes.isNotEmpty) {
        await FirebaseFirestore.instance.collection('logs').add({
          'tipo': 'atualizacao',
          'id_paciente': recordid,
          'nome_paciente': nomeController,
          'usuario': email, // Substitua pelo email do usuário autenticado
          'alteracoes': changes,
          'data': FieldValue.serverTimestamp(),
        });
      }

      // Enviando os dados atualizados para a API REDCap

      var record = {
        'record_id': recordid,
        'nome_do_paciente': nomeController,
        'nome_da_m_e_do_paciente': nomeDaMaeController,
        'cpf': cpfPac,
        'cns': cartaoSus,
        'municio_residencia': cidadeProc,
        'uf_procedencia': estadoSelecionado,
        'data_de_nascimento': dataNascimentoController,
        'sexo': sexoSelecionado,
        'etnia': etniapacSelecionado,
        'especialidade_do_m_dica_do': especialidadeSelecionado,
        'local_de_tratamento': localTrat,
        'local_diagnostico': localDiag,
        'mudou_de_hospital_durante': outrolocaltratamento,
        'data_dos_primeiros_sintoma': dataPriSintomas,
        'data_da_primeira_consulta': dataPriConsulta,
        'data_diagnostico': dataDoDiagnostico,
        'data_do_encontro_com_o_ped': dataDoEncOncoPed,
        'diagn_stico': diagnostico,
        'diagn_stico_detalhado': diagnosticoDetalhado,
        'estadiamento_do_tumor': estadiamento,
        'diagn_stico_descritivo': diagnosticoDescritivo,
        'met_stase': metastase,
        'local_do_tumor': localDoTumor,
        'exame_que_realizou_o_diagn': examesString,
        'data_tratamento': dataInicioDoTrat,
        'inicio_tratamento': localInicioDoTrat,
        'tipo_de_tratamento': tipoTratamentoPac,
        'tipotmo': tipotmo,

        'paciente_est_vivo': vivo,
        'houve_refratariedade': refratariedadepacSelecionado,
        'houve_reca_da': recaidapacSelecionado,
        'data_da_reca_da': dataDaRecaida,
        'houve_bito': obito,
        'data_de_bito': dataDoObito,
        'motivo_do_bito': motivoObitoPac,
        'nome_do_protocolo_de_trata': nomeDoProtocolo,
        'classifica_o_molecular': classificacaoMolecular,
        'dadosmolecular': dadosmolecular,
        'dt_atualizacao': dataAtualizacaoCadastro.toString(),
        'cidade_de_bito': cidadeDoObito,
        'estado_obito': estadoSelecionado2,
        'data_do_ltimo_tratamento': dataUltimoTrat,
        'outrohospitaldiag': outrohospitaldiag,
        'outro_local_de_inicio_de_t': outrolocaliniciotratamento,
        'primeira_linha_de_tratamen': primeiraLinha,
        'segunda_linha_de_tratament': segundaLinha,
        'terceira_linha_de_tratamen': terceiraLinha,
        'quarta_linha_de_tratamento': quartaLinha,
        //'especialidade_do_m_dica_do_2':            especialidadeSelecionado2, // ajuste o nome exato
        'diagn_stico_detalhado_segm':
            diagnosticoDetalhado2, // ajuste o nome exato
        'houve_novo_diagn_stico_seg':
            houvenovodiagnostico, // ajuste o nome exato // ajuste o nome exato
        'diagnostico2': novoDiagnostico, // ajuste o nome exato
        'estadiamento_2': estadiamento2, // ajuste o nome exato
        'especialidade_medica_2': especialidadePaciente2,
      };

      var data = jsonEncode([record]);

      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var fields = {
        'token': token,
        'content': 'record',
        'format': 'json',
        'type': 'flat',
        'data': data,
      };

      var client = http.Client();
      try {
        var response = await client.post(
          Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
          headers: headers,
          body: fields,
        );

        print('HTTP Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          AnimatedSnackBar.material(
            'Paciente atualizado com sucesso ',
            type: AnimatedSnackBarType.success,
            mobileSnackBarPosition: MobileSnackBarPosition.bottom,
            desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          ).show(context);
        } else {
          AnimatedSnackBar.material(
            'Erro: não foi possível atualizar o paciente ',
            type: AnimatedSnackBarType.error,
            mobileSnackBarPosition: MobileSnackBarPosition.bottom,
            desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          ).show(context);
          print(response.body);
        }
      } catch (error) {
        print('Erro ao enviar dados: $error');
        AnimatedSnackBar.material(
          'Erro ao enviar dados para a API $error',
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      } finally {
        client.close();
      }
    } else {
      print('Erro ao buscar dados antigos: ${response.statusCode}');
    }
  }

  Future<Patient?> verificarPacientePorId(String pacienteId) async {
    try {
      final response = await http.post(
        Uri.parse('https://redcap.redcapbrasil.com.br/api/'),
        body: {
          'token': token,
          'content': 'record',
          'format': 'json',
          'type': 'flat',
          'records': pacienteId,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Patient.fromJson(data.first);
        } else {
          return null; // Paciente não encontrado
        }
      } else {
        throw Exception('Erro ao buscar paciente: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao verificar paciente: $error');
      return null;
    }
  }
}

// Função para enviar o arquivo PDF para a API REDCap
