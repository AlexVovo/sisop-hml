import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:regsitroweb/service/patient_service.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:validatorless/validatorless.dart';

import '../../model/neoplasias_model.dart';
import '../../model/patient_model.dart';
import '../../service/neoplasias_service.dart';

class WidgetUpdatePacienteForm extends StatefulWidget {
  final Patient patient;
  final String? token;

  WidgetUpdatePacienteForm(
      {super.key, required this.patient, required this.token});

  @override
  WidgetUpdatePacienteFormState createState() =>
      WidgetUpdatePacienteFormState();
}

class WidgetUpdatePacienteFormState extends State<WidgetUpdatePacienteForm> {
  List<String> _selectedTratamentos = [];

  final List<String> _tiposTratamento = [
    'Imunoterapia',
    'Cirurgia',
    'Radioterapia',
    'Quimioterapia',
    'Hormônio',
    'Transplante de medula óssea',
    'Outras combinações de tratamento',
    'Nenhum tratamento realizado',
  ];

  void _showTiposTratamentoDialog() async {
    List<String> temp = List.from(_selectedTratamentos);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tipos de tratamento'),
              content: SingleChildScrollView(
                child: Column(
                  children: _tiposTratamento.map((t) {
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
                    });
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

  // ===== TMO (Update) =====
  List<String> _selectedItensTmo = [];
  final TextEditingController _outroTipoTmoController = TextEditingController();

  final List<String> _tiposTmo = [
    'Transplante autólogo (do próprio paciente)',
    'Transplante alogênico aparentado (doador familiar compatível)',
    'Transplante alogênico não aparentado (doador não familiar)',
    'Transplante haploidêntico (pais ou familiares parcialmente compatíveis)',
    'Outros',
  ];

  String? email = AuthenticationService(FirebaseAuth.instance).getName();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nomeDaMaeController = TextEditingController();
  TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _dataDaRecaida = TextEditingController();

  TextEditingController _idadeController = TextEditingController();
  final TextEditingController _cpfPac = TextEditingController();
  final TextEditingController _cartaoSus = TextEditingController();

  var maskcpf = MaskTextInputFormatter(mask: '###.###.###-##');
  var maskcartaosus = MaskTextInputFormatter(mask: '###############');
  List<Neoplasia> _neoplasias = [];
  List<Neoplasia> _neoplasias2 = [];
  final TextEditingController _nomeDoProtocolo = TextEditingController();
  final TextEditingController _primeira_linha = TextEditingController();
  final TextEditingController _segunda_linha = TextEditingController();
  final TextEditingController _terceira_linha = TextEditingController();
  final TextEditingController _quarta_linha = TextEditingController();

  //final TextEditingController _examesDiagnostico = TextEditingController();
  final TextEditingController _diagnosticoDescritivo = TextEditingController();
  final TextEditingController _dataUltimoTrat = TextEditingController();
  // final TextEditingController _controllerDiagnosticoDetalhado2 =TextEditingController();

  String? _sexoSelecionado; // Deixe o valor inicial como nulo
  String? _estadoSelecionado;
  String? _estadoSelecionado2;

  String? _diagnostico;
  String? _estadiamento;
  String? _diagnosticoDetalhado;
  String? _novoDiagnostico;
  String? _houvenovodiagnostico;

  String? _estadiamento2;
  String? _diagnosticoDetalhado2;

  String? _cidadeProc;

  String? _etniapacSelecionado;
  String? _especialidadepacSelecionado;
  String? _especialidadepacSelecionado2;
  String? _refratariedadepacSelecionado;
  String? _recaidapacSelecionado;
  String? _obito;
  String? _motivoObitoPac;
  String? _tipoTratamentoPac;
  String? _metastase;
  String? _vivo;

  String? _cidadeDoObito;

  DateTime? _selectedDate; //Data de cálulo da idade
  DateTime? _selectedDate2; //Data da primeiro sintomas
  DateTime? _selectedDate3; //Data da primeira consulta
  DateTime? _selectedDate4; //Data do óbito
  DateTime? _selectedDate5; //Data de início do tratamento
  DateTime? _selectedDate6; //Data de diagnóstico
  DateTime? _selectedDate7; //Data do encaminhamento a oncologia pediatrica
  DateTime? _selectedDatecampo;
  DateTime? _selectedDate9; //Data do último tratamento
//Comparar data de nascimento
  //Data do encaminhamento da oncologia pediátrica
  //DateTime? _selectedDate8; //Aguardando......
  String? _localDiag;
  final TextEditingController _outroHospitaldiag = TextEditingController();
  TextEditingController _dataPriSintomas = TextEditingController();
  final TextEditingController _dataPriConsulta = TextEditingController();

  String? _localTrat;
  final TextEditingController _outroHospitalTrat = TextEditingController();
  final TextEditingController _dataInicioDoTrat = TextEditingController();
  String? _localInicioDoTrat;
  final TextEditingController _outroHospitalInicioTrat =
      TextEditingController();
  final TextEditingController _dataDoObito = TextEditingController();
  final TextEditingController _dataDoDiagnostico = TextEditingController();
  final TextEditingController _dataDoEncOncoPed = TextEditingController();
  final TextEditingController _dataNascimentoCompController =
      TextEditingController();
  String? _classificacaoMolecular;
  final TextEditingController _dadosmolecular = TextEditingController();
  final TextEditingController _localDoTumor = TextEditingController();

  bool _localDiagEnabled = true;
  bool _localTratEnabled = true;
  bool _localInicioTratEnabled = true;
  bool _isSexoEnabled = true;
  bool _isEtiniaEnabled = true;
  bool _isEspecialidadeEnabled = true;
  bool _isEspecialidade2Enabled = true;
  bool _isEstadoEnabled = true;
  bool _isCidadeEnabled = true;
  bool _isDataPriSintomasEnabled = true;
  bool _isDataPriConsultaEnabled = true;
  bool _isDataEncaOncoEnabled = true;

  bool _isDataDiagnosticoEnabled = true;
  bool _isDiagnosticodetalhadoEnabled = true;
  bool _isestadimentoenabled = true;
  bool _isMetastaseEnable = true;
  bool _isClassificacaomolecularEnable = true;
  bool _isDatainiciodotratEnable = true;
  bool _isTipotratamentopacEnable = true;
  bool _isDataultimotratEnable = true;

  DateTime? dataatualizacaocad = DateTime.now();
  late List<String> _selectedItemsTempexames = [];

  late List<String> _selectedItemsexames = [];
  final List<String> _itemsexames = [
    'Anátomo-patológico',
    'Imunofeno/Histoquímica',
    'Citogenética',
    'Biologia molecular',
    'Ressonância magnética nuclear (RNM)',
    'Tomografia',
    'Exame do fundo de olho (RBL)',
  ];
  final List<String> _estadosBrasileiros = [
    '',
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
// Sexo (REDCap: 1=Masculino, 2=Feminino)
  static const Map<String, String> kSexoMap = {
    'Masculino': '1',
    'Feminino': '2',
  };

// Etnia (ajuste os rótulos conforme seu REDCap; mapeei as variantes mais comuns)
  static const Map<String, String> kEtniaMap = {
    'Branco': '1', 'Branca': '1',
    'Preto': '2', 'Preta': '2',
    'Pardo': '3',
    'Amarelo': '4',
    'Indígena': '5',
    'Não sabe': '9', 'Não respondido/Ignorado': '9',
    'Outros': '8',
    '': '', // vazio permanece vazio
  };

// Hospitais -> códigos (mesmos códigos do cadastro)
  static const Map<String, String> kHospitalCodes = {
    'HCPA - Hospital de Clínicas de Porto Alegre': '1',
    'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre':
        '2',
    'GHC - Grupo Hospitalar Conceição': '3',
    'HSVP - Hospital São Vicente de Paulo': '4',
    'HGCS - Hospital Geral de Caxias do Sul': '5',
    'HUSM - Hospital Universitário de Santa Maria': '6',
    'Outro': '7',
    '': '',
  };

  String labelFromCode(Map<String, String> labelToCode, String? code,
      {String empty = ''}) {
    if (code == null) return empty;
    for (final e in labelToCode.entries) {
      if (e.value == code) return e.key;
    }
    return empty;
  }

  String labelFromEtniaCode(String? code) {
    switch (code) {
      case '1':
        return 'Branco';
      case '2':
        return 'Preto';
      case '3':
        return 'Pardo';
      case '4':
        return 'Amarelo';
      case '5':
        return 'Indígena';
      case '8':
        return 'Outros';
      case '9':
        return 'Não sabe';
      default:
        return '';
    }
  }

  void _convertToDateTime() {
    DateFormat format = DateFormat("yyyy-MM-dd");

    setState(() {
      _selectedDate = _dataNascimentoController.text.isNotEmpty
          ? format.parseStrict(_dataNascimentoController.text)
          : null;
      _selectedDate2 = _dataPriSintomas.text.isNotEmpty
          ? format.parseStrict(_dataPriSintomas.text)
          : null;
      _selectedDate3 = _dataPriConsulta.text.isNotEmpty
          ? format.parseStrict(_dataPriConsulta.text)
          : null;
      _selectedDate4 = _dataDoObito.text.isNotEmpty
          ? format.parseStrict(_dataDoObito.text)
          : null;
      _selectedDate5 = _dataInicioDoTrat.text.isNotEmpty
          ? format.parseStrict(_dataInicioDoTrat.text)
          : null;
      _selectedDate6 = _dataDoDiagnostico.text.isNotEmpty
          ? format.parseStrict(_dataDoDiagnostico.text)
          : null;
      _selectedDate7 = _dataDoEncOncoPed.text.isNotEmpty
          ? format.parseStrict(_dataDoEncOncoPed.text)
          : null;
    });
  }

  String? _sexoCod;
  String? _etniaCod;
  String? _localDiagCod;
  String? _localTratCod;
  String? _inicioTratCod;
  String? _tipoTratCod;
  String? _codeOrEmpty(Map<String, String> m, String? label) {
    if (label == null) return null;
    return m[label] ?? ''; // se não achar, manda vazio pra não quebrar
  }

  void _checkSexoField() {
    setState(() {
      _isSexoEnabled = _sexoSelecionado == null || _sexoSelecionado!.isEmpty;
    });
  }

  void _checklocaldiagField() {
    setState(() {
      _localDiagEnabled = _localDiag == null || _localDiag!.isEmpty;
    });
  }

  void _checklocaltratField() {
    setState(() {
      _localTratEnabled = _localTrat == null || _localTrat!.isEmpty;
    });
  }

  void _checklocalIniciotratField() {
    setState(() {
      _localInicioTratEnabled =
          _localInicioDoTrat == null || _localInicioDoTrat!.isEmpty;
    });
  }

  void _checketiniaField() {
    setState(() {
      _isEtiniaEnabled =
          _etniapacSelecionado == null || _etniapacSelecionado!.isEmpty;
    });
  }

  void _checkespecialidadeField() {
    setState(() {
      _isEspecialidadeEnabled = _especialidadepacSelecionado == null ||
          _especialidadepacSelecionado!.isEmpty;
    });
  }

  void _checkespecialidade2Field() {
    setState(() {
      _isEspecialidade2Enabled = _especialidadepacSelecionado2 == null ||
          _especialidadepacSelecionado2!.isEmpty;
    });
  }

  void _checkEstadoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
      _isEstadoEnabled =
          _estadoSelecionado == null || _estadoSelecionado!.isEmpty;
    });
  }

  void _checkcidadeField() {
    _isCidadeEnabled = _cidadeProc == '';
  }

  void _checkdataprimeirosintomasField() {
    setState(() {
      if (_dataPriSintomas.text.isNotEmpty) {
        _isDataPriSintomasEnabled = false;
      }
    });
  }

  void _checkdataPrimeiraConsulta() {
    setState(() {
      if (_dataPriConsulta.text.isNotEmpty) {
        _isDataPriConsultaEnabled = false;
      }
    });
  }

  void _checkdataEncamOnco() {
    setState(() {
      if (_dataDoEncOncoPed.text.isNotEmpty) {
        _isDataEncaOncoEnabled = false;
      }
    });
  }

  void _checkdataDiagnostico() {
    setState(() {
      if (_dataDoDiagnostico.text.isNotEmpty) {
        _isDataDiagnosticoEnabled = false;
      }
    });
  }

  void _checkdiagnosticoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkdiagnosticodescritivoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
      _isDiagnosticodetalhadoEnabled = _diagnosticoDetalhado == '';
    });
  }

  void _checkdiestadiamentoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar

      _isestadimentoenabled = _estadiamento == '';
    });
  }

  void _checkestadiamento2Field() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checknovodiagnosticoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkMetastaseField() {
    setState(() {
      _isMetastaseEnable = _metastase ==
          ''; // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkClassificacaoMolecularField() {
    setState(() {
      _isClassificacaomolecularEnable = _classificacaoMolecular == 'Não' ||
          _classificacaoMolecular ==
              ''; // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkhouvenovodiagnosticoField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkdatainiciodotratField() {
    setState(() {
      if (_dataInicioDoTrat.text.isNotEmpty) {
        _isDatainiciodotratEnable = false;
      }
    });
  }

  void _checkdiagnosticodetalhado2Field() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkTipotratamentopacField() {
    setState(() {
      _isTipotratamentopacEnable = _tipoTratamentoPac == 'Não' ||
          _tipoTratamentoPac ==
              ''; // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkdataultimotratField() {
    //setState(() {
    //if (_dataUltimoTrat.text.isNotEmpty) {
    _isDataultimotratEnable = true;
    //}
    //}
    //);
  }

  void _checknomedoprotocoloField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkprimeira_consultaField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checksegunda_linhaField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkterceira_linhaField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  void _checkquarta_linhaField() {
    setState(() {
      // Verifique a condição inicial para habilitar ou desabilitar
    });
  }

  @override
  void initState() {
    super.initState();

    // Carrega lista de neoplasias (para os diálogos de seleção)
    NeoplasiasService().fetchNeoplasias(_updateNeoplasias);

    _selectedTratamentos = (widget.patient.tipotratamentopac ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // ====== MAPEIA CÓDIGO (REDCap) -> RÓTULO (para os Dropdowns) ======
    _sexoSelecionado = labelFromCode(kSexoMap, widget.patient.sexopac);
    _etniapacSelecionado = labelFromEtniaCode(widget.patient.etniapac);
    _localDiag = labelFromCode(kHospitalCodes, widget.patient.localdiag);
    _localTrat = labelFromCode(kHospitalCodes, widget.patient.localtrat);
    _localInicioDoTrat =
        labelFromCode(kHospitalCodes, widget.patient.localiniciodotrat);

    // ====== CONTROLLERS E CAMPOS LIVRES ======
    _nomeController.text = widget.patient.nomepac;
    _nomeDaMaeController.text = widget.patient.nomedamae;

    _dataNascimentoController =
        TextEditingController(text: widget.patient.datanascpac);
    _idadeController = TextEditingController(text: widget.patient.idadepac);
    _dataPriSintomas =
        TextEditingController(text: widget.patient.dataprisintomas);

    _cpfPac.text = widget.patient.cpfpac;
    _cartaoSus.text = widget.patient.cartaosus;

    _cidadeProc = widget.patient.cidadeproc;
    _estadoSelecionado = widget.patient.estadoproc;
    _estadoSelecionado2 =
        widget.patient.estadodoobito; // UF do óbito (quando aplicável)

    _outroHospitaldiag.text = widget.patient.outrolocaldiagnostico;
    _dataPriConsulta.text = widget.patient.datapriconsulta;
    _outroHospitalTrat.text = widget.patient.outrolocaltratamento;
    _dataInicioDoTrat.text = widget.patient.datainiciodotrat;
    _outroHospitalInicioTrat.text = widget.patient.outrolocaliniciotratamento;
    _dataDoObito.text = widget.patient.datadoobito;
    _dataDoDiagnostico.text = widget.patient.datadodiagnostico;

    _diagnostico = widget.patient.diagnostico;
    _diagnosticoDetalhado = widget.patient.diagnosticodetalhado;
    _estadiamento = widget.patient.estadiamentodotumor;
    _diagnosticoDescritivo.text = widget.patient.diagnosticodescritivo;

    _especialidadepacSelecionado =
        widget.patient.especialidadepaciente.isNotEmpty
            ? widget.patient.especialidadepaciente
            : null;

    _especialidadepacSelecionado2 =
        widget.patient.especialidadepaciente2.isNotEmpty
            ? widget.patient.especialidadepaciente2
            : null;

    _vivo = widget.patient.vivo;
    _recaidapacSelecionado = widget.patient.recaida;
    _dataDaRecaida.text = widget.patient.datadarecaida;
    _refratariedadepacSelecionado = widget.patient.refratariedade;
    _classificacaoMolecular = widget.patient.classificacaomolecular;
    _houvenovodiagnostico = widget.patient.houvenovodiagnostico;
    _novoDiagnostico = widget.patient.novodiagnostico;
    _estadiamento2 = widget.patient.estadiamento2;

    _selectedItemsexames = (widget.patient.examedodiagnostico ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _selectedItemsTempexames = List.from(_selectedItemsexames);

    _obito = widget.patient.obito;
    _motivoObitoPac = widget.patient.motivoobitopac;
    _tipoTratamentoPac = widget.patient.tipotratamentopac;
    _dataDoEncOncoPed.text = widget.patient.datadoenconcoped;
    _metastase = widget.patient.metastase;
    _dataUltimoTrat.text = widget.patient.dataultimotrat;

    _nomeDoProtocolo.text = widget.patient.nomedoprotocolo;
    _primeira_linha.text = widget.patient.primeiraLinha;
    _segunda_linha.text = widget.patient.segundaLinha;
    _terceira_linha.text = widget.patient.terceiraLinha;
    _quarta_linha.text = widget.patient.quartaLinha;

    _dadosmolecular.text = widget.patient.dadosdaclassificacaomolecular;
    _cidadeDoObito = widget.patient.cidadedoobito;

    // Se você tem esse campo no model, popular o controlador:
    // (deixa vazio se não existir)
    _localDoTumor.text = widget.patient.localdotumor ?? '';

    // ===== CARREGAR TMO JÁ SALVO =====
    if (widget.patient.tipotmo != null && widget.patient.tipotmo!.isNotEmpty) {
      final partes =
          widget.patient.tipotmo!.split(',').map((e) => e.trim()).toList();

      for (final p in partes) {
        final match = _tiposTmo.firstWhere(
          (t) => p.toLowerCase().contains(t.toLowerCase()),

          //(t) => p.startsWith(t),
          orElse: () => '',
        );

        if (match.isNotEmpty && match != 'Outros') {
          if (!_selectedItensTmo.contains(match)) {
            _selectedItensTmo.add(match);
          }
        } else {
          if (!_selectedItensTmo.contains('Outros')) {
            _selectedItensTmo.add('Outros');
          }
          _outroTipoTmoController.text = p;
        }
      }
    }

    // Converte campos de data dos controllers para DateTime locais (usado nos validadores)
    _convertToDateTime();

    // ====== CHECAGENS DE HABILITA/DESABILITA CAMPOS ======
    _checkSexoField();
    _checklocaldiagField();
    _checklocaltratField();
    _checklocalIniciotratField();
    _checketiniaField();
    _checkespecialidadeField();
    _checkespecialidade2Field();
    _checkEstadoField();
    _checkcidadeField();
    _checkdataprimeirosintomasField();
    _checkdataPrimeiraConsulta();
    _checkdataDiagnostico();
    _checkdiagnosticoField();
    _checkdiagnosticodescritivoField();
    _checkdiestadiamentoField();
    _checkhouvenovodiagnosticoField();
    _checknovodiagnosticoField();
    _checkestadiamento2Field();
    _checkdiagnosticodetalhado2Field();
    _checkMetastaseField();
    _checkClassificacaoMolecularField();
    _checkdatainiciodotratField();
    _checkTipotratamentopacField();
    _checkdataultimotratField();

    // Inicializa o service (token já está no widget)
    PatientService(widget.token);
  }

  void _showTiposTmoDialog() async {
    List<String> temp = List.from(_selectedItensTmo);
    final outroController =
        TextEditingController(text: _outroTipoTmoController.text);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tipos de TMO'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._tiposTmo.map((t) {
                      return CheckboxListTile(
                        title: Text(t),
                        value: temp.contains(t),
                        onChanged: (v) {
                          setStateDialog(() {
                            v! ? temp.add(t) : temp.remove(t);
                          });
                        },
                      );
                    }),
                    if (temp.contains('Outros'))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: outroController,
                          decoration: const InputDecoration(
                            labelText: 'Especifique o tipo de TMO',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
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
                      _outroTipoTmoController.text = outroController.text;
                    });
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

  void _updateNeoplasias(List<Neoplasia> neoplasias) {
    setState(() {
      _neoplasias = neoplasias;
      _neoplasias2 = neoplasias;
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

  Future<void> _selectDateNascComp(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDatecampo ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectDateNascComp) {
      setState(() {
        _selectedDatecampo = picked;
        _dataNascimentoCompController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDatecampo!);
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
    if (picked2 != null && picked2 != _selectedDate2) {
      setState(() {
        _selectedDate2 = picked2;
        _dataPriSintomas.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate2!);
      });
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
      if (_selectedDate2 != null && picked3.isAfter(_selectedDate2!)) {
        setState(() {
          _selectedDate3 = picked3;
          _dataPriConsulta.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate3!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data da primeira consulta deve ser posterior à data dos primeiros sintomas.',
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
      if (_selectedDate3 != null && picked2.isAfter(_selectedDate3!)) {
        setState(() {
          _selectedDate6 = picked2;
          _dataDoDiagnostico.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate6!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do diagnóstico deve ser posterior à data da primeira consulta.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
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
      if (_selectedDate2 != null &&
          _selectedDate3 != null &&
          picked2.isAfter(_selectedDate2!) &&
          picked2.isAfter(_selectedDate3!)) {
        setState(() {
          _selectedDate7 = picked2;
          _dataDoEncOncoPed.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate7!);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do encaminhamento para oncologia pediátrica deve ser posterior à data dos primeiros sintomas e da data da primeira consulta.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  void _selectdataPriSintomas(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      DateTime? dataPrimeirosSintomas;
      if (_dataPriSintomas.text.isNotEmpty) {
        dataPrimeirosSintomas = DateTime.tryParse(_dataPriSintomas.text);
      }

      if (dataPrimeirosSintomas != null &&
          _selectedDate3 != null &&
          picked.isBefore(_selectedDate3!)) {
        setState(() {
          _dataPriSintomas.text = DateFormat('yyyy-MM-dd')
              .format(picked); // Formata a data para 'yyyy-MM-dd'
        });
      } else {
        AnimatedSnackBar.material(
          'A data dos primeiros sintomas deve ser anterior à data da primeira consulta.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
        ).show(context);
      }
    }
  }

  Future<void> selectdatedataUltimoTrat(BuildContext context) async {
    DateTime initial = DateTime.now();

    if (_dataUltimoTrat.text.isNotEmpty) {
      initial = DateFormat('yyyy-MM-dd').parse(_dataUltimoTrat.text);
    }

    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _selectedDate5 ?? DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked2 != null) {
      if (_selectedDate5 != null && picked2.isAfter(_selectedDate5!)) {
        setState(() {
          _selectedDate9 = picked2;
          _dataUltimoTrat.text = DateFormat('yyyy-MM-dd').format(picked2);
        });
      } else {
        AnimatedSnackBar.material(
          'A data do último tratamento deve ser posterior à data de início do tratamento.',
          type: AnimatedSnackBarType.warning,
        ).show(context);
      }
    }
  }

  Future<void> _executarAtualizacao() async {
    final String tipotmoFinal = [
      ..._selectedItensTmo.where((e) => e != 'Outros'),
      if (_selectedItensTmo.contains('Outros') &&
          _outroTipoTmoController.text.isNotEmpty)
        _outroTipoTmoController.text,
    ].join(', ');

    final String tipoTratamentoFinal = _selectedTratamentos.join(', ');

    _sexoCod = _codeOrEmpty(kSexoMap, _sexoSelecionado);
    _etniaCod = _codeOrEmpty(kEtniaMap, _etniapacSelecionado);
    _localDiagCod = _codeOrEmpty(kHospitalCodes, _localDiag);
    _localTratCod = _codeOrEmpty(kHospitalCodes, _localTrat);
    _inicioTratCod = _codeOrEmpty(kHospitalCodes, _localInicioDoTrat);

    await PatientService(widget.token).updatedadosparaapi(
      context,
      recordid: widget.patient.registro,
      nomeController: _nomeController.text,
      dataNascimentoController: _dataNascimentoController.text,
      idadeController: _idadeController.text,
      sexoSelecionado: _sexoCod,
      etniapacSelecionado: _etniaCod,
      especialidadeSelecionado: _especialidadepacSelecionado,
      especialidadeSelecionado2: _especialidadepacSelecionado2,
      cpfPac: _cpfPac.text,
      cartaoSus: _cartaoSus.text,
      cidadeProc: _cidadeProc,
      estadoSelecionado: _estadoSelecionado,
      estadoSelecionado2: _estadoSelecionado2,
      localDiag: _localDiagCod,
      localTrat: _localTratCod,
      dataPriSintomas: _dataPriSintomas.text,
      dataPriConsulta: _dataPriConsulta.text,
      dataDoDiagnostico: _dataDoDiagnostico.text,
      dataDoEncOncoPed: _dataDoEncOncoPed.text,
      diagnostico: _diagnostico,
      examesDiagnosticoSelecionado: _selectedItemsexames,
      houvenovodiagnostico: _houvenovodiagnostico,
      novoDiagnostico: _novoDiagnostico,
      diagnosticoDetalhado: _diagnosticoDetalhado,
      estadiamento: _estadiamento,
      estadiamento2: _estadiamento2,
      diagnosticoDetalhado2: _diagnosticoDetalhado2,
      diagnosticoDescritivo: _diagnosticoDescritivo.text,
      dataInicioDoTrat: _dataInicioDoTrat.text,
      localInicioDoTrat: _inicioTratCod,
      tipoTratamentoPac: tipoTratamentoFinal,
      tipotmo: tipotmoFinal,
      vivo: _vivo,
      refratariedadepacSelecionado: _refratariedadepacSelecionado,
      recaidapacSelecionado: _recaidapacSelecionado,
      dataDaRecaida: _dataDaRecaida.text,
      obito: _obito,
      dataDoObito: _dataDoObito.text,
      motivoObitoPac: _motivoObitoPac,
      nomeDoProtocolo: _nomeDoProtocolo.text,
      primeiraLinha: _primeira_linha.text,
      segundaLinha: _segunda_linha.text,
      terceiraLinha: _terceira_linha.text,
      quartaLinha: _quarta_linha.text,
      classificacaoMolecular: _classificacaoMolecular,
      dadosmolecular: _dadosmolecular.text,
      nomeDaMaeController: _nomeDaMaeController.text,
      cidadeDoObito: _cidadeDoObito,
      localDoTumor: _localDoTumor.text,
      dataUltimoTrat: _dataUltimoTrat.text,
      metastase: _metastase,
      outrohospitaldiag: _outroHospitaldiag.text,
      outrolocaltratamento: _outroHospitalTrat.text,
      outrolocaliniciotratamento: _outroHospitalInicioTrat.text,
      dataAtualizacaoCadastro: dataatualizacaocad,
      especialidadePaciente2: _especialidadepacSelecionado2,
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> triggerAtualizarCadastro() async {
    await _executarAtualizacao();
  }

  List<String> _municipios = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color:
                    const Color.fromARGB(255, 147, 196, 125), // Cor azul pastel
                alignment: Alignment.center,
                child: const Text(
                  'IDENTIFICAÇÃO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _nomeController.text.isEmpty,
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: _dataNascimentoController.text.isNotEmpty,
                child: InkWell(
                  onTap: () => _selectDateNasc(context),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _dataNascimentoController,
                      decoration: const InputDecoration(
                        labelText: 'Data de nascimento: ',
                        labelStyle: TextStyle(fontSize: 20),
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      enabled: _dataNascimentoController.text.isEmpty,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nomeDaMaeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da mãe: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _nomeDaMaeController.text.isEmpty,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _idadeController.text.isEmpty,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isSexoEnabled,
                child: DropdownButtonFormField<String>(
                  initialValue: _sexoSelecionado ?? '',
                  decoration: InputDecoration(
                      labelText: 'Sexo: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isSexoEnabled),
                  onChanged: _isSexoEnabled
                      ? (String? newValue) {
                          setState(() {
                            _sexoSelecionado = newValue!;
                            _sexoCod = _codeOrEmpty(kSexoMap, _sexoSelecionado);
                          });
                        }
                      : null,
                  items: <String>[
                    'Masculino',
                    'Feminino',
                    '',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isEtiniaEnabled,
                child: DropdownButtonFormField<String>(
                  initialValue: _etniapacSelecionado ?? '',
                  decoration: InputDecoration(
                      labelText: 'Etnia: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isEtiniaEnabled),
                  onChanged: _isEtiniaEnabled
                      ? (String? newValue) {
                          setState(() {
                            _etniapacSelecionado = newValue!;
                            _etniaCod =
                                _codeOrEmpty(kEtniaMap, _etniapacSelecionado);
                          });
                        }
                      : null,
                  items: <String>[
                    'Branco',
                    'Pardo',
                    'Preto',
                    'Indígena',
                    'Amarelo',
                    'Outros',
                    'Não sabe',
                    ''
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
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
                enabled: _cpfPac.text.isEmpty,
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
                enabled: _cartaoSus.text.isEmpty,
                inputFormatters: [maskcartaosus],
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring:
                    !_isEstadoEnabled, // Condição para habilitar ou desabilitar
                child: DropdownButtonFormField<String>(
                  initialValue: _estadoSelecionado ?? '',
                  decoration: InputDecoration(
                      labelText: 'Estado de procedência: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isEstadoEnabled),
                  onChanged: _isEstadoEnabled
                      ? (String? newValue1) {
                          setState(() {
                            _estadoSelecionado = newValue1!;
                            _municipios.clear();
                            if (_estadoSelecionado != null) {
                              fetchMunicipios(_estadoSelecionado!);
                            }
                          });
                        }
                      : null,
                  items: _estadosBrasileiros
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring:
                    !_isCidadeEnabled, // Condição para habilitar ou desabilitar
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _cidadeProc ?? ''),
                  decoration: InputDecoration(
                      labelText: 'Cidade de procedência: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isCidadeEnabled),
                  onTap: _isCidadeEnabled
                      ? () {
                          _mostrarDialogoSelecaoMunicipio(context);
                        }
                      : null, // Desabilita o evento onTap quando o campo não está habilitado
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color:
                    const Color.fromARGB(255, 109, 158, 235), // Cor azul pastel
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
                  const SizedBox(height: 20),
                  IgnorePointer(
                    ignoring: !_localDiagEnabled,
                    child: SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _localDiag ?? '',
                        decoration: InputDecoration(
                          labelText: 'Selecione o hospital de diagnóstico: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          enabled: _localDiagEnabled,
                        ),
                        style: const TextStyle(fontSize: 20),
                        onChanged: _localDiagEnabled
                            ? (String? newValue) {
                                setState(() {
                                  _localDiag = newValue;
                                  _localDiagCod =
                                      _codeOrEmpty(kHospitalCodes, _localDiag);
                                });
                              }
                            : null,
                        items: <String>[
                          'HCPA - Hospital de Clínicas de Porto Alegre',
                          'GHC - Grupo Hospitalar Conceição',
                          'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre',
                          'HSVP - Hospital São Vicente de Paulo',
                          'HGCS - Hospital Geral de Caxias do Sul',
                          'HUSM - Hospital Universitário de Santa Maria',
                          'Outro',
                          ''
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
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
                        decoration: InputDecoration(
                          labelText: 'Digite o hospital de diagnóstico: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          enabled: _outroHospitaldiag.text.isEmpty,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    ignoring: !_localTratEnabled,
                    child: SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _localTrat ?? '',
                        decoration: InputDecoration(
                          labelText: 'Selecione o hospital do tratamento: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          enabled: _localTratEnabled,
                        ),
                        style: const TextStyle(fontSize: 20),
                        onChanged: _localTratEnabled
                            ? (String? newValue) {
                                setState(() {
                                  _localTrat = newValue;
                                  _localTratCod =
                                      _codeOrEmpty(kHospitalCodes, _localTrat);
                                });
                              }
                            : null,
                        items: <String>[
                          'HCPA - Hospital de Clínicas de Porto Alegre',
                          'GHC - Grupo Hospitalar Conceição',
                          'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre',
                          'HSVP - Hospital São Vicente de Paulo',
                          'HGCS - Hospital Geral de Caxias do Sul',
                          'HUSM - Hospital Universitário de Santa Maria',
                          'Outro',
                          ''
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
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
                        decoration: InputDecoration(
                          labelText: 'Hospital de início do tratamento: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          enabled: _outroHospitalTrat.text.isEmpty,
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
              IgnorePointer(
                ignoring: !_isDataPriSintomasEnabled,
                child: InkWell(
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
                        enabled: _isDataPriSintomasEnabled),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isDataPriConsultaEnabled,
                child: InkWell(
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
                      style: const TextStyle(fontSize: 20),
                      enabled: _isDataPriConsultaEnabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: (_especialidadepacSelecionado != null &&
                        _especialidadepacSelecionado!.isNotEmpty)
                    ? _especialidadepacSelecionado
                    : null,
                decoration: InputDecoration(
                  labelText: 'Especialidade médica do primeiro encaminhamento:',
                  labelStyle: const TextStyle(fontSize: 20),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  enabled: _isEspecialidadeEnabled,
                ),
                onChanged: _isEspecialidadeEnabled
                    ? (String? newValue) {
                        setState(() {
                          _especialidadepacSelecionado = newValue!;
                        });
                      }
                    : null,
                items: <String>[
                  'Alergia e Imunologia',
                  'Anestesiologia',
                  'Angiologia',
                  'Cardiologia',
                  'Cirurgia Cardiovascular',
                  'Cirurgia da Mão',
                  'Cirurgia de Cabeça e Pescoço',
                  'Cirurgia do Aparelho Digestivo',
                  'Cirurgia Geral',
                  'Cirurgia Oncológica',
                  'Cirurgia Pediátrica',
                  'Cirurgia Plástica',
                  'Cirurgia Torácica',
                  'Cirurgia Vascular',
                  'Clínica Médica',
                  'Coloproctologia',
                  'Dermatologia',
                  'Endocrinologia e Metabologia',
                  'Endoscopia',
                  'Gastroenterologia',
                  'Genética Médica',
                  'Geriatria',
                  'Ginecologia e Obstetrícia',
                  'Hematologia e Hemoterapia',
                  'Homeopatia',
                  'Infectologia',
                  'Mastologia',
                  'Medicina de Emergência',
                  'Medicina de Família e Comunidade',
                  'Medicina do Trabalho',
                  'Medicina de Tráfego',
                  'Medicina Esportiva',
                  'Medicina Física e Reabilitação',
                  'Medicina Intensiva',
                  'Medicina Legal e Perícia Médica',
                  'Medicina Nuclear',
                  'Medicina Preventiva e Social',
                  'Nefrologia',
                  'Neurocirurgia',
                  'Neurologia',
                  'Nutrologia',
                  'Oftalmologia',
                  'Oncologia Clínica',
                  'Ortopedia e Traumatologia',
                  'Otorrinolaringologia',
                  'Patologia',
                  'Patologia Clínica/Medicina Laboratorial',
                  'Pediatria',
                  'Pneumologia',
                  'Psiquiatria',
                  'Radiologia e Diagnóstico por Imagem',
                  'Radioterapia',
                  'Reumatologia',
                  'Urologia',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isDataPriConsultaEnabled,
                child: InkWell(
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
                      enabled: _isDataPriConsultaEnabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring:
                    !_isDataDiagnosticoEnabled, // Condição para habilitar ou desabilitar
                child: InkWell(
                  onTap: () => _selectDateDiagnostico(context),
                  child: IgnorePointer(
                    child: TextFormField(
                        controller: _dataDoDiagnostico,
                        decoration: const InputDecoration(
                          labelText: 'Data do diagnóstico: ',
                          labelStyle: TextStyle(fontSize: 20),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 20),
                        enabled: _isDataDiagnosticoEnabled),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: const Color.fromARGB(255, 255, 153, 0), // Cor laranja
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
                controller: TextEditingController(text: _diagnostico ?? ""),
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico da doença: ',
                  labelStyle: TextStyle(fontSize: 20),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                onTap: () {
                  _mostrarDialogoSelecaoNeoplasia(context);
                },
                enabled: _diagnostico?.isEmpty,
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
                            decoration: InputDecoration(
                                labelText: 'Classificação: ',
                                labelStyle: const TextStyle(fontSize: 20),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                enabled: _isDiagnosticodetalhadoEnabled),
                            onTap: () {
                              _mostrarDialogoSelecaoClassificacao(context);
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
                          IgnorePointer(
                            ignoring: !_isestadimentoenabled,
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text: _estadiamento ?? ""),
                              decoration: InputDecoration(
                                  labelText: 'Estadiamento: ',
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  enabled: _isestadimentoenabled),
                              onTap: () {
                                _mostrarDialogoSelecaoEstadiamento(context);
                              },
                            ),
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
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico descritivo: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _diagnosticoDescritivo.text.isEmpty,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _localDoTumor,
                decoration: const InputDecoration(
                  labelText: 'Local do Tumor: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _diagnosticoDescritivo.text.isEmpty,
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isMetastaseEnable,
                child: DropdownButtonFormField<String>(
                  initialValue: _metastase ?? '',
                  decoration: InputDecoration(
                      labelText: 'Metástase: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isMetastaseEnable),
                  onChanged: _isMetastaseEnable
                      ? (String? newValue) {
                          setState(() {
                            _metastase = newValue!;
                          });
                        }
                      : null,
                  items: <String>[
                    'Metastático',
                    'Não metastático',
                    'Não se aplica',
                    ''
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              AbsorbPointer(
                absorbing: _selectedItemsexames.isNotEmpty,
                child: GestureDetector(
                  onTap: _showExamesdiag,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedItemsexames.isEmpty
                              ? 'Exames do diagnóstico'
                              : _selectedItemsexames.join(', '),
                          style: TextStyle(
                            color: _selectedItemsexames.isEmpty
                                ? Colors.black
                                : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: _selectedItemsexames.isEmpty
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isClassificacaomolecularEnable,
                child: DropdownButtonFormField<String>(
                  initialValue: _classificacaoMolecular,
                  decoration: InputDecoration(
                      labelText: 'Classificação molecular: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isClassificacaomolecularEnable),
                  onChanged: _isClassificacaomolecularEnable
                      ? (String? newValue) {
                          setState(() {
                            _classificacaoMolecular = newValue!;
                          });
                        }
                      : null,
                  items: <String>['Não', 'Sim', '']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: _classificacaoMolecular == 'Sim',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dadosmolecular,
                      decoration: InputDecoration(
                        labelText: 'Dados da classificação molecular: ',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        enabled: _dadosmolecular.text.isEmpty,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: (_especialidadepacSelecionado2 != null &&
                        _especialidadepacSelecionado2!.isNotEmpty)
                    ? _especialidadepacSelecionado2
                    : null,
                decoration: InputDecoration(
                  labelText: 'Especialidade médica do segundo encaminhamento:',
                  labelStyle: const TextStyle(fontSize: 20),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  enabled: _isEspecialidade2Enabled,
                ),
                onChanged: _isEspecialidade2Enabled
                    ? (String? newValue) {
                        setState(() {
                          _especialidadepacSelecionado2 = newValue!;
                        });
                      }
                    : null,
                items: <String>[
                  'Alergia e Imunologia',
                  'Anestesiologia',
                  'Angiologia',
                  'Cardiologia',
                  'Cirurgia Cardiovascular',
                  'Cirurgia da Mão',
                  'Cirurgia de Cabeça e Pescoço',
                  'Cirurgia do Aparelho Digestivo',
                  'Cirurgia Geral',
                  'Cirurgia Oncológica',
                  'Cirurgia Pediátrica',
                  'Cirurgia Plástica',
                  'Cirurgia Torácica',
                  'Cirurgia Vascular',
                  'Clínica Médica',
                  'Coloproctologia',
                  'Dermatologia',
                  'Endocrinologia e Metabologia',
                  'Endoscopia',
                  'Gastroenterologia',
                  'Genética Médica',
                  'Geriatria',
                  'Ginecologia e Obstetrícia',
                  'Hematologia e Hemoterapia',
                  'Homeopatia',
                  'Infectologia',
                  'Mastologia',
                  'Medicina de Emergência',
                  'Medicina de Família e Comunidade',
                  'Medicina do Trabalho',
                  'Medicina de Tráfego',
                  'Medicina Esportiva',
                  'Medicina Física e Reabilitação',
                  'Medicina Intensiva',
                  'Medicina Legal e Perícia Médica',
                  'Medicina Nuclear',
                  'Medicina Preventiva e Social',
                  'Nefrologia',
                  'Neurocirurgia',
                  'Neurologia',
                  'Nutrologia',
                  'Oftalmologia',
                  'Oncologia Clínica',
                  'Ortopedia e Traumatologia',
                  'Otorrinolaringologia',
                  'Patologia',
                  'Patologia Clínica/Medicina Laboratorial',
                  'Pediatria',
                  'Pneumologia',
                  'Psiquiatria',
                  'Radiologia e Diagnóstico por Imagem',
                  'Radioterapia',
                  'Reumatologia',
                  'Urologia',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

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

              IgnorePointer(
                ignoring: !_isDatainiciodotratEnable,
                child: InkWell(
                  onTap: () => selectdateInicioDoTrat(context),
                  child: IgnorePointer(
                    child: TextFormField(
                        controller: _dataInicioDoTrat,
                        decoration: const InputDecoration(
                          labelText: 'Data do início do tratamento: ',
                          labelStyle: TextStyle(fontSize: 20),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 20),
                        enabled: _isDatainiciodotratEnable),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IgnorePointer(
                    ignoring: !_localInicioTratEnabled,
                    child: SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _localInicioDoTrat ?? '',
                        decoration: InputDecoration(
                          labelText:
                              'Selecione o hospital de início do tratamento: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          enabled: _localInicioTratEnabled,
                        ),
                        style: const TextStyle(fontSize: 20),
                        onChanged: _localInicioTratEnabled
                            ? (String? newValue) {
                                setState(() {
                                  _localInicioDoTrat = newValue;
                                  _inicioTratCod = _codeOrEmpty(
                                      kHospitalCodes, _localInicioDoTrat);
                                });
                              }
                            : null,
                        items: <String>[
                          'HCPA - Hospital de Clínicas de Porto Alegre',
                          'GHC - Grupo Hospitalar Conceição',
                          'ISCMPA - Hospital Santo Antônio - Santa Casa de Misericórdia de Porto Alegre',
                          'HSVP - Hospital São Vicente de Paulo',
                          'HGCS - Hospital Geral de Caxias do Sul',
                          'HUSM - Hospital Universitário de Santa Maria',
                          'Outro',
                          '',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
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
                        decoration: InputDecoration(
                          labelText:
                              'Digite o hospital de início do tratamento: ',
                          labelStyle: const TextStyle(fontSize: 20),
                          border: const OutlineInputBorder(),
                          enabled: _outroHospitalInicioTrat.text.isEmpty,
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
              GestureDetector(
                onTap: _showTiposTratamentoDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTratamentos.isEmpty
                              ? 'Tipo de tratamento'
                              : _selectedTratamentos.join(', '),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              /*   IgnorePointer(
                ignoring: !_isTipotratamentopacEnable,
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoTratamentoPac ?? '',
                  decoration: InputDecoration(
                      labelText: 'Tipo de tratamento: ',
                      labelStyle: const TextStyle(fontSize: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      enabled: _isTipotratamentopacEnable),
                  onChanged: _isTipotratamentopacEnable
                      ? (String? newValue) {
                          setState(() {
                            _tipoTratamentoPac = newValue!;
                          });
                        }
                      : null,
                  items: <String>[
                    'Imunoterapia',
                    'Cirurgia',
                    'Radioterapia',
                    'Quimioterapia',
                    'Hormônio',
                    'Transplante de medula óssea',
                    'Nenhum tratamento realizado',
                    '',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ), */

              const SizedBox(height: 20),

              Visibility(
                //visible: _tipoTratamentoPac == 'Transplante de medula óssea',
                //visible: _selectedTratamentos.contains('Transplante de medula óssea'),
                visible: _selectedTratamentos
                        .contains('Transplante de medula óssea') ||
                    _selectedItensTmo.isNotEmpty,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    : [
                                        ..._selectedItensTmo
                                            .where((e) => e != 'Outros'),
                                        if (_selectedItensTmo
                                                .contains('Outros') &&
                                            _outroTipoTmoController
                                                .text.isNotEmpty)
                                          _outroTipoTmoController.text,
                                      ].join(', '),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                //enabled: _nomeDoProtocolo.text.isEmpty,
                enabled: true,
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _primeira_linha,
                decoration: InputDecoration(
                  labelText: 'Primeira Linha: ',
                  labelStyle: const TextStyle(fontSize: 20),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  enabled: _primeira_linha.text.isEmpty,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _segunda_linha,
                decoration: const InputDecoration(
                  labelText: 'Segunda Linha: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _segunda_linha.text.isEmpty,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _terceira_linha,
                decoration: const InputDecoration(
                  labelText: 'Terceira Linha: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _terceira_linha.text.isEmpty,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quarta_linha,
                decoration: const InputDecoration(
                  labelText: 'Quarta Linha: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                enabled: _quarta_linha.text.isEmpty,
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: !_isDataultimotratEnable,
                child: InkWell(
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
                        enabled: _isDataultimotratEnable),
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
                initialValue: _vivo ?? '',
                decoration: const InputDecoration(
                  labelText: 'Vivo? ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                onChanged: (String? newValue) {
                  setState(() {
                    _vivo = newValue!;
                    // Define "Óbito" automaticamente com base em "Vivo?"
                    _obito = newValue == 'Sim' ? 'Não' : 'Sim';
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

              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _houvenovodiagnostico ?? '',
                decoration: const InputDecoration(
                  labelText: 'Houve mudança do diagnóstico da doença? ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                onChanged: (String? newValue) {
                  setState(() {
                    _houvenovodiagnostico = newValue!;
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
                visible: _houvenovodiagnostico == 'Sim',
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: _novoDiagnostico ?? ""),
                      decoration: const InputDecoration(
                        labelText: 'Novo diagnóstico da doença: ',
                        labelStyle: TextStyle(fontSize: 20),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onTap: () {
                        _mostrarDialogoSelecaoNeoplasia2(context);
                      },
                      // enabled: _diagnostico?.isEmpty,
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _novoDiagnostico != null &&
                          _novoDiagnostico!.isNotEmpty,
                      child: Column(
                        children: [
                          Visibility(
                            visible: _temClassificacao2(_novoDiagnostico),
                            child: Column(
                              children: [
                                TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: _diagnosticoDetalhado2 ?? ""),
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Classificação do novo diagnostico: ',
                                    labelStyle: TextStyle(fontSize: 20),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 20),
                                  onTap: () {
                                    _mostrarDialogoSelecaoClassificacao2(
                                        context);
                                  },
                                ),
                                const SizedBox(height: 20),
                                Visibility(
                                  visible: _temestadiamento2(_novoDiagnostico),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: _estadiamento2 ?? ""),
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Estadiamento do novo diagnostico: ',
                                          labelStyle: TextStyle(fontSize: 20),
                                          suffixIcon:
                                              Icon(Icons.arrow_drop_down),
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        style: const TextStyle(fontSize: 20),
                                        onTap: () {
                                          _mostrarDialogoSelecaoEstadiamento2(
                                              context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _refratariedadepacSelecionado ?? '',
                decoration: const InputDecoration(
                  labelText: 'Refratariedade: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                onChanged: (String? newValue) {
                  setState(() {
                    _refratariedadepacSelecionado = newValue!;
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
                  setState(() {
                    _recaidapacSelecionado = newValue!;
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
              const SizedBox(height: 20),

              // Dropdown for Óbito inside the visibility check for Recaída
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
                initialValue: _obito ?? '',
                decoration: const InputDecoration(
                  labelText: 'Óbito: ',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 20),
                onChanged: (String? newValue) {
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
              // Nested Visibility for Óbito details
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
                      initialValue: _estadoSelecionado2 ?? '',
                      decoration: const InputDecoration(
                        labelText: 'UF(Unidade de Federação) de falecimento: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue1) {
                        setState(() {
                          _estadoSelecionado2 = newValue1!;
                          _municipios.clear();
                          if (_estadoSelecionado2 != null) {
                            fetchMunicipios(_estadoSelecionado2!);
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
                    ),

                    const SizedBox(height: 20),
                    // Condição para habilitar ou desabilitar
                    TextFormField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: _cidadeDoObito ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Cidade de falecimento: ',
                        labelStyle: TextStyle(fontSize: 20),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onTap: () {
                        _mostrarDialogoSelecaoCidadeobito(context);
                      }, // Desabilita o evento onTap quando o campo não está habilitado
                    ),

                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _motivoObitoPac ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Motivo do óbito: ',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (String? newValue) {
                        setState(() {
                          _motivoObitoPac = newValue!;
                        });
                      },
                      items: <String>[
                        'Progressão do tumor',
                        'Toxicidade terapêutica grave',
                        'Sepse',
                        'Outros',
                        ''
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
              const SizedBox(height: 20),
            ],
          ),
        ));
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
            title: const Text('Selecione a cidade de procedência'),
            content: DropdownSearch<String>(
              asyncItems: (String filter) => filtercidades(filter),
              selectedItem: _cidadeProc,
              onChanged: (String? newValue) {
                setState(() {
                  _cidadeProc = newValue;
                });
                Navigator.pop(context);
              },
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  icon: Icon(Icons.arrow_downward),
                  labelText: 'Selecione',
                  labelStyle: TextStyle(fontSize: 20),
                  //  border: OutlineInputBorder(),
                ),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                  ),
                  style: TextStyle(fontSize: 20),
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
            title: const Text('Selecione a cidade de falecimento:'),
            content: DropdownSearch<String>(
              asyncItems: (String filter) => filtercidades(filter),
              selectedItem: _cidadeDoObito,
              onChanged: (String? newValue) {
                setState(() {
                  _cidadeDoObito = newValue;
                });
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
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  style: TextStyle(fontSize: 20),
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
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                labelStyle: TextStyle(fontSize: 20),
                // border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                labelStyle: TextStyle(fontSize: 20),
                // border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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
    var neoplasiaSelecionada = _neoplasias2.firstWhere(
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
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                labelStyle: TextStyle(fontSize: 20),
                // border: OutlineInputBorder(),
              ),
              baseStyle: TextStyle(fontSize: 20),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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

  void _mostrarDialogoSelecaoNeoplasia2(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione o novo diagnóstico'),
          content: DropdownSearch<String>(
            items: _neoplasias2.map((n) => n.diagnostico).toList(),
            selectedItem: _novoDiagnostico,
            onChanged: (String? newValue) {
              setState(() {
                _novoDiagnostico = newValue;
                _diagnosticoDetalhado2 = null;
                _estadiamento2 =
                    null; // Resetar a classificação ao mudar o diagnóstico
              });
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                labelStyle: TextStyle(fontSize: 20),

                // border: OutlineInputBorder(),
              ),
              baseStyle: TextStyle(fontSize: 20),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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

  bool _temClassificacao2(String? novoDiagnostico) {
    var neoplasiaSelecionada2 = _neoplasias2.firstWhere(
        (n) => n.diagnostico == novoDiagnostico,
        orElse: () =>
            Neoplasia(diagnostico: '', classificacao: '', estadiamento: ''));

    return neoplasiaSelecionada2.classificacao.isNotEmpty;
  }

  void _mostrarDialogoSelecaoClassificacao2(BuildContext context) {
    var neoplasiaSelecionada2 =
        _neoplasias2.firstWhere((n) => n.diagnostico == _novoDiagnostico);
    var classificacoes2 = neoplasiaSelecionada2.classificacao
        .split(',')
        .map((e) => e.trim())
        .toList();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a classificação'),
          content: DropdownSearch<String>(
            items: classificacoes2,
            selectedItem: _diagnosticoDetalhado2,
            onChanged: (String? newValue) {
              setState(() {
                _diagnosticoDetalhado2 = newValue;
              });
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                labelStyle: TextStyle(fontSize: 20),
                // border: OutlineInputBorder(),
              ),
              baseStyle: TextStyle(fontSize: 20),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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

  bool _temestadiamento2(String? diagnostico2) {
    var neoplasiaSelecionada2 = _neoplasias2.firstWhere(
        (n) => n.diagnostico == diagnostico2,
        orElse: () =>
            Neoplasia(diagnostico: '', classificacao: '', estadiamento: ''));
    return neoplasiaSelecionada2.estadiamento.isNotEmpty;
  }

  void _mostrarDialogoSelecaoEstadiamento2(BuildContext context) {
    var neoplasiaSelecionada2 =
        _neoplasias2.firstWhere((n) => n.diagnostico == _novoDiagnostico);
    var estadiamento2 = neoplasiaSelecionada2.estadiamento
        .split(',')
        .map((e) => e.trim())
        .toList();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione o estadiamento'),
          content: DropdownSearch<String>(
            items: estadiamento2,
            selectedItem: _estadiamento2,
            onChanged: (String? newValue) {
              setState(() {
                _estadiamento2 = newValue;
              });
              Navigator.pop(context);
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Selecione',
                // border: OutlineInputBorder(),
              ),
              baseStyle: TextStyle(fontSize: 20),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: TextStyle(fontSize: 20),
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

  void fetchMunicipios(String estado) async {
    var uri = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$estado/municipios');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var municipios = json.decode(response.body);
      setState(() {
        _municipios = List<String>.from(municipios.map((x) => x['nome']));
      });
    } else {
      throw Exception('Failed to load municipios....');
    }
  }

  void _showExamesdiag() async {
    _selectedItemsTempexames = List.from(_selectedItemsexames);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione os exames'),
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
                      _selectedItemsexames = _selectedItemsexames;
                    });
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
  }
}
