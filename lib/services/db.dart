import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DB {

    static Database _db;

    static int get _version => 1;

    static Future<void> init() async {

        if (_db != null) { return; }

        try {
            String _path = await getDatabasesPath() + 'db_mylab';
            _db = await openDatabase(_path, version: _version, onCreate: onCreate);
        }
        catch(ex) { 
            print(ex);
        }
    }

    static void onCreate(Database db, int version) async =>
        await db.execute('CREATE TABLE projects (id INTEGER PRIMARY KEY NOT NULL, name STRING, data STRING)');

    static Future<List<Map<String, dynamic>>> query(String table) async => _db.query(table);

    static Future readByName(String table, String name) async {
        final sql = '''SELECT * FROM ${table} WHERE name == "${name}"''';
        final res = await _db.rawQuery(sql);
        return res[0];
    }


    static Future<int> insert(String table, DBitem model) async => 
        await _db.insert(table, model.toMap());

    static Future<int> update(String table, DBitem model) async =>
        await _db.update(table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);

    static Future<int> delete(String table, DBitem model) async =>
        await _db.delete(table, where: 'id = ?', whereArgs: [model.id]);
}

class DBitem{

    static String table = 'projects';

    int id;
    String name;
    List<List> data;

    DBitem({ this.id, this.name, this.data });

    Map<String, dynamic> toMap() {

        Map<String, dynamic> map = {
            'name': name,
            'data': data.toString()
        };

        if (id != null) { map['id'] = id; }
        return map;
    }

    static DBitem fromMap(Map<String, dynamic> map) {
        
        List<List> itemData = List.from(jsonDecode(map['data']));

        List<List<double>> aux = [];
        for (var i = 0; i < itemData.length ; i++) {
          aux.add([]);
          for (var j = 0; j < itemData[0].length; j++) {
            aux[i].add(itemData[i][j].toDouble());
          } 
        }

        return DBitem(
            id: map['id'],
            name: map['name'],
            data: aux
        );
    }

}