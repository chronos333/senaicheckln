import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'registro_model.dart';

class RegistroDbhelper {
  static final instance = RegistroDbhelper();
  Future<Database> get database async => openDatabase(
    join(await getDatabasesPath(), 'senai_checkin.db'),
    version: 1,
    onCreate: (db, version) => db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT, data_hora TEXT NOT NULL,
        latitude REAL NOT NULL, longitude REAL NOT NULL, precisao REAL NOT NULL,
        observacao TEXT NOT NULL, caminho_da_foto TEXT NOT NULL
      )
    '''),
  );
  Future<int> inserir(Registro registro) async =>
      (await database).insert('registros', registro.toMap());
  Future<List<Registro>> listar() async {
    final maps = await (await database).query(
      'registros',
      orderBy: 'data_hora DESC, id DESC',
    );
    return maps.map(Registro.fromMap).toList();
  }
}
