import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/cadastroPage/widgetCadastro.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/tools/size/sizescreen.dart';

class CadastroPacienteForm extends StatefulWidget {
  final String hospitalselecionado;
  const CadastroPacienteForm({
    super.key,
    required this.hospitalselecionado,
  });

  @override
  State<CadastroPacienteForm> createState() => _CadastroPacienteFormState();
}

class _CadastroPacienteFormState extends State<CadastroPacienteForm> {
  final GlobalKey<WidgetCadastroPacienteFormState> _cadastroFormKey =
      GlobalKey<WidgetCadastroPacienteFormState>();
  DraftSaveUiState _draftSaveState = DraftSaveUiState.idle;
  Duration _statusDuration = const Duration(milliseconds: 1400);
  int _savedPingTick = 0;

  Future<void> _abrirOpcoesTcle() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description_outlined),
            SizedBox(width: 8),
            Text('TCLE'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.send_outlined),
                title: Text('Enviar TCLE'),
                subtitle: Text('Disponível futuramente'),
                enabled: false,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Subir TCLE assinado'),
                subtitle: const Text(
                  'Selecione o PDF assinado manualmente pelos responsáveis.',
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  await _cadastroFormKey.currentState?.triggerSelecionarTcle();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _setDraftState(DraftSaveUiState state) {
    if (!mounted) return;
    setState(() {
      _draftSaveState = state;
      if (state == DraftSaveUiState.saved) {
        _savedPingTick++;
      }
      _statusDuration = state == DraftSaveUiState.saving
          ? const Duration(milliseconds: 350)
          : const Duration(milliseconds: 1400);
    });
  }

  Widget _buildCloudPingIcon() {
    return TweenAnimationBuilder<double>(
      key: ValueKey('saved-ping-$_savedPingTick'),
      tween: Tween(begin: 0.82, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, _) {
        final pulseScale = 1 + ((1 - scale) * 1.6);
        final pulseOpacity = ((1 - scale) * 0.65).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: pulseOpacity),
                  ),
                ),
              ),
              const Icon(
                Icons.cloud_done_outlined,
                size: 20,
                color: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraftSaveIndicator() {
    Widget child;

    switch (_draftSaveState) {
      case DraftSaveUiState.saving:
        child = const Row(
          key: ValueKey('saving'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 20),
            SizedBox(width: 8),
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Salvando...'),
          ],
        );
        break;
      case DraftSaveUiState.saved:
        child = Row(
          key: ValueKey('saved-$_savedPingTick'),
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCloudPingIcon(),
            const SizedBox(width: 8),
            const Text('Progresso salvo'),
          ],
        );
        break;
      case DraftSaveUiState.error:
        child = const Row(
          key: ValueKey('error'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 20, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro ao salvar'),
          ],
        );
        break;
      case DraftSaveUiState.idle:
        child = const SizedBox(
          key: ValueKey('idle'),
          width: 1,
          height: 1,
        );
        break;
    }

    return AnimatedSwitcher(
      duration: _statusDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Cadastro de paciente',
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: _buildDraftSaveIndicator()),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'fab-salvar-cadastro',
              onPressed: () {
                _cadastroFormKey.currentState?.triggerSalvarCadastro();
              },
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Salvar'),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: 'fab-limpar-cadastro',
              onPressed: () {
                _cadastroFormKey.currentState?.triggerLimparCampos();
              },
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Limpar'),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: 'fab-tcle-cadastro',
              onPressed: _abrirOpcoesTcle,
              backgroundColor: Colors.green.shade400,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.description_outlined),
              label: const Text('TCLE'),
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 20,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      right: 350.0, left: 350.0, top: 100, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetCadastroPacienteForm(
                        key: _cadastroFormKey,
                        hospitalselecionado: widget.hospitalselecionado,
                        onDraftSaveStateChanged: _setDraftState,
                      )
                    ],
                  ),
                ),
              ),
            if (!Responsive.isDesktop(context))
              Expanded(
                flex: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.screenHeight,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widgetCadastroPacienteForm(
                          key: _cadastroFormKey,
                          hospitalselecionado: widget.hospitalselecionado,
                          onDraftSaveStateChanged: _setDraftState,
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
