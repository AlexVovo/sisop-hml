import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regsitroweb/service/user_servicer.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarUsuarioScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController nomeController;
  late TextEditingController chaveAuthController;

  /// Lista de nomes de hospitais selecionados
  late List<String> hospitaisSelecionados;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    emailController =
        TextEditingController(text: widget.usuario['email'] ?? '');
    nomeController = TextEditingController(text: widget.usuario['nome'] ?? '');
    chaveAuthController =
        TextEditingController(text: widget.usuario['chaveauth'] ?? '');

    final hs = widget.usuario['hospitaisSelecionados'];
    hospitaisSelecionados =
        (hs is List) ? hs.map((e) => e.toString()).toList() : <String>[];
  }

  @override
  void dispose() {
    emailController.dispose();
    nomeController.dispose();
    chaveAuthController.dispose();
    super.dispose();
  }

  void _toggleHospital(String hospital, bool selecionado) {
    setState(() {
      if (selecionado) {
        if (!hospitaisSelecionados.contains(hospital)) {
          hospitaisSelecionados.add(hospital);
        }
      } else {
        hospitaisSelecionados.remove(hospital);
      }
    });
  }

  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await UserServicer().atualizarUser({
        'uid': widget.usuario['uid'],
        'email': emailController.text.trim(),
        'nome': nomeController.text.trim(),
        'chaveauth': chaveAuthController.text.trim(),
        'hospitaisSelecionados': hospitaisSelecionados,
      });

      if (!mounted) return;
      // Deixa a SnackBar para a tela anterior (Lista) quando receber `true`
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      // Evita o crash usando maybeOf
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Usuário')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EMAIL
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    v = v?.trim();
                    if (v == null || v.isEmpty) return 'Informe o email';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // NOME
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Informe o nome';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CHAVE AUTH
                TextFormField(
                  controller: chaveAuthController,
                  decoration: const InputDecoration(
                    labelText: 'Chave Auth',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Hospitais Selecionados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // Lista de hospitais
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('hospitais')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (snapshot.hasError) {
                      return Text(
                          'Erro ao carregar hospitais: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('Nenhum hospital encontrado.');
                    }

                    final hospitais = snapshot.data!.docs
                        .map((doc) => (doc['nome_hospital'] ?? '').toString())
                        .where((s) => s.isNotEmpty)
                        .toList()
                      ..sort(
                          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                    return Column(
                      children: hospitais.map((hospital) {
                        final marcado =
                            hospitaisSelecionados.contains(hospital);
                        return CheckboxListTile(
                          title: Text(hospital),
                          value: marcado,
                          onChanged: (bool? selecionado) {
                            if (selecionado != null) {
                              _toggleHospital(hospital, selecionado);
                            }
                          },
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          onPressed: _salvarUsuario,
                          label: const Text('Salvar'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
