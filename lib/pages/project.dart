import 'package:flutter/material.dart';
import 'package:myLAB/services/table.dart';
import 'package:myLAB/services/db.dart';
import 'package:myLAB/pages/graphpage.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Project extends StatefulWidget {
    Project({Key key, this.projectName}) : super(key: key);
    final String projectName;
    @override
    _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<Project> {

  bool showButtons = false;

  String chartTitle;
  String chartXlabel;
  String chartYlabel;
  List<int> axisIndex= [0,1];
  List<int> axisValues = [0,1];
  bool showCreateChart = false;
  bool showNameChange = false;
  DBitem item = new DBitem();

  Widget NavDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 100,
            child: DrawerHeader(
              child: Text(
                'Opções',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.blueGrey[400],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.multiline_chart, color: Colors.blueGrey[400]),
            title: Text('Plotar Gráfico', style: TextStyle(color: Colors.blueGrey[400]),),
            onTap: () {
              setState(() {
                showCreateChart = !showCreateChart;
              });
            },
          ),
          if (showCreateChart) createChart(),
          ListTile(
            leading: Icon(Icons.file_upload, color: Colors.blueGrey[400]),
            title: Text('Exportar Dados', style: TextStyle(color: Colors.blueGrey[400]),),
            onTap: () async {
              var result = await DB.readByName('projects', item.name);
              var data = DBitem.fromMap(result).data;
              List<List> csvdata = [];
              for (var i = -1; i < data[0].length; i++) {
                csvdata.add([]);
                for (var j = 0; j < data.length; j++) {
                  if (i >= 0) csvdata[i+1].add(data[j][i]);
                  else csvdata[i+1].add("x$j");
                }
              }
              String csv = const ListToCsvConverter().convert(csvdata);
              String dir = (await getExternalStorageDirectory()).absolute.path;
              File f = new File(dir + "/${item.name}.txt");
              f.writeAsString(csv);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                    return AlertDialog(title: Column(
                      children: <Widget>[
                        Text("Arquivo salvo em:"),
                        Text("${dir}")
                      ]
                    ),);
                }
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark, color: Colors.blueGrey[400]),
            title: Text('Alterar Nome do Projeto', style: TextStyle(color: Colors.blueGrey[400]),),
            onTap: () { setState(() { showNameChange = !showNameChange; });},
          ),
          if (showNameChange) changeName()
          
          
        ],
      ),
    );
  }

  refresh() async {
      var result = await DB.readByName('projects', item.name);
      item = DBitem.fromMap(result);
      axisValues = List<int>(item.data.length);
      for (var i = 0; i < item.data.length; i++) {
        axisValues[i] = i;
      }
  }

  Widget changeName ()
  {   
    return Container(
      width: MediaQuery.of(context).size.width*0.5,
      child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.4,
            child: TextFormField(
              initialValue: item.name,
              onChanged: (value) {
                setState(() {
                  if(value != null && value != "") {
                    item.name = value;
                    DB.update("projects", item);
                    refresh();
                  }
                });
              },
            ),
          )
      )
    );
  }

  Widget returnDrop(int axis)
  {
    return DropdownButton(
      value: axisIndex[axis],
      items: axisValues
          .map((value) => DropdownMenuItem(
                child: Text(value.toString()),
                value: value,
              ))
          .toList(),
      onChanged: (value) {
        axisIndex[axis] = value;
        setState(() {});
      },
      isExpanded: false,
      hint: Text('Select Number'),
    );
  }

  Widget createChart()
  {
    refresh();
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Título'),
            onChanged: (value) { chartTitle = value; },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            Container(
              width: 90,
              child: TextField(
                decoration: InputDecoration(labelText: 'eixo x'),
                onChanged: (value) { chartXlabel = value; },
              ),
            ),
            returnDrop(0)
          ]),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            Container(
              width: 90,
              child: TextField(
                decoration: InputDecoration(labelText: 'eixo y'),
                onChanged: (value) { chartYlabel = value; },
              ),
            ),
            returnDrop(1)
          ]),

          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                color: Colors.blueGrey,
                  child: Text('Criar', style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    Navigator.push(context,MaterialPageRoute(
                      builder: (context) => GraphPage(
                        projectName: item.name, 
                        title: chartTitle, 
                        xlabel: chartXlabel, 
                        ylabel: chartYlabel,
                        axisIndex: axisIndex,) 
                    ));
                  }
              )     
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      item.name = widget.projectName;
    });
    super.initState();
    refresh();
  }


  @override
  Widget build(BuildContext context) {
        return Scaffold(
        endDrawer: NavDrawer(),
        appBar: AppBar(
          title: Text(item.name),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          height: MediaQuery.of(context).size.height*0.95,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              TableSimple(projectName: item.name,),
            ],
          ),
        )
    );
  }

}