class Registro {
  final int? id;
  final DateTime dataHora;
  final double latitude, longitude, precisao;
  final String observacao, caminhoDaFoto;

  const Registro({
    this.id,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.observacao,
    required this.caminhoDaFoto,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'data_hora': dataHora.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'precisao': precisao,
    'observacao': observacao,
    'caminho_da_foto': caminhoDaFoto,
  };

  factory Registro.fromMap(Map<String, Object?> map) => Registro(
    id: map['id'] as int,
    dataHora: DateTime.parse(map['data_hora'] as String).toLocal(),
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    precisao: (map['precisao'] as num).toDouble(),
    observacao: map['observacao'] as String,
    caminhoDaFoto: map['caminho_da_foto'] as String,
  );

  String get dataFormatada {
    final d = dataHora.toLocal();
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} às ${dois(d.hour)}:${dois(d.minute)}';
  }

  String get coordenadas =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
