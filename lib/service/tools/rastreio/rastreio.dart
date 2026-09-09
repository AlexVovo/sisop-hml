import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RastreioPage extends StatelessWidget {
  const RastreioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento de Usuários'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user_tracking').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum registro de rastreamento encontrado.'),
            );
          }

          final trackingData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trackingData.length,
            itemBuilder: (context, index) {
              final trackingEntry = trackingData[index];
              final data = trackingEntry.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  'Usuário: ${data['user_email'] ?? 'Desconhecido'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Ação: ${data['action']}\n'
                  'Data/Hora: ${data['timestamp'] ?? 'Não especificado'}',
                ),
                leading: const Icon(Icons.person),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
