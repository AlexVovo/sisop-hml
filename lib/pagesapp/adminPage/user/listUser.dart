import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/EditarUsuarioScreen.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:regsitroweb/service/user_servicer.dart';

class ListaUsuariosScreen extends StatefulWidget {
  const ListaUsuariosScreen({super.key});

  @override
  State<ListaUsuariosScreen> createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final resultado = await UserServicer().buscarTodosUsers();
      if (!mounted) return;
      setState(() {
        usuarios = resultado;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      // use o context do State
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuários: $e')),
        );
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Timestamp? _extrairUltimoAcesso(dynamic acessos) {
    if (acessos is List && acessos.isNotEmpty) {
      final last = acessos.last;
      if (last is Map && last['data'] is Timestamp) {
        return last['data'] as Timestamp;
      }
    }
    return null;
  }

  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    // Usa o context do State
    final bool? atualizado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditarUsuarioScreen(usuario: usuario),
      ),
    );

    if (!mounted) return;

    if (atualizado == true) {
      await _carregarUsuarios();
      if (!mounted) return;

      // Agenda o SnackBar após o rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Lista atualizada')),
        );
      });
    }
  }

  Future<void> _deletarUsuario(String email) async {
    try {
      await UserServicer().deletarUser(email, context); // service sem UI
      if (!mounted) return;
      await _carregarUsuarios();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Usuário deletado com sucesso')),
        );
      });
    } catch (e) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Erro ao deletar: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.isDesktop(context) ? 500.0 : 20.0;
    final verticalPadding = Responsive.isDesktop(context) ? 50.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de usuários'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : usuarios.isEmpty
                ? const Center(child: Text('Nenhum usuário encontrado.'))
                : ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (itemCtx, index) {
                      final usuario = usuarios[index];
                      final Timestamp? ultimoAcesso =
                          _extrairUltimoAcesso(usuario['acessos']);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(usuario['email']?.toString() ??
                              'Email não disponível'),
                          subtitle: Text(
                              'Último acesso: ${_formatTimestamp(ultimoAcesso)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarUsuario(
                                    usuario), // não passa o context do item
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deletarUsuario(
                                    usuario['email']?.toString() ?? ''),
                                tooltip: 'Excluir',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
