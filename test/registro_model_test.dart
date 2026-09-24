import 'package:flutter_test/flutter_test.dart';
import 'package:senaicheckln/registro_model.dart';

void main() {
  test(
    'preserva os dados e o instante ao converter para SQLite e recuperar',
    () {
      final registro = Registro(
        id: 7,
        dataHora: DateTime.parse('2026-09-15T11:30:00-03:00'),
        latitude: -23.55052,
        longitude: -46.633308,
        precisao: 8.5,
        observacao: 'Inspeção concluída — portão 2',
        caminhoDaFoto: '/imagens/registro_7.jpg',
      );
      final recuperado = Registro.fromMap(registro.toMap());
      expect(recuperado.id, 7);
      expect(recuperado.dataHora.isAtSameMomentAs(registro.dataHora), isTrue);
      expect(recuperado.latitude, registro.latitude);
      expect(recuperado.longitude, registro.longitude);
      expect(recuperado.precisao, 8.5);
      expect(recuperado.observacao, registro.observacao);
      expect(recuperado.caminhoDaFoto, registro.caminhoDaFoto);
    },
  );

  test('novo registro deixa o SQLite gerar o id e aceita observação vazia', () {
    final registro = Registro(
      dataHora: DateTime(2026, 9, 15, 8, 5),
      latitude: 0,
      longitude: 0,
      precisao: 10,
      observacao: '',
      caminhoDaFoto: '/foto.jpg',
    );
    expect(registro.toMap().containsKey('id'), isFalse);
    expect(registro.dataFormatada, '15/09/2026 às 08:05');
    expect(registro.coordenadas, '0.000000, 0.000000');
  });
}
