import 'package:flutter/material.dart';
import 'package:myLAB/services/db.dart';

class TableSimple extends StatefulWidget {
    TableSimple({Key key, @required this.projectName, }) : super(key: key);
    final String projectName;
    @override
    _TableSimpleState createState() => _TableSimpleState();
}

class _TableSimpleState extends State<TableSimple> {

  DBitem item;

  DataTable TABLE = DataTable(
    columns: [DataColumn(label: Text("N"))],
    rows: [],
  );

  void removeRow(int index) async {
      if (item.data[0].length > 1) for (var i = 0; i < item.data.length; i++) {
        item.data[i].removeAt(index);
      }
      DB.update('projects', item);
      refresh();
  }

  void removeColumn(int index) async {
      if (item.data.length > 1) item.data.removeAt(index);
      DB.update('projects', item);
      refresh();
  }

  void addRow(int index) async {
      for (var i = 0; i < item.data.length; i++) {
        item.data[i].insert(index,0.0);
      }
      DB.update('projects', item);
      refresh();
  }

  void addColumn(int index) async {
      List<double> aux = [];
      int l = item.data[0].length;
      item.data.insert(index,aux);
      for (var i = 0; i < l; i++) {
        item.data[index].add(2*i.toDouble());
      }
      DB.update('projects', item);
      refresh();
  }

  List<DataColumn> loadColumns()
  {
    var nColumns = 0;
    List<DataColumn> columns = [DataColumn(label: Text("N"))];
    if (item != null) nColumns = item.data.length;
    for (var i = 0; i < nColumns; i++) {
      columns.add(DataColumn(label: GestureDetector(
        onTap: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Remover Coluna $i"),
                    actions: <Widget>[
                      FlatButton(child:Text('Remover Coluna'),onPressed:()=>Navigator.of(context).pop({'action': 1, 'column': i})),
                      FlatButton(child:Text('Adicionar Coluna à Esqueda'),onPressed:()=>Navigator.of(context).pop({'action': 2, 'column': i})),
                      FlatButton(child:Text('Adicionar Coluna à Direita'),onPressed:()=>Navigator.of(context).pop({'action': 2, 'column': i+1})),
                    ],
                );
            }
        ).then((value){
          if (value['action'] == 1) removeColumn(value['column']);
          if (value['action'] == 2) addColumn(value['column']);
        });
        },
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
          height: MediaQuery.of(context).size.height*0.5,
          decoration: BoxDecoration(
            //color: Colors.blueGrey[300],
            borderRadius: BorderRadius.circular(10)
          ),
          child: Center(child: Text('$i',)),
        )
      ), ));
    }
    return columns;
  } 

  List<DataRow> loadRows()
  {
    double x = 0.0;
    var nColumns = 0;
    var nRows = 0;
    if (item != null){
      nColumns = item.data.length;
      nRows = item.data[0].length;
    }
    List<DataRow> rows = [];
    for (var i = 0; i < nRows; i++) {
      List<DataCell> cells = [DataCell(Text("${i+1}"), onTap: (){
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Remover Linha ${i+1}"),
                    actions: <Widget>[
                      FlatButton(child:Text('Remover Linha'),onPressed:()=>Navigator.of(context).pop({'action': 1, 'row': i})),
                      FlatButton(child:Text('Adicionar Linha Acima'),onPressed:()=>Navigator.of(context).pop({'action': 2, 'row': i})),
                      FlatButton(child:Text('Adicionar Linha Abaixo'),onPressed:()=>Navigator.of(context).pop({'action': 2, 'row': i+1})),
                    ],
                );
            }
        ).then((value){
          if (value['action'] == 1) removeRow(value['row']);
          if (value['action'] == 2) addRow(value['row']);
        });
      })];

      for (var j = 0; j < nColumns; j++) {
        x = item.data[j][i];   
        cells.add(
          DataCell(TextFormField(
            key: Key(x.toString()),
            initialValue: x.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value != '')
              {
                item.data[j][i] = double.parse(value);
                DB.update('projects', item);
                //refresh();
              }
            },
          ))
        );
      }
      rows.add(DataRow(cells: cells));
    }
    
    return rows;
  }

  refresh() async {
      var result = await DB.readByName('projects', widget.projectName);

      DBitem res = DBitem.fromMap(result);
      
      setState(() {
        item = res;
      });    


      setState(() {
        TABLE = DataTable(
          columns: loadColumns(),
          rows: loadRows()
        );
      });

  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: TABLE
      ),
    ]);
  }
}