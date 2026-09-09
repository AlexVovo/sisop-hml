import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/dashboardPage/DashboardPage.dart';
import 'package:regsitroweb/pagesapp/adminPage/hospital/hospitalPage.dart';
import 'package:regsitroweb/pagesapp/adminPage/hospital/listHospitalpage.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/listUser.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/logs_page.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/userPage.dart';
import 'package:url_launcher/url_launcher.dart';

class Adminpagewidget extends StatefulWidget {
  const Adminpagewidget({super.key});

  @override
  State<Adminpagewidget> createState() => _AdminpagewidgetState();
}

class _AdminpagewidgetState extends State<Adminpagewidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: <Widget>[
                  buildCustomButton(
                    icon: Icons.person_add,
                    label: 'Cadastrar usuário',
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Userpage()),
                      );
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.add,
                    label: 'Cadastrar hospital',
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Hospitalpage()),
                      );
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.person,
                    label: 'Meus usuários',
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListaUsuariosScreen(),
                        ),
                      );
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.local_hospital_sharp,
                    label: 'Meus hospitais',
                    color: Colors.red,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListaHospitaisScreen(),
                        ),
                      );
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.history,
                    label: 'Visualizar Logs',
                    color: Colors.purple,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogPacientesPage(),
                        ),
                      );
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Acessar Dashboard RHC ICI',
                    color: Colors.cyan,
                    onPressed: () async {
                      await _abrirDashboard();
                    },
                  ),
                  buildCustomButton(
                    icon: Icons.dashboard,
                    label: 'Dashboard de completude dos dados RHC ICI',
                    color: const Color.fromARGB(255, 0, 128, 255),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirDashboard() async {
    final Uri url = Uri.parse(
      'https://paineloncoped.ici.ong/painel-rhc-ici',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Não foi possível abrir o dashboard.');
    }
  }

  Widget buildCustomButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 180),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      icon: Icon(
        icon,
        size: 40,
        color: Colors.white,
      ),
      label: Text(
        label,
        textAlign: TextAlign.center,
        selectionColor: Colors.white,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

//Código original2
/* import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/hospital/hospitalPage.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/listUser.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/userPage.dart';

class Adminpagewidget extends StatefulWidget {
  const Adminpagewidget({super.key});

  @override
  State<Adminpagewidget> createState() => _AdminpagewidgetState();
}

class _AdminpagewidgetState extends State<Adminpagewidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Admin Page',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20.0, // Espaçamento horizontal entre os botões
              runSpacing: 20.0, // Espaçamento vertical entre os botões
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Userpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Cadastrar usuário',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Hospitalpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Cadastrar hospital',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListaUsuariosScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.person),
                  label: const Text(
                    'Meus usuários',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.local_hospital_sharp),
                  label: const Text(
                    'Meus hospitais',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} */
//Código original1
/* import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/adminPage/hospital/hospitalPage.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/listUser.dart';
import 'package:regsitroweb/pagesapp/adminPage/user/userPage.dart';

class Adminpagewidget extends StatefulWidget {
  const Adminpagewidget({super.key});

  @override
  State<Adminpagewidget> createState() => _AdminpagewidgetState();
}

class _AdminpagewidgetState extends State<Adminpagewidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Admin Page',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Preto
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Userpage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(
                            200, 200), // Tamanho fixo para todos os botões
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        'Cadastrar Usuário',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Hospitalpage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(
                            200, 200), // Tamanho fixo para todos os botões
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Cadastrar Hospital',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ListaUsuariosScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(
                            200, 200), // Tamanho fixo para todos os botões
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.person),
                      label: const Text(
                        'Meus Usuários',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(
                            200, 200), // Tamanho fixo para todos os botões
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.local_hospital_sharp),
                      label: const Text(
                        'Meus Hospitais',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
 */
