class Patient {
  final String registro;
  final String nomepac;
  final String nomedamae;
  final String datanascpac;
  final String idadepac;
  final String sexopac;
  final String etniapac;
  final String especialidadepaciente;
  final String especialidadepaciente2;
  final String cpfpac;
  final String cartaosus;
  final String cidadeproc;
  final String estadoproc;
  final String localdiag;
  final String outrolocaldiagnostico;
  final String dataprisintomas;
  final String datapriconsulta;
  final String localtrat;
  final String outrolocaltratamento;
  final String datainiciodotrat;
  final String datadodiagnostico;
  final String localiniciodotrat;
  final String outrolocaliniciotratamento;
  final String refratariedade;
  final String datadoobito;
  final String diagnostico;
  final String diagnosticodetalhado;
  final String diagnosticoDetalhado2;
  final String obito;

  final String tipotratamentopac;

  final String? tipotmo;

  final String motivoobitopac;
  final String datadoenconcoped;
  final String dataexamediag;
  final String diagnosticodescritivo;
  final String metastase;
  final String localdotumor;
  final String datadarecaida;
  final String examedodiagnostico;
  final String estadiamentodotumor;
  final String estadiamento2;
  final String nomedoprotocolo;

  final String primeiraLinha;
  final String segundaLinha;
  final String terceiraLinha;
  final String quartaLinha;

  final String recaida;
  final String vivo;
  final String datametastase;
  final String classificacaomolecular;
  final String classificacao;
  final String dadosdaclassificacaomolecular;
  final String dataatualizacaocad;
  final String dataultimotrat;
  final String estadodoobito;
  final String cidadedoobito;
  final String novodiagnostico;
  final String houvenovodiagnostico;

  bool needsReview;

  Patient({
    required this.localdotumor,
    this.outrolocaldiagnostico = '',
    this.outrolocaltratamento = '',
    this.outrolocaliniciotratamento = '',
    required this.registro,
    required this.nomepac,
    required this.nomedamae,
    required this.datanascpac,
    required this.idadepac,
    required this.sexopac,
    required this.cpfpac,
    required this.cartaosus,
    required this.cidadeproc,
    required this.estadoproc,
    required this.localdiag,
    required this.dataprisintomas,
    required this.datapriconsulta,
    required this.localtrat,
    required this.datainiciodotrat,
    required this.localiniciodotrat,
    required this.datadoobito,
    required this.diagnostico,
    required this.classificacao,
    required this.diagnosticodetalhado,
    required this.diagnosticoDetalhado2,
    required this.etniapac,
    required this.especialidadepaciente,
    required this.especialidadepaciente2,
    required this.refratariedade,
    required this.motivoobitopac,
    required this.obito,
    required this.tipotratamentopac,
    required this.tipotmo,
    required this.datadodiagnostico,
    required this.datadoenconcoped,
    required this.dataexamediag,
    required this.diagnosticodescritivo,
    required this.metastase,
    required this.datadarecaida,
    required this.examedodiagnostico,
    required this.estadiamentodotumor,
    required this.nomedoprotocolo,
    required this.primeiraLinha,
    required this.segundaLinha,
    required this.terceiraLinha,
    required this.quartaLinha,
    required this.recaida,
    required this.vivo,
    required this.datametastase,
    required this.classificacaomolecular,
    required this.dadosdaclassificacaomolecular,
    required this.dataatualizacaocad,
    required this.dataultimotrat,
    required this.estadodoobito,
    required this.cidadedoobito,
    required this.novodiagnostico,
    required this.houvenovodiagnostico,
    required this.estadiamento2,
    this.needsReview = false,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      registro: json['record_id'] ?? '',
      nomepac: json['nome_do_paciente'] ?? '',
      nomedamae: json['nome_da_m_e_do_paciente'] ?? '',
      datanascpac: json['data_de_nascimento'] ?? '',
      idadepac: json['idade_do_paciente'] ?? '',
      sexopac: json['sexo'] ?? '',
      etniapac: json['etnia'] ?? '',
      especialidadepaciente: json['especialidade_do_m_dica_do'] ?? '',
      especialidadepaciente2: json['especialidade_medica_2'] ?? '',
      cpfpac: json['cpf'] ?? '',
      cartaosus: json['cns'] ?? '',
      cidadeproc: json['municio_residencia'] ?? '',
      estadoproc: json['uf_procedencia'] ?? '',
      localdiag: json['local_diagnostico'] ?? '',
      dataprisintomas: json['data_dos_primeiros_sintoma'] ?? '',
      datapriconsulta: json['data_da_primeira_consulta'] ?? '',
      localtrat: json['local_de_tratamento'] ?? '',
      datainiciodotrat: json['data_tratamento'] ?? '',
      localiniciodotrat: json['inicio_tratamento'] ?? '',
      refratariedade: json['houve_refratariedade'] ?? '',
      datadoobito: json['data_de_bito'] ?? '',
      diagnostico: json['diagn_stico'] ?? '',
      classificacao: json['classificacao'] ?? '',
      diagnosticodetalhado: json['diagn_stico_detalhado'] ?? '',
      diagnosticoDetalhado2: json['diagn_stico_detalhado_segm'] ?? '',
      tipotratamentopac: json['tipo_de_tratamento'] ?? '',
      tipotmo: json['tipotmo'] ?? '',
      obito: json['houve_bito'] ?? '',
      motivoobitopac: json['motivo_do_bito'] ?? '',
      datadodiagnostico: json['data_diagnostico'] ?? '',
      datadoenconcoped: json['data_do_encontro_com_o_ped'] ?? '',
      dataexamediag: json['data_do_exame'] ?? '',
      diagnosticodescritivo: json['diagn_stico_descritivo'] ?? '',
      metastase: json['met_stase'] ?? '',
      datadarecaida: json['data_da_reca_da'] ?? '',
      examedodiagnostico: json['exame_que_realizou_o_diagn'] ?? '',
      estadiamentodotumor: json['estadiamento_do_tumor'] ?? '',
      nomedoprotocolo: json['nome_do_protocolo_de_trata'] ?? '',
      primeiraLinha: json['primeira_linha_de_tratamen'] ?? '',
      segundaLinha: json['segunda_linha_de_tratament'] ?? '',
      terceiraLinha: json['terceira_linha_de_tratamen'] ?? '',
      quartaLinha: json['quarta_linha_de_tratamento'] ?? '',
      recaida: json['houve_reca_da'] ?? '',
      vivo: json['paciente_est_vivo'] ?? '',
      datametastase: json['datametastase'] ?? '',
      classificacaomolecular: json['classifica_o_molecular'] ?? '',
      dadosdaclassificacaomolecular: json['dadosmolecular'] ?? '',
      dataatualizacaocad: json['dt_atualizacao'] ?? '',
      dataultimotrat: json['data_do_ltimo_tratamento'] ?? '',
      estadodoobito: json['estado_obito'] ?? '',
      cidadedoobito: json['cidade_de_bito'] ?? '',
      houvenovodiagnostico: json['houve_novo_diagn_stico_seg'] ?? '',
      novodiagnostico: json['diagnostico2'] ?? '',
      estadiamento2: json['estadiamento_2'] ?? '',
      needsReview: json['needsReview'] == true || json['needsReview'] == 'true',
      outrolocaldiagnostico: json['outrohospitaldiag'] ?? '',
      outrolocaltratamento: json['mudou_de_hospital_durante'] ?? '',
      outrolocaliniciotratamento: json['outro_local_de_inicio_de_t'] ?? '',
      localdotumor: json['local_do_tumor'] ?? '',
    );
  }
}
