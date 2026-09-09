import 'package:flutter/material.dart';
import 'package:regsitroweb/pagesapp/PacientesPage/widgetPacientes.dart';
import 'package:regsitroweb/service/hospital_service.dart';
import 'package:regsitroweb/service/tools/size/sizeResponsive.dart';
import '../../model/patient_model.dart';
import '../../service/patient_service.dart';

class PatientListPage extends StatefulWidget {
  final String hospitalselecionado;

  const PatientListPage({super.key, required this.hospitalselecionado});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  Future<List<Patient>>? _patients;
  late List<Patient> _allPatients;
  late List<Patient> _filteredPatients;
  String _searchQuery = '';
  bool _showOnlyPatientsNeedingReview = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _patients = _loadPatients(); // <-- future memorizado corretamente
  }

  Future<List<Patient>> _loadPatients() async {
    await buscandotokenhospital();
    final service = PatientService(token!);

    List<Patient> patients = await service.fetchPatients();

    // Remove Duplicados pela combinação nome + data de atualização
    final Map<String, Patient> unique = {};

    for (var p in patients) {
      final key = "${p.nomepac}_${p.dataatualizacaocad}";
      unique[key] = p;
    }

    patients = unique.values.toList();

    // Ordena pacientes por data de cadastro (decrescente)
    patients.sort(
      (a, b) => DateTime.parse(b.dataatualizacaocad)
          .compareTo(DateTime.parse(a.dataatualizacaocad)),
    );

    _checkPatientsForReview(patients);

    _allPatients = patients;
    _filteredPatients = patients;

    return patients;
  }

  Future<void> buscandotokenhospital() async {
    token =
        await HospitalServicer().buscarTokenSmart(widget.hospitalselecionado);
    if (token == null) {
      debugPrint('Token inválido ou não encontrado.');
      throw Exception('Token não encontrado.');
    }
  }

  void _filterPatients(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      final normalizedQuery = _searchQuery.trim().toLowerCase();
      _filteredPatients = _allPatients.where((patient) {
        final matchesSearch = normalizedQuery.isEmpty ||
            patient.nomepac.toLowerCase().contains(normalizedQuery);
        final matchesReviewFilter =
            !_showOnlyPatientsNeedingReview || patient.needsReview;
        return matchesSearch && matchesReviewFilter;
      }).toList();
    });
  }

  void _checkPatientsForReview(List<Patient> patients) {
    final now = DateTime.now();

    for (var patient in patients) {
      try {
        final registrationDate = DateTime.parse(patient.dataatualizacaocad);
        final differenceInDays = now.difference(registrationDate).inDays;

        patient.needsReview = differenceInDays >= 180;
      } catch (e) {
        debugPrint('Erro ao interpretar a data de ${patient.nomepac}: $e');
        patient.needsReview = false;
      }
    }
  }

  Widget _buildReviewSummary() {
    final reviewCount =
        _allPatients.where((patient) => patient.needsReview).length;
    if (reviewCount == 0) return const SizedBox.shrink();

    final horizontalPadding = Responsive.isDesktop(context) ? 400.0 : 15.0;
    final label = reviewCount == 1
        ? '1 paciente precisa de revisão'
        : '$reviewCount pacientes precisam de revisão';

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
      child: Material(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF9A6700), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showOnlyPatientsNeedingReview =
                      !_showOnlyPatientsNeedingReview;
                  _applyFilters();
                },
                child: Text(
                  _showOnlyPatientsNeedingReview
                      ? 'Mostrar todos'
                      : 'Ver pendentes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 30),
            SizedBox(width: 8),
            Text('Meus pacientes'),
          ],
        ),
      ),

      // REMOVEI o onRefresh daqui — estava no lugar errado
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPatients();
          _applyFilters();
        },
        child: Column(
          children: [
            // Campo de busca desktop
            if (Responsive.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(right: 400, left: 400, top: 10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar pacientes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _filterPatients,
                ),
              ),

            // Campo de busca mobile
            if (!Responsive.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar pacientes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _filterPatients,
                ),
              ),

            if (_patients != null)
              FutureBuilder<List<Patient>>(
                future: _patients,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildReviewSummary();
                },
              ),

            Expanded(
              child: FutureBuilder<List<Patient>>(
                future: _patients, // <-- Future memorized OK
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum paciente encontrado'),
                    );
                  }

                  return ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          if (Responsive.isDesktop(context))
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                right: 400,
                                left: 400,
                                top: 10,
                              ),
                              child: widgetPatientListPage(
                                patient: _filteredPatients[index],
                                token: token,
                              ),
                            ),
                          if (!Responsive.isDesktop(context))
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                right: 15,
                                left: 15,
                                top: 10,
                              ),
                              child: widgetPatientListPage(
                                patient: _filteredPatients[index],
                                token: token,
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
