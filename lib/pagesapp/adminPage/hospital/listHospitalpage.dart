import 'package:flutter/material.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';

class ListaHospitaisScreen extends StatelessWidget {
  const ListaHospitaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding =
        Responsive.isDesktop(context) ? 500.0 : 20.0;
    final double verticalPadding = Responsive.isDesktop(context) ? 50.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Hospitais'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>( 
          future: HospitalServicer().buscarHospitais(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar hospitais'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum hospital encontrado.'));
            }

            List<Map<String, dynamic>> hospitais = snapshot.data!;
            return ListView.builder(
              itemCount: hospitais.length,
              itemBuilder: (context, index) {
                var hospital = hospitais[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: Text(
                        hospital['nome_hospital'] ?? 'Nome não disponível'),
                    subtitle: Text(
                      'ID: ${hospital['id_hospital'] ?? 'N/A'}\n'
                      'Token: ${hospital['token_hospital'] ?? 'N/A'}\n'
                      'Email do usuário: ${hospital['user_email'] ?? 'N/A'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Exibe o diálogo para editar
                            _showEditDialog(context, hospital);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Exclui o hospital
                            _deleteHospital(context, hospital['id_hospital']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Método para mostrar o pop-up de edição
  void _showEditDialog(BuildContext context, Map<String, dynamic> hospital) {
    final nomeController =
        TextEditingController(text: hospital['nome_hospital']);
    final tokenController =
        TextEditingController(text: hospital['token_hospital']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Hospital'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Hospital',
                  ),
                ),
                TextField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Token do Hospital',
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
                // Salva as alterações no hospital
                HospitalServicer().editarHospital(
                  context,
                  id_hospital: hospital['id_hospital'],
                  nome_hospital: nomeController.text,
                  token_hospital: tokenController.text,
                );
                Navigator.of(context).pop(); // Fecha o diálogo após salvar
              },
            ),
          ],
        );
      },
    );
  }

  // Método para excluir o hospital
  void _deleteHospital(BuildContext context, String? idHospital) {
    if (idHospital != null) {
      HospitalServicer().deletarHospital(context, id_hospital: idHospital);
    }
  }
}
