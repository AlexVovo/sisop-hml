import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class LogPacientesPage extends StatefulWidget {
  const LogPacientesPage({super.key});

  @override
  _LogPacientesPageState createState() => _LogPacientesPageState();
}

class _LogPacientesPageState extends State<LogPacientesPage> {
  String searchQuery = '';

  Set<String> selecionados = {}; // guarda os IDs selecionados

  ///// colocar nos services as funcoes de operacao com firebase /////

  Future<void> deletarLog(String idpaciente) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('logs')
          .where('id_paciente', isEqualTo: idpaciente)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log deletado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log não encontrado.')),
        );
      }
    } catch (e) {
      print('Erro ao deletar Log: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar Log.')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> logs) {
    final nomeController = TextEditingController(text: logs['nome_log']);
    final tokenController = TextEditingController(text: logs['token_log']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Logs'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Paciente',
                  ),
                ),
                TextField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'ID do paciente',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                // Aqui só chamei deletarLog mesmo, já que tu não está editando
                deletarLog(logs['id_paciente']);
                Navigator.of(context).pop(); // Fecha o diálogo após salvar
              },
            ),
          ],
        );
      },
    );
  }


  // TODO criar um logs_page_service ou algo assim pra colocar essa função abaixo

  Future<void> deletarSelecionados() async {
    try {
      for (var id in selecionados) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('logs')
            .where('id_paciente', isEqualTo: id)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // isso aqui é pra voltar para o estado inicial
      setState(() {
        selecionados.clear();
      });

      // Mensagem de retorno caso dê certo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs deletados com sucesso!')),
      );
    } catch (e) {
      // Mensagem de retorno caso dê errado
      print('Erro ao deletar logs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar logs.')),
      );
    }
  }

// Bem, essa daqui é a basicamente a construção da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log de Pacientes'),
      ),
      body: SingleChildScrollView(
        padding: Responsive.isDesktop(context)
            ? const EdgeInsets.only(right: 400, left: 400, top: 50)
            : const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // botão para deletar logs selecionados (botao superior)
            ElevatedButton.icon(
              onPressed: selecionados.isEmpty ? null : deletarSelecionados,
              icon: const Icon(Icons.delete),
              label: const Text("Deletar Selecionados"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              // barra de pesquisa, já tava aqui
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome do paciente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('logs')
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum log encontrado.'));
                }

                var logs = snapshot.data!.docs
                    .where((doc) {
                      var log = doc.data() as Map<String, dynamic>;
                      var nomePaciente =
                          log['nome_paciente']?.toLowerCase() ?? '';
                      return nomePaciente.contains(searchQuery);
                    })
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var log = logs[index];
                    // salvado o id do paciente (auto explicatico)
                    var idPaciente = log['id_paciente'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      // o bendito checkbox
                      child: CheckboxListTile(
                        value: selecionados.contains(idPaciente),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              selecionados.add(idPaciente);
                            } else {
                              selecionados.remove(idPaciente);
                            }
                          });
                        },
                        title: Text('Paciente: ${log['nome_paciente']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usuário: ${log['usuario']}'),
                            Text('Tipo: ${log['tipo']}'),
                            if (log['tipo'] == 'atualizacao' &&
                                log['alteracoes'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    (log['alteracoes'] as Map<String, dynamic>)
                                        .entries
                                        .map((e) {
                                  var valorAlteracao = e.value != null
                                      ? e.value.toString()
                                      : 'Alteração não disponível';
                                  return Text(
                                    '${e.key}: $valorAlteracao',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  );
                                }).toList(),
                              ),
                            Text(
                              'Data: ${log['data'] != null ? log['data'].toDate().toString() : 'Desconhecida'}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
