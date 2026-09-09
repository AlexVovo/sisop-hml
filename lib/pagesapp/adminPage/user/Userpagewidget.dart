import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Pacote para multi-seleção
import 'package:regsitroweb/pagesapp/adminPage/adminPage.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:validatorless/validatorless.dart';
import '../../../service/user_servicer.dart';

class Userpagewidget extends StatefulWidget {
  const Userpagewidget({super.key});

  @override
  State<Userpagewidget> createState() => _UserpagewidgetState();
}

class _UserpagewidgetState extends State<Userpagewidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _senhacontroller = TextEditingController();
  final _formKey2 = GlobalKey<FormState>();
  bool _obscureText = true;

  /// Hospitais carregados do Firestore (cada item deve ter ao menos: id_hospital, nome_hospital)
  List<Map<String, dynamic>> _hospitais = [];

  /// Aqui vamos guardar **apenas os nomes** selecionados
  List<String> _hospitaisSelecionados = [];

  @override
  void initState() {
    super.initState();
    _carregarHospitais(); // Carregar hospitais ao iniciar o widget
  }

  // Função para carregar hospitais do Firestore
  Future<void> _carregarHospitais() async {
    final hospitais = await HospitalServicer().buscarHospitais();
    // garantindo o tipo
    setState(() {
      _hospitais = hospitais.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Cadastro usuário',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),

              // Campo de ID do usuário
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID do usuário',
                  border: OutlineInputBorder(),
                ),
                validator: Validatorless.required('campo obrigatório'),
              ),
              const SizedBox(height: 20),

              // Campo de E-mail do usuário
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail do Usuário',
                  border: OutlineInputBorder(),
                ),
                validator: Validatorless.required('campo obrigatório'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Campo de Senha
              TextFormField(
                validator: Validatorless.required(
                    "Por favor, preencha o campo de senha"),
                controller: _senhacontroller,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
              ),
              const SizedBox(height: 20),

              // Campo de seleção múltipla de hospitais
              MultiSelectDialogField<String>(
                // Agora o value é o **nome** do hospital
                items: _hospitais
                    .map(
                      (hospital) => MultiSelectItem<String>(
                        (hospital['nome_hospital'] ?? '').toString(),
                        (hospital['nome_hospital'] ?? '').toString(),
                      ),
                    )
                    .toList(),
                title: const Text("Hospitais"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                buttonText: const Text("Selecione os hospitais"),
                onConfirm: (results) {
                  setState(() {
                    // results já são os NOMES
                    _hospitaisSelecionados = results;
                  });
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate()) {
                    _doCadastrarUsuarios(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doCadastrarUsuarios(BuildContext context) {
    print('ID: ${_idController.text}');
    print('Hospitais Selecionados (NOMES): $_hospitaisSelecionados');

    UserServicer()
        .cadastrarUser(
      _emailController.text,
      _senhacontroller.text,
      context,
      _idController.text,
      _hospitaisSelecionados, // agora envia a lista de NOMES
    )
        .then((value) async {
      if (value) {
        // Navegar para a página de admin
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Adminpage()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }
}
