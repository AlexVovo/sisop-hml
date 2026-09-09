import 'package:file_picker/file_picker.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:regsitroweb/service/estado_service.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:regsitroweb/service/patient_service.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:validatorless/validatorless.dart';
import '../../model/neoplasias_model.dart';
import '../../service/neoplasias_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
// import 'package:age_calculator/age_calculator.dart';

enum DraftSaveUiState { idle, saving, saved, error }

// ignore: camel_case_types
class widgetCadastroPacienteForm extends StatefulWidget {
  final String hospitalselecionado;
  final ValueChanged<DraftSaveUiState>? onDraftSaveStateChanged;
  widgetCadastroPacienteForm({
    super.key,
    required this.hospitalselecionado,
    this.onDraftSaveStateChanged,
  });

  @override
  WidgetCadastroPacienteFormState createState() =>
      WidgetCadastroPacienteFormState();
}

//ttttttttttttttttttttttttttt

//Token Hospital 1 :39AE91C50C41DA5112941F3EA9FCC1CB
//Token Hospital 2 :949E6FC94F1634480FBB3D73DEC89ADC
// ignore: camel_case_types
// ignore: camel_case_types
class WidgetCadastroPacienteFormState
    extends State<widgetCadastroPacienteForm> {
  String? email = AuthenticationService(FirebaseAuth.instance).getName();
  String? token;
  List<Neoplasia> _neoplasias = [];
  Timer? _debounce;

  String? recordId;

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeComparacaoController.dispose();
    _dataNascimentoController.dispose();
    _dataNascimentoCompController.dispose();
    _dataDaRecaida.dispose();
    _idadeController.dispose();
    _cpfPac.dispose();
    _cartaoSus.dispose();
    _diagnosticoDescritivo.dispose();
    _localDoTumor.dispose();
    _nomeDoProtocolo.dispose();
    _primeiraLinha.dispose();
    _segundaLinha.dispose();
    _terceiraLinha.dispose();
    _quartaLinha.dispose();
    _nomeDaMaeController.dispose();
    _dataUltimoTrat.dispose();
    _outroHospitaldiag.dispose();
    _outroHospitalTrat.dispose();
    _outroHospitalInicioTrat.dispose();
    _dadosmolecular.dispose();
    _dataPriSintomas.dispose();
    _dataPriConsulta.dispose();
    _datadoexame.dispose();
    _dataInicioDoTrat.dispose();
    _dataDoObito.dispose();
    _dataDoDiagnostico.dispose();
    _dataDoEncOncoPed.dispose();

    _debounce?.cancel();

    super.dispose();
  }
  // =========================
  // TMO
  // =========================

  List<String> _selectedItensTmo = [];

  final TextEditingController _outroTipoTmoController = TextEditingController();

  final List<String> _tiposTmo = [
    'Transplante autólogo (do próprio paciente)',
    'Transplante alogênico aparentado (doador familiar compatível)',
    'Transplante alogênico não aparentado (doador não familiar)',
    'Transplante haploidêntico (pais ou familiares parcialmente compatíveis)',
    'Outros',
  ];

  void _showTiposTmoDialog() async {
    /* const tipos = [ */
    final tipos = _tiposTmo;
    [
      'Autólogo',
      'Alogênico aparentado',
      'Alogênico não aparentado',
      'Cordão umbilical',
      'Haploidêntico',
      'Outros',
    ];

    List<String> temp = List.from(_selectedItensTmo);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tipos de TMO'),
              content: SingleChildScrollView(
                child: Column(
                  children: tipos.map((t) {
                    return CheckboxListTile(
                      title: Text(t),
                      value: temp.contains(t),
                      onChanged: (v) {
                        setStateDialog(() {
                          v! ? temp.add(t) : temp.remove(t);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Aplicar'),
                  onPressed: () {
                    setState(() {
                      _selectedItensTmo = temp;
                    });
                    // salvar seleção de tipos de TMO no rascunho
                    salvarCampoDropdown(
                        "tipotmo", _selectedItensTmo.join(', '));
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectTipodetartamento() async {
    List<String> temp = List.from(_selectedTratamentos);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tipo de tratamento do paciente'),
              content: SingleChildScrollView(
                child: Column(
                  children: treatmentTypes.map((t) {
                    return CheckboxListTile(
                      title: Text(t),
                      value: temp.contains(t),
                      onChanged: (v) {
                        setStateDialog(() {
                          v! ? temp.add(t) : temp.remove(t);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Aplicar'),
                  onPressed: () {
                    setState(() {
                      _selectedTratamentos = temp;

                      // se remover TMO → limpar tipos
                      if (!_selectedTratamentos
                          .any((e) => e.contains('Transplante'))) {
                        _selectedItensTmo.clear();
                        _outroTipoTmoController.clear();
                        // limpar rascunho relacionado ao TMO
                        salvarCampoDropdown("tipotmo", "");
                        salvarCampoDropdown("outroTipoTmo", "");
                      }
                    });
                    // salvar lista de tratamentos no rascunho
                    salvarCampoDropdown(
                        "tipoTratamentoPac", _selectedTratamentos.join(', '));
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? ultimoId;
  DateTime? dataatualizacaocad;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    iniciar();
  }

  Future<void> iniciar() async {
    // precisamos do token para calcular próximo id
    await buscandotokenhospital();

    await carregarOuCriarDraft();

    // Conectar autosave só depois de carregar os dados
    conectarAutoSave(_nomeController, "nome");
    conectarAutoSave(_nomeComparacaoController, "nome");
    conectarAutoSave(_dataNascimentoController, "dataNascimento");
    conectarAutoSave(_dataNascimentoCompController, "dataNascimento");
    conectarAutoSave(_nomeDaMaeController, "nomeDaMae");
    conectarAutoSave(_idadeController, "idade");
    // descobrir uma forma de conectar o autosave para campos de seleção
    conectarAutoSaveDropdown("sexo", _sexoSelecionado);
    conectarAutoSaveDropdown("etnia", _etniapacSelecionado);
    conectarAutoSave(_cpfPac, "cpf");
    conectarAutoSave(_cartaoSus, "cartaoSus");
    conectarAutoSaveDropdown("estado", _estadoSelecionado);
    conectarAutoSaveDropdown("cidade", _cidadeProc);
    conectarAutoSaveDropdown("localDiag", _localDiag);
    conectarAutoSaveDropdown("localTrat", _localTrat);
    conectarAutoSave(_dataPriSintomas, "dataPriSintomas");
    conectarAutoSave(_dataPriConsulta, "dataPriConsulta");
    conectarAutoSave(_dataDoEncOncoPed, "dataDoEncOncoPed");
    conectarAutoSave(_dataDoDiagnostico, "dataDoDiagnostico");
    conectarAutoSave(_diagnosticoDescritivo, "diagnosticoDescritivo");
    conectarAutoSave(_localDoTumor, "localDoTumor");
    conectarAutoSave(_dataInicioDoTrat, "dataInicioDoTrat");
    conectarAutoSaveDropdown("localInicioDoTrat", _localInicioDoTrat);
    conectarAutoSave(_nomeDoProtocolo, "nomeDoProtocolo");
    conectarAutoSave(_primeiraLinha, "primeiraLinha");
    conectarAutoSave(_segundaLinha, "segundaLinha");
    conectarAutoSave(_terceiraLinha, "terceiraLinha");
    conectarAutoSave(_quartaLinha, "quartaLinha");
    conectarAutoSave(_dataUltimoTrat, "dataUltimoTrat");
    conectarAutoSave(_dataDaRecaida, "dataDaRecaida");
    conectarAutoSaveDropdown("refratariedade", _refratariedadepacSelecionado);
    conectarAutoSaveDropdown("recaida", _recaidapacSelecionado);
    conectarAutoSaveDropdown("obito", _obito);
    conectarAutoSave(_dataDoObito, "dataDoObito");
    conectarAutoSave(_outroHospitaldiag, "outroHospitalDiag");
    conectarAutoSave(_outroHospitalTrat, "outroHospitalTrat");
    conectarAutoSave(_outroHospitalInicioTrat, "outroHospitalInicioTrat");
    // add autosave for molecular classification details
    conectarAutoSave(_dadosmolecular, "dadosMolecular");
    // ensure classificacao, estadiamento and classificacao detalhada are saved to draft
    conectarAutoSaveDropdown("classificacaoMolecular", _classificacaoMolecular);
    conectarAutoSaveDropdown("estadiamento", _estadiamento);
    conectarAutoSaveDropdown("diagnosticoDetalhado", _diagnosticoDetalhado);
    // autosave for TMO fields
    conectarAutoSaveDropdown("tipotmo", _selectedItensTmo.join(', '));
    conectarAutoSave(_outroTipoTmoController, "outroTipoTmo");
  }

  Future<void> carregarOuCriarDraft() async {
    final query = await FirebaseFirestore.instance
        .collection('temporaryPatients')
        .where('email', isEqualTo: email)
        .where('hospital', isEqualTo: widget.hospitalselecionado)
        .where('status', isEqualTo: 'draft')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      // make sure we have a real map so the analyzer won't complain later
      final formData =
          Map<String, dynamic>.from(data['formData'] as Map? ?? {});
      // existing draft for this user + hospital; use its id
      recordId = doc.id;

      String textValue(String key) => formData[key]?.toString() ?? '';
      String? optionalValue(String key) {
        final v = formData[key];
        if (v == null) return null;
        final s = v.toString();
        return s.isEmpty ? null : s;
      }

      _nomeController.text = textValue('nome');
      _nomeComparacaoController.text = textValue('nome');
      _dataNascimentoController.text = textValue('dataNascimento');
      _dataNascimentoCompController.text = textValue('dataNascimento');
      _idadeController.text = textValue('idade');
      _nomeDaMaeController.text = textValue('nomeDaMae');
      _cpfPac.text = textValue('cpf');
      _cartaoSus.text = textValue('cartaoSus');
      // dropdowns: use nullable helper so that absence or empty string -> null
      _estadoSelecionado = optionalValue('estado');
      _cidadeProc = optionalValue('cidade');
      _localDiag = optionalValue('localDiag');
      _localDiagCodigo = _localDiag != null ? _hospitalCodes[_localDiag] : null;
      _localTrat = optionalValue('localTrat');
      _localTratCodigo = _localTrat != null ? _hospitalCodes[_localTrat] : null;
      _dataPriSintomas.text = textValue('dataPriSintomas');
      _dataPriConsulta.text = textValue('dataPriConsulta');
      _dataDoEncOncoPed.text = textValue('dataDoEncOncoPed');
      _dataDoDiagnostico.text = textValue('dataDoDiagnostico');
      _diagnosticoDescritivo.text = textValue('diagnosticoDescritivo');
      _localDoTumor.text = textValue('localDoTumor');
      _dataInicioDoTrat.text = textValue('dataInicioDoTrat');
      _localInicioDoTrat = optionalValue('localInicioDoTrat');
      _inicioTratamentoCodigo = _localInicioDoTrat != null
          ? _hospitalCodes[_localInicioDoTrat]
          : null;
      _nomeDoProtocolo.text = textValue('nomeDoProtocolo');
      _primeiraLinha.text = textValue('primeiraLinha');
      _segundaLinha.text = textValue('segundaLinha');
      _terceiraLinha.text = textValue('terceiraLinha');
      _quartaLinha.text = textValue('quartaLinha');
      _dataUltimoTrat.text = textValue('dataUltimoTrat');
      _refratariedadepacSelecionado = optionalValue('refratariedade');
      _recaidapacSelecionado = optionalValue('recaida');
      _dataDaRecaida.text = textValue('dataDaRecaida');
      _obito = optionalValue('obito');
      _cidadeDoObito = optionalValue('cidadeDoObito');
      _dataDoObito.text = textValue('dataDoObito');
      _metastase = optionalValue('metastase');
      _selectedItemsexames =
          (formData['examesDiagnosticoSelecionado']?.toString() ?? '')
              .split(', ')
              .where((s) => s.isNotEmpty)
              .toList();
      _classificacaoMolecular = optionalValue('classificacaoMolecular');
      // restore molecular details from draft if available
      _dadosmolecular.text = textValue('dadosMolecular');
      // restore TMO selections and "outro" text from draft if present
      _selectedItensTmo = (formData['tipotmo']?.toString() ?? '')
          .split(', ')
          .where((s) => s.isNotEmpty)
          .toList();
      _outroTipoTmoController.text = textValue('outroTipoTmo');
      _vivo = optionalValue('vivo');
      _estadoSelecionado2 = optionalValue('estadoObito');
      _motivoObitoPac = optionalValue('motivoObito');
      _diagnostico = optionalValue('diagnostico');
      _diagnosticoDetalhado = optionalValue('diagnosticoDetalhado');
      // restore estadiamento (staging) from draft if available
      _estadiamento = optionalValue('estadiamento');

      final rawTrat = formData['tipoTratamentoPac']?.toString() ?? '';
      _selectedTratamentos =
          rawTrat.split(', ').where((s) => s.isNotEmpty).toList();
      _outroHospitaldiag.text = textValue('outroHospitalDiag');
      _outroHospitalTrat.text = textValue('outroHospitalTrat');
      _outroHospitalInicioTrat.text = textValue('outroHospitalInicioTrat');

      recordId = doc.id;

      // also populate some of the dropdown values that are used in the UI
      _etniapacSelecionado = optionalValue('etnia');
      // restore specialties from draft (keys match autosave calls)
      _especialidadepacSelecionado = optionalValue('especialidadePaciente');
      _especialidadepacSelecionado2 = optionalValue('especialidadePaciente2');

      setState(() {
        _etniaCodigo = formData['etnia']?.toString();
        _sexoSelecionado = formData['sexo']?.toString();
      });
    } else {
      // no draft yet for this user/hospital: compute a unique id and create
      // document.  _getUniqueDraftId handles collisions by checking existing
      // drafts in Firestore, so two people opening at the same time won't
      // get the same identifier.
      final unique = await _getUniqueDraftId();
      recordId = unique;
      await criarNovoDraft(recordId);
    }

    draftPronto = true;

    print("Draft carregado: $recordId");
    print("Docs encontrados: ${query.docs.length}");
    print("Email usado no query: $email");
    print("Hospital usado no query: ${widget.hospitalselecionado}");
  }

  // return a record id that is guaranteed not to collide with an
  // existing draft in Firestore.  This allows multiple users at the same
  // hospital (or even the same user with multiple windows) to open the form
  // simultaneously without overwriting each other's documents.
  Future<String> _getUniqueDraftId() async {
    String candidate = await _nextIdFromRedcap();
    final collection =
        FirebaseFirestore.instance.collection('temporaryPatients');
    final regex = RegExp(r'^(.*?)(\d+)\$');

    while (true) {
      final doc = await collection.doc(candidate).get();
      if (!doc.exists) return candidate;
      // already in use, increment numeric suffix
      final m = regex.firstMatch(candidate);
      if (m != null) {
        final prefix = m.group(1)!;
        int num = int.parse(m.group(2)!) + 1;
        int width = m.group(2)!.length;
        candidate = prefix + num.toString().padLeft(width, '0');
      } else {
        candidate = candidate + '1';
      }
    }
  }

  Future<void> criarNovoDraft([String? id]) async {
    // if caller provided an ID, trust it (it should already be unique);
    // otherwise compute one that is guaranteed unique.
    if (id != null) {
      recordId = id;
    } else {
      recordId = await _getUniqueDraftId();
    }

    final docRef = FirebaseFirestore.instance
        .collection('temporaryPatients')
        .doc(recordId);

    await docRef.set({
      'record_id': recordId,
      'email': email,
      'hospital': widget.hospitalselecionado,
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'formData': {},
    });

    print("Novo draft criado: $recordId");
  }

  Future<void> salvarCampo(String campo, String valor) async {
    if (recordId == null) return;

    widget.onDraftSaveStateChanged?.call(DraftSaveUiState.saving);
    try {
      await FirebaseFirestore.instance
          .collection('temporaryPatients')
          .doc(recordId)
          .update({
        'formData.$campo': valor,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("Campo salvo: $campo = $valor");
      widget.onDraftSaveStateChanged?.call(DraftSaveUiState.saved);
    } catch (e) {
      widget.onDraftSaveStateChanged?.call(DraftSaveUiState.error);
      rethrow;
    }
  }

  // calcula próximo ID simples: pega último ID do REDCap e soma 1
  Future<String> _nextIdFromRedcap() async {
    if (token == null) throw Exception('Token não disponível');
    String last = await PatientService(token!).fetchLastPatientRecordId();
    final regex = RegExp(r'^(.*?)(\d+)$');
    final m = regex.firstMatch(last);
    if (m != null) {
      String prefix = m.group(1)!;
      int num = int.parse(m.group(2)!);
      int width = m.group(2)!.length;
      int next = num + 1;
      return prefix + next.toString().padLeft(width, '0');
    }
    return last + '1';
  }

  // basicamente a mesma função so que para campos de selecao
  Future<void> salvarCampoDropdown(String campo, String valor) async {
    if (!draftPronto || recordId == null) return;

    widget.onDraftSaveStateChanged?.call(DraftSaveUiState.saving);
    try {
      await FirebaseFirestore.instance
          .collection('temporaryPatients')
          .doc(recordId)
          .update({
        'formData.$campo': valor,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("Campo salvo: $campo = $valor");
      widget.onDraftSaveStateChanged?.call(DraftSaveUiState.saved);
    } catch (e) {
      widget.onDraftSaveStateChanged?.call(DraftSaveUiState.error);
      rethrow;
    }
  }

  Future<void> buscandotokenhospital() async {
    setState(() {
      isLoading = true; // Inicia o carregamento
    });

    try {
      token =
          await HospitalServicer().buscarTokenSmart(widget.hospitalselecionado);

      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      await Future.delayed(const Duration(seconds: 2));

      // Busca o último ID de paciente e atualiza o estado
      ultimoId = await PatientService(token!).fetchLastPatientRecordId();
      dataatualizacaocad = DateTime.now();
      NeoplasiasService().fetchNeoplasias(_updateNeoplasias);
    } catch (e) {
      print(e.toString());
      // Aqui você pode adicionar lógica de tratamento de erro, como mostrar um alerta
    } finally {
      setState(() {
        isLoading = false; // Finaliza o carregamento
      });
    }
  }

  void _updateNeoplasias(List<Neoplasia> neoplasias) {
    setState(() {
      _neoplasias = neoplasias;
    });
  }

  final _formKey = GlobalKey<FormState>();

// Identificação do paciente
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nomeComparacaoController =
      TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _dataNascimentoCompController =
      TextEditingController();
  final TextEditingController _nomeDaMaeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _cpfPac = TextEditingController();
  var maskcpf = MaskTextInputFormatter(mask: '###.###.###-##');
  final TextEditingController _cartaoSus = TextEditingController();
  var maskcartaosus = MaskTextInputFormatter(mask: '###############');
// ##################################

  final TextEditingController _dataDaRecaida = TextEditingController();
  final TextEditingController _diagnosticoDescritivo = TextEditingController();
  final TextEditingController _localDoTumor = TextEditingController();
  final TextEditingController _nomeDoProtocolo = TextEditingController();
  final TextEditingController _primeiraLinha = TextEditingController();
  final TextEditingController _segundaLinha = TextEditingController();
  final TextEditingController _terceiraLinha = TextEditingController();
  final TextEditingController _quartaLinha = TextEditingController();
  final TextEditingController _dataUltimoTrat = TextEditingController();
  final TextEditingController _outroHospitaldiag = TextEditingController();
  final TextEditingController _outroHospitalTrat = TextEditingController();
  final TextEditingController _outroHospitalInicioTrat =
      TextEditingController();

  //DateTime? _selectedDateMetastase;
  //final TextEditingController _dateMetastaseController = TextEditingController();

  bool draftPronto = false;
  String? _sexoSelecionado; // Deixe o valor inicial como nulo
  String? _estadoSelecionado;

  String? _estadoSelecionado2;
  String? _estadiamento;
  String? _diagnosticoDetalhado;

  String? _cidadeDoObito;

  String? _cidadeProc;
  String? _diagnostico;
  String? _etniapacSelecionado;
  String? _especialidadepacSelecionado;
  String? _especialidadepacSelecionado2;

  String? _refratariedadepacSelecionado;
  String? _recaidapacSelecionado;
  String? _obito;
  String? _motivoObitoPac;

  List<String> _selectedTratamentos = [];

  String? _metastase;
  String? _vivo;
  String? _classificacaoMolecular;

  String? _nomeErro; // Defina a variável _nomeErro aqui
  //Trata o nome verificar se é igual
  final TextEditingController _dadosmolecular = TextEditingController();
  String? _localDiag;

  String? _localTrat;

  DateTime? _selectedDate; //Data de cálulo da idade
  DateTime? _selectedDatecampo; //Data de cálulo da idade
  DateTime? _selectedDate2; //Data da primeiro sintomas
  DateTime? _selectedDate3; //Data da primeira consulta
  DateTime? _selectedDate4; //Data do óbito
  DateTime? _selectedDate5; //Data de início do tratamento
  DateTime? _selectedDate6; //Data de diagnóstico
  DateTime? _selectedDate7; //Data do encaminhamento da oncologia pediátrica
  DateTime? _selectedDate9; //Data do último tratamento

  //final TextEditingController _localDiag = TextEditingController();
  final TextEditingController _dataPriSintomas = TextEditingController();
  final TextEditingController _dataPriConsulta = TextEditingController();
  final TextEditingController _datadoexame = TextEditingController();
  //final TextEditingController _localTrat = TextEditingController();
  final TextEditingController _dataInicioDoTrat = TextEditingController();
  String? _localInicioDoTrat;
  final TextEditingController _dataDoObito = TextEditingController();
  final TextEditingController _dataDoDiagnostico = TextEditingController();
  final TextEditingController _dataDoEncOncoPed = TextEditingController();
  String? sexoCod;
  // final TextEditingController _dataExameDiag = TextEditingController();
  //final TextEditingController _dateMetastase = TextEditingController();
  //final TextEditingController _estadoDoObito = TextEditingController();

  final List<String> _itemsexames = [
    'Anátomo-patológico',
    'Imunofeno/Histoquímica',
    'Citogenética',
    'Biologia Molecular',
    'Ressonância magnética nuclear (RNM)',
    'Tomografia',
    'Exame do fundo de olho (RBL)',
  ];

  List<String> _selectedItemsTempexames = [];

  List<String> _selectedItemsexames = [];

  static const Map<String, String> sexoMap = {
    'Masculino': '1',
    'Feminino': '2',
  };

  static const Map<String, String> kEtniaCodeMap = {
    'Branca': '1',
    'Preta': '2',
    'Parda': '3',
    'Amarela': '4',
    'Indígena': '5',
    'Não respondido/Ignorado': '9',
  };

  final List<String> _estadosBrasileiros = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
  ];

  String? _etniaCodigo; // [etnia]
  String? _localTratCodigo;
  String?
      _localDiagCodigo; // [local_de_tratamento]// [mudou_de_hospital_durante]
  String? _inicioTratamentoCodigo; // [inicio_tratamento]

  void conectarAutoSave(TextEditingController controller, String campo) {
    controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 800), () {
        salvarCampo(campo, controller.text);
      });
    });
  }

  void conectarAutoSaveDropdown(String campo, String? valor) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!draftPronto || recordId == null) return;
      salvarCampo(campo, valor ?? '');
    });
  }

  void _calculateAge() {
    if (_selectedDate != null) {
      final today = DateTime.now();
      final age = today.difference(_selectedDate!);

      if (age.inDays >= 365) {
        final years = age.inDays ~/ 365;
        setState(() {
          _idadeController.text = '$years anos';
        });
      } else if (age.inDays >= 30) {
        final months = age.inDays ~/ 30;
        setState(() {
          _idadeController.text = '$months meses';
        });
      } else {
        setState(() {
          _idadeController.text = '${age.inDays} dias';
        });
      }
    }
  }

  // Função para calcular a idade no diagnóstico
  // Usei como base a função acima de cálculo da idade
  //verificar se funciona corretamente
  String _idadeDiagnostico(
      DateTime dataNascimento, DateTime dataDoDiagnostico) {
    int anos = dataDoDiagnostico.year - dataNascimento.year;
    int meses = dataDoDiagnostico.month - dataNascimento.month;
    int dias = dataDoDiagnostico.day - dataNascimento.day;

    if (dias < 0) {
      meses -= 1;
      dias += DateTime(dataDoDiagnostico.year, dataDoDiagnostico.month, 0).day;
    }
    if (meses < 0) {
      anos -= 1;
      meses += 12;
    }

    if (anos > 0) {
      return '$anos ano${anos > 1 ? 's' : ''}';
    } else if (meses > 0) {
      return '$meses mês${meses > 1 ? 'es' : ''}';
    } else {
      return '$dias dia${dias > 1 ? 's' : ''}';
    }
  }

  Future<void> _selectDateNascComp(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDatecampo ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDatecampo) {
      if (_selectedDate != null && picked != _selectedDate) {
        // Mostra notificação de erro
        final snackBar = AnimatedSnackBar.material(
          'As datas de nascimento devem ser iguais!',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        );

        // Exibe o SnackBar
        snackBar.show(context);
      } else {
        // Se as datas forem iguais, salva a segunda data
        setState(() {
          _selectedDatecampo = picked;
          _dataNascimentoCompController.text =
              DateFormat('yyyy-MM-dd').format(_selectedDatecampo!);
          _calculateAge();
        });
      }
    }
  }

  Future<void> _selectDateNasc(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataNascimentoController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
        _calculateAge();
      });
    }
  }

  //datas
  Future<void> _selectDatePri(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: _selectedDate2 ?? DateTime.now(),
      firstDate: _selectedDate ?? DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked2 != null) {
      setState(() {
        _selectedDate2 = picked2;
        _dataPriSintomas.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate2!);
      });
      salvarCampo("dataPriSintomas", _dataPriSintomas.text);
    }
  }

  Future<void> _selectDateConsult(BuildContext context) async {
    final DateTime? picked3 = await showDatePicker(
      context: context,
      initialDate: _selectedDate3 ?? DateTime.now(),
      firstDate: _selectedDate2 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked3 != null) {
      setState(() {
        _selectedDate3 = picked3;
        _dataPriConsulta.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate3!);
      });
      // } else {
      //  AnimatedSnackBar.material(
      //    'A data da primeira consulta deve ser posterior à data dos primeiros sintomas.',
      //   type: AnimatedSnackBarType.warning,
      //  mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      //  desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      //  ).show(context);
      // }
    }
  }

  Future<void> selectdatedataUltimoTrat(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: _selectedDate9 ?? DateTime.now(),
      firstDate: _selectedDate5 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked2 != null) {
      // Verificar se a data selecionada é posterior à data de início do tratamento
      if (_selectedDate5 != null && picked2.isAfter(_selectedDate5!)) {
        setState(() {
          _selectedDate9 = picked2; // Atualiza a data do último tratamento
          _dataUltimoTrat.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate9!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do último tratamento deve ser posterior à data de início do tratamento.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  Future<void> selectdateInicioDoTrat(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: _selectedDate5 ?? DateTime.now(),
      firstDate: _selectedDate7 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked2 != null) {
      if (_selectedDate6 != null && picked2.isAfter(_selectedDate6!)) {
        setState(() {
          _selectedDate5 = picked2;
          _dataInicioDoTrat.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate5!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do início do tratamento deve ser posterior à data do diagnóstico.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  Future<void> _selectDateDiagnostico(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: _selectedDate6 ?? DateTime.now(),
      firstDate: _selectedDate3 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked2 != null) {
      setState(() {
        _selectedDate6 = picked2;
        _dataDoDiagnostico.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate6!);
        // _idadeDiagnostico(DateTime.parse(_dataNascimentoController.text),
        //     DateTime.parse(_dataDoDiagnostico.text));
        if (_dataNascimentoController.text.isNotEmpty) {
          try {
            final nascimento = DateTime.parse(_dataNascimentoController.text);
            final diagnostico = DateTime.parse(_dataDoDiagnostico.text);

            final idade = _idadeDiagnostico(nascimento, diagnostico);
            print('Idade no diagnóstico: $idade'); // <-- Apenas cálculo interno

            // Se quiser salvar no banco, pode fazer algo tipo:
            // paciente.idadeDiagnostico = idade;
          } catch (e) {
            print('Erro ao calcular idade: $e');
          }
        }
      });
    }
  }

  Future<void> _selectDateObito(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate4 ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      List<String> errorMessages = [];

      // Helper para parsear datas no formato yyyy-MM-dd (dos TextEditingController)
      DateTime? parseDate(String dateText) {
        if (dateText.isEmpty) return null;
        try {
          return DateFormat('yyyy-MM-dd').parse(dateText);
        } catch (_) {
          errorMessages
              .add('Formato de data inválido em "$dateText". Use yyyy-MM-dd.');
          return null;
        }
      }

      // Campos já preenchidos na tela
      final DateTime? dataPriConsulta = parseDate(_dataPriConsulta.text);
      final DateTime? dataInicioDoTrat = parseDate(_dataInicioDoTrat.text);
      final DateTime? dataDoDiagnostico = parseDate(_dataDoDiagnostico.text);
      final DateTime? dataNascimento =
          parseDate(_dataNascimentoController.text);
      final DateTime? dataUltimoTrat = parseDate(_dataUltimoTrat.text);
      final DateTime? dataRecaida =
          parseDate(_dataDaRecaida.text); // <— NOVO: data da recaída

      // Regras
      if (dataPriConsulta != null && !pickedDate.isAfter(dataPriConsulta)) {
        errorMessages.add(
            'A data do óbito deve ser posterior à data da primeira consulta.');
      }
      if (dataInicioDoTrat != null && !pickedDate.isAfter(dataInicioDoTrat)) {
        errorMessages.add(
            'A data do óbito deve ser posterior à data de início do tratamento.');
      }
      if (dataDoDiagnostico != null && !pickedDate.isAfter(dataDoDiagnostico)) {
        errorMessages
            .add('A data do óbito deve ser posterior à data do diagnóstico.');
      }
      if (dataNascimento != null && !pickedDate.isAfter(dataNascimento)) {
        errorMessages
            .add('A data do óbito deve ser posterior à data de nascimento.');
      }
      if (dataNascimento == null) {
        errorMessages
            .add('A data do óbito deve ser posterior à data de nascimento.');
      }
      if (dataUltimoTrat != null && !pickedDate.isAfter(dataUltimoTrat)) {
        errorMessages.add(
            'A data do óbito deve ser posterior à data do último tratamento.');
      }

      // NOVO: óbito deve ser posterior à recaída
      if (dataRecaida != null && !pickedDate.isAfter(dataRecaida)) {
        errorMessages
            .add('A data do óbito deve ser posterior à data da recaída.');
      }

      if (errorMessages.isEmpty) {
        setState(() {
          _selectedDate4 = pickedDate;
          _dataDoObito.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        });
        salvarCampo("dataDoObito", _dataDoObito.text);
      } else {
        AnimatedSnackBar.material(
          errorMessages.join('\n'),
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  void _selectDateRecaida(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // se já existe óbito, limita o último dia possível para a recaída ser antes do óbito
      lastDate: _selectedDate4 ?? DateTime.now(),
      firstDate: DateTime(1900),
    );

    if (picked != null) {
      List<String> errors = [];

      DateTime? parseDate(String s) {
        if (s.isEmpty) return null;
        try {
          return DateFormat('yyyy-MM-dd').parse(s);
        } catch (_) {
          errors.add('Formato de data inválido em "$s". Use yyyy-MM-dd.');
          return null;
        }
      }

      final DateTime? dataInicioTrat = parseDate(_dataInicioDoTrat.text);
      final DateTime? dataObito =
          _selectedDate4 ?? parseDate(_dataDoObito.text);

      // Recaída deve ser posterior ao início do tratamento
      if (dataInicioTrat != null && !picked.isAfter(dataInicioTrat)) {
        errors.add(
            'A data da recaída deve ser posterior à data de início do tratamento.');
      }

      // Se já há óbito, a recaída não pode ser depois do óbito
      if (dataObito != null && picked.isAfter(dataObito)) {
        errors.add('A data da recaída não pode ser posterior à data do óbito.');
      }

      if (errors.isEmpty) {
        setState(() {
          _dataDaRecaida.text = DateFormat('yyyy-MM-dd').format(picked);
          _selectedDate5 = picked;
        });
        salvarCampo("dataDaRecaida", _dataDaRecaida.text);
      } else {
        AnimatedSnackBar.material(
          errors.join('\n'),
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  Future<void> _selectDateDoEncOncoPed(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: _selectedDate7 ?? DateTime.now(),
      firstDate: _selectedDate3 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked2 != null) {
      if (_selectedDate3 != null && picked2.isAfter(_selectedDate3!)) {
        setState(() {
          _selectedDate7 = picked2;
          _dataDoEncOncoPed.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate7!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do encaminhamento para Oncologia Pediátrica deve ser posterior à data da primeira consulta.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  //'A data do diagnóstico de metástase não deve ser anterior a data do encaminhamento para oncologia pediátrica.',

  PlatformFile? _selectedPdfFile;
  PlatformFile? _selectedTcleFile;

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedPdfFile = result.files.first;
      });
    } else {
      // O usuário cancelou a seleção do arquivo
    }
  }

  Future<void> triggerSelecionarTcle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedTcleFile = result.files.single;
    });
    _mostrarMensagem(
      'TCLE selecionado: ${_selectedTcleFile!.name}. O arquivo será enviado ao REDCap ao salvar o cadastro.',
    );
  }

  Future<void> waitForFourSeconds() async {
    await Future.delayed(const Duration(seconds: 2));
    // 2segundos
    _limparCampos();
    PatientService(token!).fetchLastPatientRecordId().then((id) {
      setState(() {
        ultimoId = id;
      });
    });
    Navigator.of(context).pop();
  }

  void _limparCampos() {
    _nomeController.clear();
    _nomeComparacaoController.clear();
    _dataNascimentoController.clear();
    _dataNascimentoCompController.clear();
    _idadeController.clear();
    _cartaoSus.clear();
    _cpfPac.clear();
    //_localDiag.clear();
    //_localTrat.clear();
    _dataPriSintomas.clear();
    _dataPriConsulta.clear();

    _dataInicioDoTrat.clear();
    _dataDoDiagnostico.clear();

    //_examesUtilParaAcomp.clear();
    _dataDoEncOncoPed.clear();
    _dataDaRecaida.clear();
    _dataDoObito.clear();
    _nomeDoProtocolo.clear();
    _primeiraLinha.clear();
    _segundaLinha.clear();
    _terceiraLinha.clear();
    _quartaLinha.clear();
    //_dataExameDiag.clear();

    _diagnosticoDescritivo.clear();
    _localDoTumor.clear();
    _datadoexame.clear();
    _dataUltimoTrat.clear();
    _nomeDaMaeController.clear();

    setState(() {
      _sexoSelecionado = null; // Limpar seleção de sexo
      _etniapacSelecionado = null; // Limpar seleção de etnia
      _especialidadepacSelecionado = null;
      _especialidadepacSelecionado2 = null;
      _refratariedadepacSelecionado = null; // Limpar seleção de refratariedade
      _estadoSelecionado = null; // Limpar seleção de estado
      _estadoSelecionado2 = null;

      _diagnostico = null;
      _diagnosticoDetalhado = null;
      _vivo = null;
      _localDiag = null;
      _localTrat = null;

      _cidadeProc = null; // Limpar seleção de estado
      _recaidapacSelecionado = null;
      _obito = null;
      _selectedTratamentos.clear();
      /* _tipoTratamentoPac = null; */
      _motivoObitoPac = null;
      _selectedItemsexames = [];
      _metastase = null;
      _vivo = null;
      _classificacaoMolecular = null;
      _selectedItensTmo.clear();
      _outroTipoTmoController.clear();
      _selectedPdfFile = null;
      _selectedTcleFile = null;
    });
  }

  Future<void> _salvarELimparCampos() async {
    // Exibir indicador de carregamento
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Buscar o token do hospital selecionado
      String? token =
          await HospitalServicer().buscarTokenSmart(widget.hospitalselecionado);

      if (token == null) {
        Navigator.pop(context); // Fechar o diálogo
        _mostrarMensagem("Erro ao obter o token do hospital.");
        return;
      }

      String? ultimoId = await PatientService(token).fetchLastPatientRecordId();

      final String tipotmoFinal = [
        ..._selectedItensTmo.where((e) => e != 'Outros'),
        if (_selectedItensTmo.contains('Outros') &&
            _outroTipoTmoController.text.isNotEmpty)
          _outroTipoTmoController.text,
      ].join(', ');

      // verificar se o paciente já existe
      bool pacienteExiste =
          (await PatientService(token).verificarPacientePorId(ultimoId)) !=
              null;

      if (pacienteExiste) {
        Navigator.pop(context);
        _mostrarMensagem("Paciente já cadastrado!");
        return;
      }

      final tipoTratamentoFinal = _selectedTratamentos.join(', ');

      // Enviar registro para API
      await PatientService(token).enviarRegistroParaAPI(
        context,
        ultimoId: ultimoId,
        nomePaciente: _nomeController.text,
        dataNascimento: _dataNascimentoController.text,
        idadePaciente: _idadeController.text,
        sexoPaciente: sexoCod,
        etniaPaciente: _etniaCodigo,
        especialidadePaciente: _especialidadepacSelecionado,
        especialidadePaciente2: _especialidadepacSelecionado2,
        cpfPaciente: _cpfPac.text,
        cartaoSus: _cartaoSus.text,
        cidadeProc: _cidadeProc,
        estadoProc: _estadoSelecionado,
        estadoObito: _estadoSelecionado2,
        dataPriSintomas: _dataPriSintomas.text,
        dataPriConsulta: _dataPriConsulta.text,
        dataDoDiagnostico: _dataDoDiagnostico.text,
        dataDoEncOncoPed: _dataDoEncOncoPed.text,
        diagnostico: _diagnostico,
        diagnosticoDetalhado: _diagnosticoDetalhado,
        estadiamento: _estadiamento,
        diagnosticoDescritivo: _diagnosticoDescritivo.text,
        localDoTumor: _localDoTumor.text,
        examesDiagnosticoSelecionado: _selectedItemsexames,
        dataInicioDoTrat: _dataInicioDoTrat.text,
        localInicioDoTrat: _inicioTratamentoCodigo,
        /*  tipoTratamentoPac: _tipoTratamentoPac, */
        tipoTratamentoPac: tipoTratamentoFinal,
        vivo: _vivo,
        refratariedade: _refratariedadepacSelecionado,
        recaida: _recaidapacSelecionado,
        dataDaRecaida: _dataDaRecaida.text,
        obito: _obito,
        dataDoObito: _dataDoObito.text,
        motivoObitoPac: _motivoObitoPac,
        nomeDoProtocolo: _nomeDoProtocolo.text,
        primeiraLinha: _primeiraLinha.text,
        segundaLinha: _segundaLinha.text,
        terceiraLinha: _terceiraLinha.text,
        quartaLinha: _quartaLinha.text,
        classificacaoMolecular: _classificacaoMolecular,
        dadosMolecular: _dadosmolecular.text,
        dataAtualizacaoCadastro: dataatualizacaocad,
        nomeDaMae: _nomeDaMaeController.text,
        cidadedoobito: _cidadeDoObito,
        dataUltimoTrat: _dataUltimoTrat.text,
        selectedPdfFile: _selectedPdfFile,
        selectedTcleFile: _selectedTcleFile,
        metastase: _metastase,
        localDiag: _localDiagCodigo,
        localTrat: _localTratCodigo,
        outrohospitaldiag: _outroHospitaldiag.text,
        outrolocaltratamento: _outroHospitalTrat.text,
        /* outrolocaliniciotratamento: _outroHospitalInicioTrat.text, */
        outrolocaliniciotratamento: _outroHospitalInicioTrat.text,
        tipotmo: tipotmoFinal,
      );

      // successfully sent to REDCap; remove the firebase draft so it won't
      // clutter the collection or be reused accidentally.
      if (recordId != null) {
        await FirebaseFirestore.instance
            .collection('temporaryPatients')
            .doc(recordId)
            .delete();
        recordId = null;
      }

      // optionally clear the form fields as before
      _limparCampos();

      waitForFourSeconds();
    } catch (e) {
      Navigator.pop(context); // Fechar o diálogo em caso de erro
      _mostrarMensagem("Erro ao salvar os dados: $e");
    }
  }

  Future<void> triggerSalvarCadastro() async {
    await _salvarELimparCampos();
  }

  void triggerLimparCampos() {
    _limparCampos();
    _mostrarMensagem('Campos limpos.');
  }

  // Mostra snackbar genérica de mensagem de erro/sucesso no rodapé
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // feedback de progresso agora é mostrado no AppBar

  bool isValidCartaoSus(String s) {
    final regex1 = RegExp(r'^[1-2]\d{10}00[0-1]\d$');
    final regex2 = RegExp(r'^[7-9]\d{14}$');

    if (regex1.hasMatch(s) || regex2.hasMatch(s)) {
      return somaPonderada(s) % 11 == 0;
    }
    return false;
  }

  int somaPonderada(String s) {
    final cs = s.split('');
    int soma = 0;
    for (int i = 0; i < cs.length; i++) {
      soma += int.parse(cs[i]) * (15 - i);
    }
    return soma;
  }

  void _updateMunicipios(List<String> municipios) {
    setState(() {
      _municipios = municipios;
    });
  }

  List<String> _municipios = [];

  final Map<String, String> _hospitalCodes = {
    'HCPA - Hospital de Clínicas de Porto Alegre':
        '1', // Hospital de Clínica de Porto Alegre
    'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre':
        '2', // Santa Casa
    'GHC - Grupo Hospitalar Conceição': '3', // Nossa Senhora da Conceição
    'HSVP - Hospital São Vicente de Paulo': '4',
    'HGCS - Hospital Geral de Caxias do Sul': '5',
    'HUSM - Hospital Universitário de Santa Maria': '6',
    'Outro': '7',
  };

// mantém sua lista para o SimpleDialog
  final List<String> hospitals = [
    'HCPA - Hospital de Clínicas de Porto Alegre',
    'GHC - Grupo Hospitalar Conceição',
    'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre',
    'HSVP - Hospital São Vicente de Paulo',
    'HGCS - Hospital Geral de Caxias do Sul',
    'HUSM - Hospital Universitário de Santa Maria',
    'Outro'
  ];
  final List<String> treatmentTypes = [
    'Imunoterapia',
    'Cirurgia',
    'Radioterapia',
    'Quimioterapia',
    'Hormônio',
    'Transplante de medula óssea',
    'Nenhum tratamento realizado',
  ];
  void _selectHospital(String type) async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(type == 'diag'
              ? 'Selecione o hospital de diagnóstico'
              : 'Selecione o hospital do tratamento'),
          children: hospitals.map((String hospital) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, hospital);
              },
              child: Text(hospital),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (type == 'diag') {
          _localDiag = selected;
          _localDiagCodigo = _hospitalCodes[selected];
        } else {
          _localTrat = selected; // rótulo
          _localTratCodigo = _hospitalCodes[selected]; // código 1..7
        }
      });
      // autosave para rascunho
      if (type == 'diag') {
        salvarCampoDropdown("localDiag", selected);
      } else {
        salvarCampoDropdown("localTrat", selected);
      }
    }
  }

  void _selectHospital2() async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Selecione hospital de início do tratamento'),
          children: hospitals.map((String hospital) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, hospital);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(hospital,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _localInicioDoTrat = selected; // rótulo
        _inicioTratamentoCodigo = _hospitalCodes[selected]; // código 1..7
      });
      salvarCampoDropdown("localInicioDoTrat", selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
          padding: const EdgeInsets.all(20.0),
          child: AbsorbPointer(
              absorbing:
                  isLoading, // Impede interação enquanto isLoading for true
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: const Color.fromARGB(
                          255, 147, 196, 125), // Cor azul pastel
                      alignment: Alignment.center,
                      child: const Text(
                        'IDENTIFICAÇÃO',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isLoading)
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: 'ID: $ultimoId'),
                      //decoration: const InputDecoration(labelText: 'ID: '),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo: ',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 20),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'),
                      onChanged: (value) {
                        setState(() {
                          _nomeErro = null;
                          _nomeComparacaoController.text =
                              ''; // Limpa o campo de comparação ao alterar o nome
                        });
                      },
                      readOnly: false,
                      enableInteractiveSelection: false,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(fontSize: 20),
                      controller: _nomeComparacaoController,
                      decoration: InputDecoration(
                        labelText: 'Nome completo: ',
                        border: const OutlineInputBorder(),
                        labelStyle: const TextStyle(fontSize: 20),
                        errorText:
                            _nomeErro, // Mostra a mensagem de erro diretamente no campo
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo é de preenchimento obrigatório!';
                        }
                        if (value != _nomeController.text) {
                          return 'Os nomes não coincidem. Por favor, verifique.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _nomeErro = value != _nomeController.text
                              ? 'Os nomes não coincidem. Por favor, verifique.'
                              : null;
                        });
                      },
                      readOnly: false,
                      enableInteractiveSelection: false,
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDateNasc(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataNascimentoController,
                          decoration: const InputDecoration(
                            labelText: 'Data de nascimento: ',
                            labelStyle: TextStyle(fontSize: 20),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 20),
                          validator: Validatorless.required(
                              'Este campo é de preenchimento obrigatório!'), // Tornar obrigatório o preenchimento
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDateNascComp(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataNascimentoCompController,
                          decoration: const InputDecoration(
                            labelText: 'Data de nascimento: ',
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontSize: 20),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                          validator: Validatorless.required(
                              'Este campo é de preenchimento obrigatório!'), // Tornar obrigatório o preenchimento
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeDaMaeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo da Mãe: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _idadeController,
                      decoration: const InputDecoration(
                        labelText: 'Idade: ',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 20),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'), //Tornar obrigatório o preenchimento
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    // 'Masculino' ou 'Feminino'

                    DropdownButtonFormField<String>(
                      initialValue: _sexoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Sexo:',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (String? newValue) {
                        // trigger autosave for sexo dropdown
                        conectarAutoSaveDropdown("sexo", newValue);
                        setState(() {
                          _sexoSelecionado = newValue;
                        });
                      },
                      items: const ['Masculino', 'Feminino']
                          .map((v) => DropdownMenuItem<String>(
                              value: v, child: Text(v)))
                          .toList(),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _etniaCodigo,
                      decoration: const InputDecoration(
                        labelText: 'Etnia (codificada para REDCap):',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newCode) {
                        print("Etnia carregada: $_etniapacSelecionado");
                        print("Valores possíveis: ${kEtniaCodeMap.values}");
                        conectarAutoSaveDropdown("etnia", newCode);
                        setState(() {
                          _etniaCodigo = newCode; // salva o código (ex: '3')
                          _etniapacSelecionado = kEtniaCodeMap.keys.firstWhere(
                              (k) =>
                                  kEtniaCodeMap[k] ==
                                  newCode); // label só pra exibir se quiser
                        });
                      },
                      items: kEtniaCodeMap.entries
                          .map((e) => DropdownMenuItem<String>(
                                value: e.value, // código
                                child: Text(e.key), // label
                              ))
                          .toList(),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cpfPac,
                      decoration: const InputDecoration(
                        labelText: 'CPF: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      //validator: Validatorless.multiple([
                      //Validatorless.required(
                      ////      'Este campo é de preenchimento obrigatório!'),
                      //        Validatorless.cpf('Esse CPF não é valido')
                      //  ]), //Tornar obrigatório o preenchimento
                      inputFormatters: [maskcpf],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cartaoSus,
                      decoration: const InputDecoration(
                        labelText: 'Cartão SUS',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      //Tornar obrigatório o preenchimento
                      inputFormatters: [maskcartaosus],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado de procedência: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue1) {
                        // trigger autosave for estado dropdown
                        conectarAutoSaveDropdown("estado", newValue1);
                        setState(() {
                          _estadoSelecionado = newValue1!;
                          _municipios.clear();
                          // Clear the list of municipalities when a new state is selected
                          if (_estadoSelecionado != null) {
                            EstadoService().fetchMunicipios(
                                _estadoSelecionado, _updateMunicipios);

                            // Fetch municipalities for the selected state
                          }
                        });
                      },
                      items: _estadosBrasileiros
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'), //Tornar obrigatório o preenchimento
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: _cidadeProc ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Cidade de procedência: ',
                        labelStyle: TextStyle(fontSize: 20),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      validator: Validatorless.required(
                          'Este campo é de preenchimento obrigatório!'), //Tornar obrigatório o preenchimento
                      onTap: () {
                        _mostrarDialogoSelecaoMunicipio(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      color: const Color.fromARGB(
                          255, 109, 158, 235), // Cor azul pastel
                      alignment: Alignment.center,
                      child: const Text(
                        'INFORMAÇÕES DO ATENDIMENTO ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _selectHospital('diag'),
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText:
                                    'Hospital de diagnóstico: ${_localDiag ?? 'Selecione:'}',
                                labelStyle: const TextStyle(fontSize: 20),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                        ),
                        if (_localDiag == 'Outro')
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _outroHospitaldiag,
                              decoration: const InputDecoration(
                                labelText: 'Digite o hospital de diagnóstico: ',
                                labelStyle: TextStyle(fontSize: 20),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _selectHospital('trat'),
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText:
                                    'Hospital do tratamento: ${_localTrat ?? 'Selecione:'}',
                                labelStyle: const TextStyle(fontSize: 20),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                        ),
                        if (_localTrat == 'Outro')
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _outroHospitalTrat,
                              decoration: const InputDecoration(
                                labelText: 'Digite o hospital do tratamento: ',
                                labelStyle: TextStyle(fontSize: 20),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDatePri(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataPriSintomas,
                          decoration: const InputDecoration(
                            labelText: 'Data dos primeiros sintomas: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDateConsult(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataPriConsulta,
                          decoration: const InputDecoration(
                            labelText: 'Data da primeira consulta: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          //style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _especialidadepacSelecionado,
                      decoration: const InputDecoration(
                        labelText:
                            'Especialidade médica do primeiro encaminhamento:',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave especialidade do primeiro encaminhamento
                        conectarAutoSaveDropdown(
                            "especialidadePaciente", newValue);
                        setState(() {
                          _especialidadepacSelecionado = newValue!;
                        });
                      },
                      items: <String>[
                        'Alergia e Imunologia',
                        'Anestesiologia',
                        'Angiologia',
                        'Cardiologia',
                        'Clínica Médica',
                        'Dermatologia',
                        'Endocrinologia e Metabologia',
                        'Gastroenterologia',
                        'Genética Médica',
                        'Geriatria',
                        'Hematologia e Hemoterapia',
                        'Infectologia',
                        'Medicina de Família e Comunidade',
                        'Medicina de Emergência',
                        'Medicina Esportiva',
                        'Medicina Física e Reabilitação',
                        'Medicina Intensiva',
                        'Medicina Legal e Perícia Médica',
                        'Medicina Nuclear',
                        'Medicina Preventiva e Social',
                        'Nefrologia',
                        'Neurologia',
                        'Nutrologia',
                        'Oncologia Clínica',
                        'Pneumologia',
                        'Psiquiatria',
                        'Radiologia e Diagnóstico por Imagem',
                        'Radioterapia',
                        'Reumatologia',
                        'Cirurgia Cardiovascular',
                        'Cirurgia da Mão',
                        'Cirurgia de Cabeça e Pescoço',
                        'Cirurgia do Aparelho Digestivo',
                        'Cirurgia Geral',
                        'Cirurgia Pediátrica',
                        'Cirurgia Plástica',
                        'Cirurgia Torácica',
                        'Cirurgia Vascular',
                        'Coloproctologia',
                        'Neurocirurgia',
                        'Ortopedia e Traumatologia',
                        'Urologia',
                        'Ginecologia e Obstetrícia',
                        'Mastologia',
                        'Pediatria',
                        'Oftalmologia',
                        'Otorrinolaringologia',
                        'Patologia',
                        'Patologia Clínica/Medicina Laboratorial',
                        'Homeopatia',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: Validatorless.required(
                        'Este campo é de preenchimento obrigatório!',
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDateDoEncOncoPed(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataDoEncOncoPed,
                          decoration: const InputDecoration(
                            labelText:
                                'Data do encaminhamento para Oncologista Pediatrica: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDateDiagnostico(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataDoDiagnostico,
                          decoration: const InputDecoration(
                            labelText: 'Data do Diagnóstico: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      color:
                          const Color.fromARGB(255, 255, 153, 0), // Cor laranja
                      alignment: Alignment.center,
                      child: const Text(
                        'DADOS DO DIAGNÓSTICO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: _diagnostico ?? ""),
                      decoration: InputDecoration(
                        labelText: 'Diagnóstico da Doença: ',
                        labelStyle: const TextStyle(fontSize: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ajusta o tamanho da linha para o conteúdo mínimo necessário
                          children: [
                            const Icon(Icons.arrow_drop_down),
                            IconButton(
                              icon: const Icon(Icons.info,
                                  color: Colors.black), // Ícone de informação
                              iconSize: 18.0,
                              onPressed: () {
                                _mostrarInformacoes(
                                    context,
                                    'Nome da doença diagnosticada',
                                    'Exemplificando: Linfoma de Hodking, hepatoblastoma, Leucemia mielóide aguda, etc...');
                              },
                            ),
                          ],
                        ),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onTap: () {
                        _mostrarDialogoSelecaoNeoplasia(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _diagnostico != null && _diagnostico!.isNotEmpty,
                      child: Column(
                        children: [
                          Visibility(
                            visible: _temClassificacao(_diagnostico),
                            child: Column(
                              children: [
                                TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: _diagnosticoDetalhado ?? ""),
                                  decoration: const InputDecoration(
                                    labelText: 'Classificação: ',
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    border: OutlineInputBorder(),
                                    labelStyle: TextStyle(fontSize: 20),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 20),
                                  onTap: () {
                                    _mostrarDialogoSelecaoClassificacao(
                                        context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _temestadiamento(_diagnostico),
                            child: Column(
                              children: [
                                TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: _estadiamento ?? ""),
                                  decoration: const InputDecoration(
                                    labelText: 'Estadiamento: ',
                                    labelStyle: TextStyle(fontSize: 20),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 20),
                                  onTap: () {
                                    _mostrarDialogoSelecaoEstadiamento(context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _diagnosticoDescritivo,
                      decoration: InputDecoration(
                        labelText: 'Diagnóstico descritivo: ',
                        labelStyle: const TextStyle(fontSize: 20),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.black), // Ícone de informação
                          iconSize: 18.0,
                          onPressed: () {
                            _mostrarInformacoes(
                                context,
                                'Informações sobre Diagnóstico Descritivo',
                                'O diagnóstico descritivo é uma descrição detalhada dos sinais, sintomas e condições observadas que ajudam a entender melhor a condição do paciente. Use este campo para registrar qualquer observação clínica relevante que possa complementar o diagnóstico principal.');
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _localDoTumor,
                      decoration: InputDecoration(
                        labelText: 'Local do tumor: ',
                        labelStyle: const TextStyle(fontSize: 20),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.black), // Ícone de informação
                          iconSize: 18.0,
                          onPressed: () {
                            _mostrarInformacoes(
                                context,
                                'Informações sobre o local do tumor',
                                'O "local do tumor" é a região anatômica específica da neoplasia, essencial para diagnóstico, estadiamento e tratamento, podendo ser descrito de diversas formas conforme o contexto clínico.');
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _metastase,
                      decoration: InputDecoration(
                        labelText: 'Metástase: ',
                        labelStyle: const TextStyle(fontSize: 20),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.black), // Ícone de informação
                          iconSize: 18.0,
                          onPressed: () {
                            _mostrarInformacoes(
                                context,
                                'Informações sobre Metástase',
                                'Metástase é a propagação de células cancerosas de um órgão ou tecido para outra parte do corpo. Neste campo, você deve selecionar se a condição do paciente é metastática, não metastática, ou se a informação não se aplica.');
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave metastase
                        conectarAutoSaveDropdown("metastase", newValue);
                        setState(() {
                          _metastase = newValue!;
                        });
                      },
                      items: <String>[
                        'Metastático',
                        'Não metastático',
                        'não se aplica',
                        ''
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showExamesdiag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedItemsexames.isEmpty
                                    ? 'Exames do diagnóstico'
                                    : _selectedItemsexames.join(', '),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            const Icon(Icons
                                .arrow_drop_down), // Ícone da seta de seleção
                            IconButton(
                              icon: const Icon(Icons.info,
                                  color: Colors.black), // Ícone de informação
                              iconSize: 18.0,
                              onPressed: () {
                                _mostrarInformacoes(
                                    context,
                                    'Informações sobre Exames do Diagnóstico',
                                    'Os exames de diagnóstico são procedimentos realizados para identificar ou avaliar uma doença ou condição. Selecionar os exames corretos pode ajudar a confirmar ou descartar um diagnóstico.');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _classificacaoMolecular,
                      decoration: InputDecoration(
                        labelText: 'Classificação molecular: ',
                        labelStyle: const TextStyle(fontSize: 20),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal:
                                10), // Ajuste o padding interno para aumentar a altura
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.black), // Ícone de informação
                          iconSize: 18.0,
                          onPressed: () {
                            _mostrarInformacoes(
                              context,
                              'Informações sobre Classificação Molecular',
                              'A Classificação Molecular envolve a análise de marcadores genéticos e moleculares específicos para determinar o subtipo de uma doença, como o câncer. Esta classificação pode ajudar na escolha do tratamento mais adequado.',
                            );
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave classificacao molecular
                        conectarAutoSaveDropdown(
                            "classificacaoMolecular", newValue);
                        setState(() {
                          _classificacaoMolecular = newValue;
                          if (newValue != 'Sim') {
                            // clear details if user deselects
                            _dadosmolecular.clear();
                            salvarCampo("dadosMolecular", "");
                          }
                        });
                      },
                      items: <String>['Sim', 'Não']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _classificacaoMolecular == 'Sim',
                      child: Column(
                        children: [
                          // Ajuste de altura do TextFormField
                          SizedBox(
                            height: 100, // Ajuste a altura conforme necessário
                            child: TextFormField(
                              controller: _dadosmolecular,
                              decoration: InputDecoration(
                                labelStyle: const TextStyle(fontSize: 20),
                                labelText: 'Dados da classificação molecular: ',
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 10,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.info,
                                      color: Colors.black),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Informações'),
                                          content: const Text(
                                            'Aqui o usuário deve descrever os subtipos de tumores com base em características genéticas.',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Fechar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              style: const TextStyle(
                                  fontSize: 20), // ✅ Aqui está a correção
                            ),
                          ),
                        ],
                      ),
                    ),
                    //const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _especialidadepacSelecionado2,
                      decoration: const InputDecoration(
                        labelText:
                            'Especialidade médica do segundo encaminhamento:',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave especialidade do segundo encaminhamento
                        conectarAutoSaveDropdown(
                            "especialidadePaciente2", newValue);
                        setState(() {
                          _especialidadepacSelecionado2 = newValue!;
                        });
                      },
                      items: <String>[
                        'Alergia e Imunologia',
                        'Anestesiologia',
                        'Angiologia',
                        'Cardiologia',
                        'Clínica Médica',
                        'Dermatologia',
                        'Endocrinologia e Metabologia',
                        'Gastroenterologia',
                        'Genética Médica',
                        'Geriatria',
                        'Hematologia e Hemoterapia',
                        'Infectologia',
                        'Medicina de Família e Comunidade',
                        'Medicina de Emergência',
                        'Medicina Esportiva',
                        'Medicina Física e Reabilitação',
                        'Medicina Intensiva',
                        'Medicina Legal e Perícia Médica',
                        'Medicina Nuclear',
                        'Medicina Preventiva e Social',
                        'Nefrologia',
                        'Neurologia',
                        'Nutrologia',
                        'Oncologia Clínica',
                        'Pneumologia',
                        'Psiquiatria',
                        'Radiologia e Diagnóstico por Imagem',
                        'Radioterapia',
                        'Reumatologia',
                        'Cirurgia Cardiovascular',
                        'Cirurgia da Mão',
                        'Cirurgia de Cabeça e Pescoço',
                        'Cirurgia do Aparelho Digestivo',
                        'Cirurgia Geral',
                        'Cirurgia Pediátrica',
                        'Cirurgia Plástica',
                        'Cirurgia Torácica',
                        'Cirurgia Vascular',
                        'Coloproctologia',
                        'Neurocirurgia',
                        'Ortopedia e Traumatologia',
                        'Urologia',
                        'Ginecologia e Obstetrícia',
                        'Mastologia',
                        'Pediatria',
                        'Oftalmologia',
                        'Otorrinolaringologia',
                        'Patologia',
                        'Patologia Clínica/Medicina Laboratorial',
                        'Homeopatia',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: Validatorless.required(
                        'Este campo é de preenchimento obrigatório!',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: _pickPdfFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFFFCC80), // Cor de fundo laranja pastel
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  3.0), // Bordas arredondadas
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ), // Ajuste do tamanho do botão
                          ),
                          child: const Text(
                            'Selecionar arquivo de exames',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Espaço entre o botão e o ícone
                        IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.black54), // Ícone de informação
                          iconSize: 20.0, // Tamanho do ícone ajustado
                          onPressed: () {
                            _mostrarInformacoes(
                              context,
                              'Informações sobre o campo de Exames',
                              'Este botão permite selecionar um arquivo PDF de exames para ser anexado ao registro. Certifique-se de escolher o arquivo correto que corresponde ao exame do paciente.',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    _selectedPdfFile != null
                        ? Text('Arquivo selecionado: ${_selectedPdfFile!.name}')
                        : const Text('Nenhum arquivo selecionado'),
                    const SizedBox(height: 20),
                    Container(
                      color: const Color.fromARGB(
                        255,
                        241,
                        194,
                        50,
                      ), // Pastel
                      alignment: Alignment.center,
                      child: const Text(
                        'DADOS DO TRATAMENTO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => selectdateInicioDoTrat(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataInicioDoTrat,
                          decoration: const InputDecoration(
                            labelText: 'Data de início do tratamento: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _selectHospital2(),
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText:
                                    'Hospital de início do tratamento: ${_localInicioDoTrat ?? 'Selecione'}',
                                labelStyle: const TextStyle(fontSize: 20),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                        ),
                        if (_localInicioDoTrat == 'Outro')
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _outroHospitalInicioTrat,
                              decoration: const InputDecoration(
                                labelText:
                                    'Digite o hospital de início do tratamento: ',
                                labelStyle: TextStyle(fontSize: 20),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!',
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    GestureDetector(
                      onTap: _selectTipodetartamento,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText:
                                'Tipo de tratamento do paciente: ${_selectedTratamentos.isEmpty ? 'Selecione:' : _selectedTratamentos.join(', ')}',
                            labelStyle: const TextStyle(fontSize: 20),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                          validator: Validatorless.required(
                            'Este campo é de preenchimento obrigatório!',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

// ===== CAMPO TMO =====
                    Visibility(
                      visible: _selectedTratamentos
                          .any((t) => t.contains('Transplante')),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// botão abrir dialog
                          GestureDetector(
                            onTap: _showTiposTmoDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedItensTmo.isEmpty
                                          ? 'Tipos de TMO'
                                          : _selectedItensTmo.join(', '),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),

                          /// espaço
                          const SizedBox(height: 20),

                          /// campo OUTROS
                          if (_selectedItensTmo.contains('Outros')) ...[
                            TextFormField(
                              controller: _outroTipoTmoController,
                              decoration: const InputDecoration(
                                labelText: 'Especifique o tipo de TMO:',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            //const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nomeDoProtocolo,
                      decoration: const InputDecoration(
                        labelText: 'Nome do protocolo: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _primeiraLinha,
                      decoration: const InputDecoration(
                        labelText: 'Primeira linha: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _segundaLinha,
                      decoration: const InputDecoration(
                        labelText: 'Segunda linha: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _terceiraLinha,
                      decoration: const InputDecoration(
                        labelText: 'Terceira linha: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _quartaLinha,
                      decoration: const InputDecoration(
                        labelText: 'Quarta linha: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => selectdatedataUltimoTrat(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dataUltimoTrat,
                          decoration: const InputDecoration(
                            labelText: 'Data do último tratamento: ',
                            labelStyle: TextStyle(fontSize: 20),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      color: const Color.fromARGB(255, 213, 166, 189), // Rosa
                      alignment: Alignment.center,
                      child: const Text(
                        'DADOS DE ACOMPANHAMENTO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _vivo,
                      decoration: const InputDecoration(
                        labelText: 'Vivo? ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave vivo
                        conectarAutoSaveDropdown("vivo", newValue);
                        setState(() {
                          _vivo = newValue!;
                          // Define "Óbito" automaticamente com base em "Vivo?"
                          _obito = newValue == 'Sim' ? 'Não' : 'Sim';
                        });
                      },
                      items: <String>[
                        'Sim',
                        'Não',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _refratariedadepacSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Refratariedade: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave refratariedade
                        conectarAutoSaveDropdown("refratariedade", newValue);
                        setState(() {
                          _refratariedadepacSelecionado = newValue!;
                        });
                      },
                      items: <String>[
                        'Sim',
                        'Não',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _recaidapacSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Recaída: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave recaida
                        conectarAutoSaveDropdown("recaida", newValue);
                        setState(() {
                          _recaidapacSelecionado = newValue!;
                        });
                      },
                      items: <String>[
                        'Sim',
                        'Não',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _recaidapacSelecionado == 'Sim',
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _selectDateRecaida(context),
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _dataDaRecaida,
                                decoration: const InputDecoration(
                                  labelText: 'Data da recaída: ',
                                  labelStyle: TextStyle(fontSize: 20),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _obito,
                      decoration: const InputDecoration(
                        labelText: 'Óbito: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        // autosave obito
                        conectarAutoSaveDropdown("obito", newValue);
                        setState(() {
                          _obito = newValue!;
                          // Define "Vivo?" automaticamente com base em "Óbito"
                          _vivo = newValue == 'Sim' ? 'Não' : 'Sim';
                        });
                      },
                      items: <String>['Sim', 'Não', '']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Visibility(
                      visible: _obito == 'Sim',
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () => _selectDateObito(context),
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _dataDoObito,
                                decoration: const InputDecoration(
                                  labelText: 'Data do Óbito: ',
                                  labelStyle: TextStyle(fontSize: 20),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            initialValue: _estadoSelecionado2,
                            decoration: const InputDecoration(
                              labelText:
                                  'UF(Unidade de Federação) de falecimento: ',
                              labelStyle: TextStyle(fontSize: 20),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 20),
                            onChanged: (String? newValue1) {
                              // autosave estado de obito
                              conectarAutoSaveDropdown(
                                  "estadoObito", newValue1);
                              setState(() {
                                _estadoSelecionado2 = newValue1!;
                                _municipios.clear();
                                // Clear the list of municipalities when a new state is selected
                                if (_estadoSelecionado2 != null) {
                                  EstadoService().fetchMunicipios(
                                      _estadoSelecionado2, _updateMunicipios);

                                  // Fetch municipalities for the selected state
                                }
                              });
                            },
                            items: _estadosBrasileiros
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!'), //Tornar obrigatório o preenchimento
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: _cidadeDoObito ?? ''),
                            decoration: const InputDecoration(
                              labelText: 'Cidade de falecimento: ',
                              labelStyle: TextStyle(fontSize: 20),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 20),
                            validator: Validatorless.required(
                                'Este campo é de preenchimento obrigatório!'), // Tornar obrigatório o preenchimento
                            onTap: () {
                              _mostrarDialogoSelecaoCidadeobito(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            initialValue: _motivoObitoPac,
                            decoration: const InputDecoration(
                              labelText: 'Motivo do óbito: ',
                              labelStyle: TextStyle(fontSize: 20),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 20),
                            onChanged: (String? newValue) {
                              // autosave motivo do obito
                              conectarAutoSaveDropdown("motivoObito", newValue);
                              setState(() {
                                _motivoObitoPac = newValue!;
                              });
                            },
                            items: <String>[
                              'Progressão do tumor',
                              'Toxicidade terapêutica grave',
                              'Sepse',
                              'Outros',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ))),
    ]);
  }

  void _mostrarDialogoSelecaoMunicipio(BuildContext context) {
    Future<List<String>> filtercidades(String filter) async {
      if (filter.isEmpty) {
        return _municipios;
      }
      return _municipios
          .where((municipios) =>
              municipios.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
                'Selecione a cidade de procedência - Escolha o estado de procedência primeiro.'),
            content: DropdownSearch<String>(
              asyncItems: (String filter) => filtercidades(filter),
              selectedItem: _cidadeProc,
              onChanged: (String? newValue) {
                setState(() {
                  _cidadeProc = newValue;
                });
                // save the selected city for procedência
                salvarCampoDropdown("cidade", newValue ?? '');
                Navigator.pop(context);
              },
              //Aqui
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  icon: Icon(Icons.arrow_downward),
                  labelText: 'Selecione',
                  //  border: OutlineInputBorder(),
                ),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                  ),
                ),
              ),
              clearButtonProps: const ClearButtonProps(
                isVisible: true,
              ),
            ),
          );
        });
  }

  void _mostrarDialogoSelecaoCidadeobito(BuildContext context) {
    Future<List<String>> filtercidades(String filter) async {
      if (filter.isEmpty) {
        return _municipios;
      }
      return _municipios
          .where((municipios) =>
              municipios.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecione a Cidade de falecimento:'),
            content: DropdownSearch<String>(
              asyncItems: (String filter) => filtercidades(filter),
              selectedItem: _cidadeDoObito,
              onChanged: (String? newValue) {
                setState(() {
                  _cidadeDoObito = newValue;
                });
                // save the selected city of death (cidade do óbito)
                salvarCampoDropdown("cidadeDoObito", newValue ?? '');
                Navigator.pop(context);
              },
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  icon: Icon(Icons.arrow_downward),
                  labelText: 'Selecione',
                  //  border: OutlineInputBorder(),
                ),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                  ),
                ),
              ),
              clearButtonProps: const ClearButtonProps(
                isVisible: true,
              ),
            ),
          );
        });
  }

  void _mostrarDialogoSelecaoNeoplasia(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione o diagnóstico'),
          content: DropdownSearch<String>(
            items: _neoplasias.map((n) => n.diagnostico).toList(),
            selectedItem: _diagnostico,
            onChanged: (String? newValue) {
              setState(() {
                _diagnostico = newValue;
                _diagnosticoDetalhado = null;
                _estadiamento =
                    null; // Resetar a classificação ao mudar o diagnóstico
              });
              // salvar diagnóstico selecionado
              salvarCampoDropdown("diagnostico", newValue ?? '');
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione: ',
                // border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                ),
              ),
            ),
            clearButtonProps: const ClearButtonProps(
              isVisible: true,
            ),
          ),
        );
      },
    );
  }

  bool _temClassificacao(String? diagnostico) {
    var neoplasiaSelecionada = _neoplasias.firstWhere(
        (n) => n.diagnostico == diagnostico,
        orElse: () =>
            Neoplasia(diagnostico: '', classificacao: '', estadiamento: ''));
    return neoplasiaSelecionada.classificacao.isNotEmpty;
  }

  void _mostrarDialogoSelecaoClassificacao(BuildContext context) {
    var neoplasiaSelecionada =
        _neoplasias.firstWhere((n) => n.diagnostico == _diagnostico);
    var classificacoes = neoplasiaSelecionada.classificacao
        .split(',')
        .map((e) => e.trim())
        .toList();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a classificação'),
          content: DropdownSearch<String>(
            items: classificacoes,
            selectedItem: _diagnosticoDetalhado,
            onChanged: (String? newValue) {
              setState(() {
                _diagnosticoDetalhado = newValue;
              });
              // salvar classificacao detalhada
              salvarCampoDropdown("diagnosticoDetalhado", newValue ?? '');
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione: ',
                // border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                ),
              ),
            ),
            clearButtonProps: const ClearButtonProps(
              isVisible: true,
            ),
          ),
        );
      },
    );
  }

  bool _temestadiamento(String? diagnostico) {
    var neoplasiaSelecionada = _neoplasias.firstWhere(
        (n) => n.diagnostico == diagnostico,
        orElse: () =>
            Neoplasia(diagnostico: '', classificacao: '', estadiamento: ''));
    return neoplasiaSelecionada.estadiamento.isNotEmpty;
  }

  void _mostrarDialogoSelecaoEstadiamento(BuildContext context) {
    var neoplasiaSelecionada =
        _neoplasias.firstWhere((n) => n.diagnostico == _diagnostico);
    var estadiamento = neoplasiaSelecionada.estadiamento
        .split(',')
        .map((e) => e.trim())
        .toList();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione o estadiamento'),
          content: DropdownSearch<String>(
            items: estadiamento,
            selectedItem: _estadiamento,
            onChanged: (String? newValue) {
              setState(() {
                _estadiamento = newValue;
              });
              // salvar estadiamento
              salvarCampoDropdown("estadiamento", newValue ?? '');
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione: ',
                // border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                ),
              ),
            ),
            clearButtonProps: const ClearButtonProps(
              isVisible: true,
            ),
          ),
        );
      },
    );
  }

  void _showExamesdiag() async {
    _selectedItemsTempexames = List.from(_selectedItemsexames);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione os exames: '),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _itemsexames.map((item) {
                    return CheckboxListTile(
                      title: Text(item),
                      value: _selectedItemsTempexames.contains(item),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedItemsTempexames.add(item);
                          } else {
                            _selectedItemsTempexames.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Aplicar'),
                  onPressed: () {
                    setState(() {
                      _selectedItemsexames =
                          List.from(_selectedItemsTempexames);
                    });
                    // salvar exames selecionados (salva como string separada por vírgula)
                    salvarCampoDropdown("examesDiagnosticoSelecionado",
                        _selectedItemsexames.join(', '));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {}); // Atualiza o estado do widget pai para refletir a seleção
    print(_selectedItemsexames);
  }
}

void _mostrarInformacoes(BuildContext context, String titulo, String conteudo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo,
            style: const TextStyle(fontSize: 24)), // Título com fonte maior
        content: Text(
          conteudo,
          style: const TextStyle(fontSize: 18), // Fonte maior para o conteúdo
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK',
                style: TextStyle(fontSize: 16)), // Botão com fonte maior
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o AlertDialog
            },
          ),
        ],
      );
    },
  );
}
