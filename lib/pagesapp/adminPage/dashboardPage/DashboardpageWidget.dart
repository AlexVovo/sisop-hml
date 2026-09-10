import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:regsitroweb/service/RedcapService.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboardpagewidget extends StatefulWidget {
  const Dashboardpagewidget({
    super.key,
    this.modoAdministrativo = false,
  });

  final bool modoAdministrativo;

  @override
  State<Dashboardpagewidget> createState() => _DashboardpagewidgetState();
}

class _IndicadorCampo {
  const _IndicadorCampo({
    required this.rotulo,
    required this.preenchidas,
    required this.total,
  });

  factory _IndicadorCampo.fromJson(Map<String, dynamic> json) {
    return _IndicadorCampo(
      rotulo: json['rotulo'] as String,
      preenchidas: json['preenchidas'] as int,
      total: json['total'] as int,
    );
  }

  final String rotulo;
  final int preenchidas;
  final int total;
}

class _IndicadorArea {
  const _IndicadorArea({
    required this.preenchidas,
    required this.total,
    required this.campos,
  });

  final int preenchidas;
  final int total;
  final List<_IndicadorCampo> campos;

  factory _IndicadorArea.fromJson(Map<String, dynamic> json) {
    return _IndicadorArea(
      preenchidas: json['preenchidas'] as int,
      total: json['total'] as int,
      campos: (json['campos'] as List)
          .map((item) => _IndicadorCampo.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

class _CampoAtencao {
  const _CampoAtencao({
    required this.area,
    required this.indicador,
    required this.percentual,
  });

  final String area;
  final _IndicadorCampo indicador;
  final double percentual;
}

class _DashboardpagewidgetState extends State<Dashboardpagewidget> {
  static const _todosEstabelecimentos = '__todos__';

  Map<String, _IndicadorArea> indicadores = {};
  Map<String, _IndicadorArea> _indicadoresGerais = {};
  Map<String, Map<String, _IndicadorArea>> indicadoresPorEstabelecimento = {};
  String estabelecimentoSelecionado = _todosEstabelecimentos;
  bool isLoading = true;
  String? mensagemErro;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  double calcularPercentual(int preenchidas, int total) {
    if (total == 0) return 0;
    return (preenchidas / total) * 100;
  }

  List<_CampoAtencao> get _camposQuePrecisamAtencao {
    final campos = <_CampoAtencao>[];
    for (final area in indicadores.entries) {
      for (final indicador in area.value.campos) {
        if (indicador.total == 0) continue;
        campos.add(
          _CampoAtencao(
            area: area.key,
            indicador: indicador,
            percentual: calcularPercentual(
              indicador.preenchidas,
              indicador.total,
            ),
          ),
        );
      }
    }
    campos.sort((a, b) {
      final porPercentual = a.percentual.compareTo(b.percentual);
      if (porPercentual != 0) return porPercentual;
      final faltantesA = a.indicador.total - a.indicador.preenchidas;
      final faltantesB = b.indicador.total - b.indicador.preenchidas;
      return faltantesB.compareTo(faltantesA);
    });
    return campos.take(5).toList();
  }

  Iterable<List<dynamic>> _linhasExportacao() sync* {
    yield [
      'Estabelecimento',
      'Seção',
      'Variável',
      'Preenchidas',
      'Total',
      'Faltantes',
      'Completude (%)'
    ];
    for (final area in indicadores.entries) {
      for (final campo in area.value.campos) {
        yield [
          estabelecimentoSelecionado == _todosEstabelecimentos
              ? 'Todos os estabelecimentos'
              : estabelecimentoSelecionado,
          area.key,
          campo.rotulo,
          campo.preenchidas,
          campo.total,
          campo.total - campo.preenchidas,
          double.parse(
            calcularPercentual(campo.preenchidas, campo.total)
                .toStringAsFixed(1),
          ),
        ];
      }
    }
  }

  String get _dataArquivo {
    final agora = DateTime.now();
    String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
    return '${agora.year}${doisDigitos(agora.month)}${doisDigitos(agora.day)}';
  }

  void _baixarXlsx() {
    final excel = Excel.createExcel();
    final sheet = excel['Completude'];
    excel.delete('Sheet1');

    for (final linha in _linhasExportacao()) {
      sheet.appendRow(
        linha.map<CellValue>((valor) {
          if (valor is int) return IntCellValue(valor);
          if (valor is double) return DoubleCellValue(valor);
          return TextCellValue(valor.toString());
        }).toList(),
      );
    }

    excel.save(fileName: 'completude_rhc_ici_$_dataArquivo.xlsx');
  }

  Future<void> abrirPainel() async {
    final url = Uri.parse('https://paineloncoped.ici.ong/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Erro ao abrir painel');
    }
  }

  Future<void> carregarDados() async {
    try {
      final service = RedcapService();
      Map<String, dynamic> resposta;
      if (widget.modoAdministrativo) {
        final hospitais = HospitalServicer();
        final token = await hospitais.buscarTokenSmart('ici') ??
            await hospitais.buscarTokenSmart('ICI') ??
            await hospitais.buscarTokenPorTermo('ici');
        if (token == null || token.isEmpty) {
          throw Exception('Token do hospital ICI não encontrado.');
        }
        resposta = await service.atualizarIndicadoresPublicos(token);
      } else {
        resposta = await service.fetchIndicadoresPublicos();
      }
      final calculados = <String, _IndicadorArea>{};
      for (final item in resposta['areas'] as List) {
        final area = Map<String, dynamic>.from(item as Map);
        calculados[area['nome'] as String] = _IndicadorArea.fromJson(area);
      }
      final porEstabelecimento = <String, Map<String, _IndicadorArea>>{};
      for (final item in (resposta['estabelecimentos'] as List? ?? const [])) {
        final estabelecimento = Map<String, dynamic>.from(item as Map);
        final areas = <String, _IndicadorArea>{};
        for (final itemArea in estabelecimento['areas'] as List) {
          final area = Map<String, dynamic>.from(itemArea as Map);
          areas[area['nome'] as String] = _IndicadorArea.fromJson(area);
        }
        porEstabelecimento[estabelecimento['nome'] as String] = areas;
      }
      if (!mounted) return;
      setState(() {
        indicadores = calculados;
        _indicadoresGerais = calculados;
        indicadoresPorEstabelecimento = porEstabelecimento;
        estabelecimentoSelecionado = _todosEstabelecimentos;
        isLoading = false;
        mensagemErro = null;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mensagemErro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (indicadores.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagemErro ?? 'Nenhum dado encontrado'),
            if (widget.modoAdministrativo) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => isLoading = true);
                  carregarDados();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dashboard de completude dos dados RHC ICI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: abrirPainel,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir Painel OncoPed'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _baixarXlsx,
                  icon: const Icon(Icons.table_view),
                  label: const Text('Baixar XLSX'),
                ),
              ],
            ),
            if (widget.modoAdministrativo) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => isLoading = true);
                  carregarDados();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar dados públicos'),
              ),
            ],
            const SizedBox(height: 30),
            _buildFiltroEstabelecimento(),
            const SizedBox(height: 20),
            _buildPainelAtencao(),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qualidade dos Dados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Clique em uma seção para ver todas as variáveis.'),
            ),
            const SizedBox(height: 20),
            ...indicadores.entries.map(
              (entry) => _buildCard(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroEstabelecimento() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DropdownButtonFormField<String>(
          key: ValueKey(estabelecimentoSelecionado),
          initialValue: estabelecimentoSelecionado,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Estabelecimento',
            prefixIcon: Icon(Icons.local_hospital_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: _todosEstabelecimentos,
              child: Text('Todos os estabelecimentos'),
            ),
            ...indicadoresPorEstabelecimento.keys.map(
              (nome) => DropdownMenuItem<String>(
                value: nome,
                child: Text(nome, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: indicadoresPorEstabelecimento.isEmpty
              ? null
              : (nome) {
                  if (nome == null) return;
                  setState(() {
                    estabelecimentoSelecionado = nome;
                    indicadores = nome == _todosEstabelecimentos
                        ? _indicadoresGerais
                        : indicadoresPorEstabelecimento[nome]!;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildPainelAtencao() {
    final campos = _camposQuePrecisamAtencao;
    if (campos.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        border: Border.all(color: const Color(0xFFFFC857)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFC56A00)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Variáveis que precisam de atenção',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'As 5 variáveis com menor completude no último levantamento.',
          ),
          const SizedBox(height: 14),
          ...campos.asMap().entries.map(
                (entry) => _buildItemAtencao(entry.key + 1, entry.value),
              ),
        ],
      ),
    );
  }

  Widget _buildItemAtencao(int posicao, _CampoAtencao campo) {
    final faltantes = campo.indicador.total - campo.indicador.preenchidas;
    final cor = campo.percentual < 50
        ? const Color(0xFFC62828)
        : campo.percentual < 75
            ? const Color(0xFFEF6C00)
            : const Color(0xFF9A6700);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: cor, width: 5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: cor.withValues(alpha: 0.12),
            foregroundColor: cor,
            child: Text(
              '$posicao',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campo.indicador.rotulo,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  campo.area,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${campo.percentual.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: cor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('$faltantes faltantes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String area, _IndicadorArea indicador) {
    final percentual = calcularPercentual(
      indicador.preenchidas,
      indicador.total,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(15),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        title: Text(
          area,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildResumo(
            indicador.preenchidas,
            indicador.total,
            percentual,
          ),
        ),
        children: [
          const Divider(),
          ...indicador.campos.map(_buildIndicadorCampo),
        ],
      ),
    );
  }

  Widget _buildResumo(int preenchidas, int total, double percentual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: percentual / 100, minHeight: 8),
        const SizedBox(height: 10),
        Text('Preenchidas: $preenchidas / $total'),
        Text('Completude: ${percentual.toStringAsFixed(1)}%'),
        Text('Faltantes: ${total - preenchidas}'),
      ],
    );
  }

  Widget _buildIndicadorCampo(_IndicadorCampo indicador) {
    final percentual = calcularPercentual(
      indicador.preenchidas,
      indicador.total,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indicador.rotulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(value: percentual / 100, minHeight: 6),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                  'Preenchidas: ${indicador.preenchidas} / ${indicador.total}'),
              Text('Completude: ${percentual.toStringAsFixed(1)}%'),
              Text('Faltantes: ${indicador.total - indicador.preenchidas}'),
            ],
          ),
        ],
      ),
    );
  }
}
