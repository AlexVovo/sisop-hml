import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:regsitroweb/pagesapp/PacientesPage/pacientes.dart';
import 'package:regsitroweb/pagesapp/cadastroPage/cadastro_page.dart';
import 'package:regsitroweb/service/tools/auth/auth_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import 'package:url_launcher/url_launcher.dart';

class WidgetHome extends StatefulWidget {
  final String hospital; // Recebe o hospital selecionado

  const WidgetHome({super.key, required this.hospital});

  @override
  State<WidgetHome> createState() => _WidgetHomeState();
}

const String url = 'https://dashoncologico.streamlit.app/';
const String url2 = 'https://ici.ong/';

class _WidgetHomeState extends State<WidgetHome> {
  bool _showUserPanel = false;
  @override
  Widget build(BuildContext context) {
    String? email = AuthenticationService(FirebaseAuth.instance).getName();
    AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showUserPanel = !_showUserPanel;
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Bem-vindo ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '$email',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Hospital selecionado: ',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: widget.hospital ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      backgroundColor: Colors.blueAccent, // marca só o nome
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
                child: GridView.count(
                    crossAxisCount: 2, // Define duas colunas
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    padding: const EdgeInsets.all(5),
                    childAspectRatio: Responsive.isDesktop(context) ? 2.5 : 1.0,
                    shrinkWrap: true,
                    children: [
                  _buildElevatedButton(
                    context,
                    Icons.person_add,
                    'Cadastrar paciente',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroPacienteForm(
                                  hospitalselecionado: widget.hospital,
                                )),
                      );
                    },
                  ),
                  _buildElevatedButton(
                    context,
                    Icons.person,
                    'Meus pacientes',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PatientListPage(
                                  hospitalselecionado: widget.hospital,
                                )),
                      );
                    },
                  ),
                  _buildElevatedButton(
                    context,
                    Icons.dashboard,
                    'Acessar dashboards',
                    () => _launchURL(
                        "https://paineloncoped.ici.ong/painel-rhc-ici"),
                  ),
                  _buildElevatedButton(
                    context,
                    Icons.health_and_safety,
                    'Acessar site do ICI',
                    () => _launchURL(url2),
                  ),
                ])),
            const SizedBox(height: 50),
            Image.asset('assets/parceiros.png')
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildElevatedButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 5), // Reduzindo padding
        minimumSize: const Size(double.infinity, 50), // Reduzindo altura mínima
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8), // Bordas levemente arredondadas
        ),
      ),
      icon: Icon(icon, size: 20), // Ícone menor
      label: Text(
        label,
        style: const TextStyle(fontSize: 16), // Texto menor
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
