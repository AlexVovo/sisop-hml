// widgetPatientDetailsPage.dart

import 'package:flutter/material.dart';

import '../../model/patient_model.dart';

class widgetPatientDetailsPage extends StatefulWidget {
  final Patient patient;

  const widgetPatientDetailsPage({
    super.key,
    required this.patient,
  });

  @override
  _widgetPatientDetailsPageState createState() =>
      _widgetPatientDetailsPageState();
}

class _widgetPatientDetailsPageState extends State<widgetPatientDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: const Color.fromARGB(255, 147, 196, 125),
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
            _buildDetailRow('Nome:', widget.patient.nomepac),
            _buildDetailRow('Data de nascimento: ', widget.patient.datanascpac),
            _buildDetailRow('Nome da mãe:', widget.patient.nomedamae),
            _buildDetailRow('Idade: ', widget.patient.idadepac.toString()),
            _buildDetailRow('Sexo: ', widget.patient.sexopac),
            _buildDetailRow('Etnia: ', widget.patient.etniapac),
            _buildDetailRow('CPF: ', widget.patient.cpfpac),
            _buildDetailRow('Cartão SUS: ', widget.patient.cartaosus),
            _buildDetailRow(
                'Estado de procedência: ', widget.patient.estadoproc),
            _buildDetailRow(
                'Cidade de procedência: ', widget.patient.cidadeproc),
            const SizedBox(height: 20), // Adiciona um espaço entre os blocos
            Container(
              color: const Color.fromARGB(255, 109, 159, 234),
              alignment: Alignment.center,
              child: const Text(
                'INFORMAÇÕES DO ATENDIMENTO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildDetailRow(
                'Hospital de diagnóstico: ', widget.patient.localdiag),
            _buildDetailRow(
                'Hospital de tratamento: ', widget.patient.localtrat),
            _buildDetailRow('Data dos primeiros sintomas: ',
                widget.patient.dataprisintomas),
            _buildDetailRow(
                'Data da primeira consulta: ', widget.patient.datapriconsulta),

            _buildDetailRow('Especialidade medica do primeiro encaminhamento: ',
                widget.patient.especialidadepaciente),

            _buildDetailRow(
                'Data do encaminhamento para oncologia pediátrica: ',
                widget.patient.datadoenconcoped),
            _buildDetailRow(
                'Data do diagnóstico: ', widget.patient.datadodiagnostico),

            const SizedBox(height: 20), // Adiciona um espaço entre os blocos
            Container(
              color: const Color.fromARGB(255, 255, 153, 0),
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
            _buildDetailRow(
                'Diagnóstico da doença: ', widget.patient.diagnostico),
            _buildDetailRow(
                'Classificação: ', widget.patient.diagnosticodetalhado),
            _buildDetailRow(
                'Estadiamento: ', widget.patient.estadiamentodotumor),
            _buildDetailRow('Diagnóstico descritivo: ',
                widget.patient.diagnosticodescritivo),
            _buildDetailRow('Metástase: ', widget.patient.metastase),
            _buildDetailRow('Local do Tumor: ', widget.patient.localdotumor),
            _buildDetailRow(
                'Exames do diagnóstico: ', widget.patient.examedodiagnostico),
            _buildDetailRow('Classificação molecular: ',
                widget.patient.classificacaomolecular),
            // newly added molecular data row
            _buildDetailRow('Dados da classificação molecular: ',
                widget.patient.dadosdaclassificacaomolecular),
            _buildDetailRow('Especialidade medica do segundo encaminhamento: ',
                widget.patient.especialidadepaciente2),

            _buildDetailRow(
                'Arquivos de exames: ', widget.patient.examedodiagnostico),
            //_buildDetailRow(
            //  'Estadiamento do tumor: ', widget.patient.estadiamentodotumor),

            //_buildDetailRow('Data do diagnóstico de metástase: ',
            //  widget.patient.datametastase),

            // _buildDetailRow('PDF do exame: ', widget.patient.pdfdoexame as String), //Ver com Felipe
            const SizedBox(height: 20), // Adiciona um espaço entre os blocos
            Container(
              color: const Color.fromARGB(255, 240, 194, 51),
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
            _buildDetailRow('Data de início do tratamento: ',
                widget.patient.datainiciodotrat),

            _buildDetailRow('Hospital de início do tratamento: ',
                widget.patient.localiniciodotrat),
            _buildDetailRow('Hospital de início do tratamento: ',
                widget.patient.localiniciodotrat),
            _buildDetailRow('Tipo de tratamento do paciente: ',
                widget.patient.tipotratamentopac),
            _buildDetailRow(
                'Nome do protocolo: ', widget.patient.nomedoprotocolo),
            _buildDetailRow('Primeira Linha: ', widget.patient.primeiraLinha),
            _buildDetailRow('Segunda Linha: ', widget.patient.segundaLinha),
            _buildDetailRow('Terceira Linha: ', widget.patient.terceiraLinha),
            _buildDetailRow('Quarta Linha: ', widget.patient.quartaLinha),

            _buildDetailRow(
                'Data do último tratamento: ', widget.patient.dataultimotrat),
            const SizedBox(height: 20), // Adiciona um espaço entre os blocos
            Container(
              color: const Color.fromARGB(255, 213, 166, 189),
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
            //_buildDetailRow('Perda se seguimento : ', ''),
            _buildDetailRow('Vivo?', widget.patient.vivo),

            // _buildDetailRow('Local de início do tratamento: ', widget.patient.localiniciodotrat),
            //   _buildDetailRow('Exames utilizados para acompanhamento: ', widget.patient.examesutilparaacomp),
            _buildDetailRow(
              'Houve novo diagnóstico da doença? ',
              widget.patient.houvenovodiagnostico,
            ),

            if (widget.patient.houvenovodiagnostico == "Sim") ...[
              _buildDetailRow(
                'Novo diagnóstico da doença: ',
                widget.patient.novodiagnostico,
              ),
              _buildDetailRow(
                'Classificação do novo diagnóstico: ',
                widget.patient.diagnosticoDetalhado2,
              ),
            ],

            _buildDetailRow(
                'Ocorreu novo estadiamento? ', widget.patient.estadiamento2),
            _buildDetailRow('Refratariedade: ', widget.patient.refratariedade),
            _buildDetailRow('Recaída: ', widget.patient.recaida),
            _buildDetailRow('Data da recaída: ', widget.patient.datadarecaida),
            _buildDetailRow('Óbito: ', widget.patient.obito),
            _buildDetailRow('Data do Óbito: ', widget.patient.datadoobito),
            _buildDetailRow('Estado do Óbito: ', widget.patient.estadodoobito),
            _buildDetailRow('Cidade do Óbito: ', widget.patient.cidadedoobito),
            _buildDetailRow('Motivo do Óbito: ', widget.patient.motivoobitopac),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
