import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:regsitroweb/service/tcle_service.dart';

class TcleSignPage extends StatefulWidget {
  const TcleSignPage({super.key, required this.token});

  final String token;

  @override
  State<TcleSignPage> createState() => _TcleSignPageState();
}

class _TcleSignPageState extends State<TcleSignPage> {
  final _signerController = TextEditingController();
  final List<Offset?> _points = [];
  bool _accepted = false;
  bool _saving = false;

  @override
  void dispose() {
    _signerController.dispose();
    super.dispose();
  }

  Future<void> _sign() async {
    if (!_accepted ||
        _signerController.text.trim().isEmpty ||
        _points.whereType<Offset>().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Informe o nome, aceite o termo e assine.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await TcleService().sign(
        token: widget.token,
        signerName: _signerController.text,
        signaturePoints:
            _points.map((point) => <double?>[point?.dx, point?.dy]).toList(),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível assinar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termo de Consentimento – TCLE')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: TcleService().watch(widget.token),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Link de TCLE inválido.'));
          }
          if (data['status'] == 'signed') {
            return const _SignedConfirmation();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'TERMO DE CONSENTIMENTO LIVRE E ESCLARECIDO (TCLE)',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Projeto CAAE: 90605725.6.1001.5327',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text('Participante: ${data['patientName'] ?? ''}'),
                    Text('Responsável: ${data['responsibleName'] ?? ''}'),
                    const SizedBox(height: 20),
                    const Text(
                      'A criança ou adolescente pela qual você é responsável '
                      'está sendo convidada a participar de uma pesquisa para '
                      'desenvolver um sistema de registro hospitalar de câncer '
                      'infantojuvenil. A participação é voluntária e você pode '
                      'retirar o consentimento conforme as orientações da equipe.',
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _accepted,
                      onChanged: (value) =>
                          setState(() => _accepted = value ?? false),
                      title: const Text(
                        'Li e compreendi as informações apresentadas neste termo.',
                      ),
                    ),
                    TextField(
                      controller: _signerController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo do responsável',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Assinatura do responsável:'),
                    const SizedBox(height: 6),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: GestureDetector(
                        onPanStart: (details) => setState(
                          () => _points.add(details.localPosition),
                        ),
                        onPanUpdate: (details) => setState(
                          () => _points.add(details.localPosition),
                        ),
                        onPanEnd: (_) => setState(() => _points.add(null)),
                        child: CustomPaint(
                          painter: _SignaturePainter(_points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(_points.clear),
                        child: const Text('Limpar assinatura'),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _saving ? null : _sign,
                      icon: const Icon(Icons.draw),
                      label: Text(
                        _saving ? 'Salvando...' : 'Confirmar assinatura',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ambiente de homologação: não utilize dados reais.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < points.length - 1; index++) {
      final current = points[index];
      final next = points[index + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class _SignedConfirmation extends StatelessWidget {
  const _SignedConfirmation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 16),
          Text(
            'Termo assinado com sucesso!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('A assinatura foi registrada no ambiente de homologação.'),
        ],
      ),
    );
  }
}
