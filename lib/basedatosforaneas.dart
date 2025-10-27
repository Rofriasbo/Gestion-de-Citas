import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:agenda/persona.dart';
import 'package:agenda/cita.dart';

class DB {
  static Future<Database> _conectarDB() async {
    return openDatabase(
      join(await getDatabasesPath(), "ejercicio2.db"),
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE PERSONA(
            IDPERSONA INTEGER PRIMARY KEY AUTOINCREMENT,
            NOMBRE TEXT NOT NULL,
            TELEFONO TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE CITA(
            IDCITA INTEGER PRIMARY KEY AUTOINCREMENT,
            LUGAR TEXT NOT NULL,
            FECHA TEXT,
            HORA TEXT,
            ANOTACIONES TEXT,
            IDPERSONA INTEGER,
            FOREIGN KEY (IDPERSONA)
              REFERENCES PERSONA(IDPERSONA)
              ON DELETE CASCADE
              ON UPDATE CASCADE
          )
        ''');
      },
    );
  }
  static Future<int> insertarPersona(Persona p) async {
    Database db = await _conectarDB();
    return db.insert("PERSONA", p.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> actualizarPersona(Persona p) async {
    Database db = await _conectarDB();
    return db.update("PERSONA", p.toJSON(),
        where: "IDPERSONA=?", whereArgs: [p.idpersona]);
  }

  static Future<int> eliminarPersona(int idpersona) async {
    Database db = await _conectarDB();
    return db.delete("PERSONA", where: "IDPERSONA=?", whereArgs: [idpersona]);
  }

  static Future<List<Persona>> mostrarPersonas() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("PERSONA");
    return List.generate(
      datos.length,
          (i) => Persona(
        idpersona: datos[i]['IDPERSONA'],
        nombre: datos[i]['NOMBRE'],
        telefono: datos[i]['TELEFONO'],
      ),
    );
  }
  static Future<int> insertarCita(Cita c) async {
    Database db = await _conectarDB();
    return db.insert("CITA", c.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> actualizarCita(Cita c) async {
    Database db = await _conectarDB();
    return db.update("CITA", c.toJSON(),
        where: "IDCITA=?", whereArgs: [c.idcita]);
  }

  static Future<int> eliminarCita(int idcita) async {
    Database db = await _conectarDB();
    return db.delete("CITA", where: "IDCITA=?", whereArgs: [idcita]);
  }

  static Future<List<Cita>> mostrarCitas() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("CITA");
    return List.generate(
      datos.length,
          (i) => Cita(
        idcita: datos[i]['IDCITA'],
        lugar: datos[i]['LUGAR'],
        fecha: datos[i]['FECHA'],
        hora: datos[i]['HORA'],
        anotaciones: datos[i]['ANOTACIONES'],
        idpersona: datos[i]['IDPERSONA'],
      ),
    );
  }
  static Future<List<Map<String, dynamic>>> mostrarCitasConPersona() async {
    Database db = await _conectarDB();
    return db.rawQuery('''
      SELECT CITA.IDCITA, CITA.LUGAR, CITA.FECHA, CITA.HORA, CITA.ANOTACIONES,
             PERSONA.NOMBRE AS NOMBRE_PERSONA, PERSONA.TELEFONO AS TELEFONO_PERSONA
      FROM CITA
      INNER JOIN PERSONA ON CITA.IDPERSONA = PERSONA.IDPERSONA
    ''');
  }
}
