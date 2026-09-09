class Neoplasia {
  final String diagnostico;
  final String classificacao;
  final String estadiamento;

  Neoplasia({
    required this.diagnostico,
    required this.classificacao,
    required this.estadiamento,
  });

  factory Neoplasia.fromJson(Map<String, dynamic> json) {
    return Neoplasia(
      diagnostico: json['Diagnóstico'],
      classificacao: json['Classificação'],
      estadiamento: json['Estadiamento'],
    );
  }
}
