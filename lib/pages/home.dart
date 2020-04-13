import 'package:flutter/material.dart';
import 'package:myLAB/services/db.dart';
import 'package:myLAB/pages/project.dart';

class MyHomePage extends StatefulWidget {
    MyHomePage({Key key, this.title}) : super(key: key);
    final String title;
    @override
    _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    
    
    String _name;

    List<DBitem> projects = [];
    
    void _save() async {
        var nameAux = 'default';
        if (_name != null && _name != '') nameAux = _name;
        Navigator.of(context).pop();
        DBitem item = DBitem(
            name: nameAux,
            data: [ [0] , [0] ]
        );
        
        await DB.insert(DBitem.table, item);
        setState(() => _name = '' );
        refresh();
    }

    void _create(BuildContext context) {

        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Criar Novo Projeto"),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('Cancelar'),
                            onPressed: () => Navigator.of(context).pop()
                        ),
                        FlatButton(
                            child: Text('Criar'),
                            onPressed: () => _save()
                        )                        
                    ],
                    content: TextField(
                        decoration: InputDecoration(labelText: 'Nome', hintText: 'exemplo: projetinho'),
                        onChanged: (value) { _name = value; },
                    ),
                );
            }
        );
    }

    void _remove(BuildContext context, DBitem item) {

        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Remover Projeto"),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('Cancelar'),
                            onPressed: () => Navigator.of(context).pop()
                        ),
                        FlatButton(
                            child: Text('Remover'),
                            onPressed: (){
                              DB.delete(DBitem.table, item);
                              Navigator.of(context).pop();
                              refresh();
                            }
                        )                        
                    ],
                );
            }
        );
    }


    @override
    void initState() {
        super.initState();
        refresh();
    }

    void refresh() async {

        List<Map<String, dynamic>> _results = await DB.query(DBitem.table);
        projects = _results.map((item) => DBitem.fromMap(item)).toList();
        setState(() { });
    }

    Widget showItem(DBitem item) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: FlatButton(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Color(0xff90a4ae)  , 
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Text(
                            item.name, 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            )
                          ),
                          IconButton(
                            color: Colors.white,
                            alignment: Alignment.center,
                            icon: Icon(Icons.delete, size: 20,),
                            onPressed: () => _remove(context, item)
                          ),
                      ]
                    )
                  )
                ]
            ),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Project(projectName: item.name,) )
              ).then((res){
                refresh();
              });
            },
        )
      );
    }
    
    Widget loadProjects()
    {
      if (projects.length == 0) return GestureDetector(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.blueGrey[400]
          ),
          child: Text("Bem vindo ao myLAB.\n\nClique aqui para criar\nseu primeiro projeto.", style: TextStyle(color: Colors.white, fontSize: 20),),
        ),
        onTap: () => _create(context),
      );

      return ListView( 
        children: projects.map((item) => showItem(item),).toList() 
      );
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar( title: Text(widget.title), actions: <Widget>[
              IconButton(
                onPressed: () { _create(context); },
                tooltip: 'New Item',
                icon: Icon(Icons.add_box),
              )
            ], ),
            body: Center(
              child: loadProjects()
            ),
        );
    }
}