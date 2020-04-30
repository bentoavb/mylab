import 'package:flutter/material.dart';
import 'package:myLAB/services/graph.dart';
import 'package:myLAB/services/db.dart';
import 'package:linalg/linalg.dart';
import 'dart:math';

class GraphPage extends StatefulWidget {
    GraphPage({Key key, this.projectName, this.title, this.xlabel, this.ylabel, this.axisIndex}) : super(key: key);
    final String projectName;
    final String title;
    final String xlabel;
    final String ylabel;
    final List<int> axisIndex;
    @override
    _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {

  List<List<double>> data1 = [[0.0,0.0]];
  List<List<double>> data2 = [[0.0,0.0]];
  List<List<List<double>>> chartData = [
      [[0.0,0.0]], [[0.0,0.0]]
  ];
  List<double> Theta = [];
  bool showFit = false;
  String fitType;
  bool showFitButton = false;
  DBitem item;
  double slider = 0;

  List<String> DropValues = [
    "Polinômio de grau 1", "Polinômio de grau 2", 
    "Polinômio de grau 3", "Polinômio de grau 4",
    "Polinômio de grau 5", "Exponencial"];
  String dropdownValue = "Polinômio de grau 1";

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
            title: Text('Ajuste de Curva', style: TextStyle(color: Colors.blueGrey[400]),),
            onTap: () {
              setState(() {
                showFitButton = !showFitButton;
              });
            },
          ),
          if(showFitButton) FitMenu(),
          if(showFitButton && showFit && fitType == "pol") FitParametersPol(),
          if(showFitButton && showFit && fitType == "exp") FitParametersExp(),
          ListTile(
            leading: Icon(Icons.file_download, color: Colors.blueGrey[400]),
            title: Text('Download do Gráfico', style: TextStyle(color: Colors.blueGrey[400]),),
            onTap: () { },
          ),
        ],
      ),
    );
  }

  Widget dropdown ()
  {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 10,
      underline: Container(
        height: 2,
        color: Colors.blueGrey,
      ),
      onChanged: (String newValue) {
        dropdownValue = newValue;
        showFit = false;
        chartData = [data1];
        setState(() { });
      },
      items: DropValues
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.toString()),
          );
        })
        .toList(),
    );
  }

  getData() async {
      var result = await DB.readByName('projects', widget.projectName);
      item = DBitem.fromMap(result);
      var x1 = item.data[widget.axisIndex[0]];
      var x2 = item.data[widget.axisIndex[1]];
      List<List<double>> aux = [];
      for (var i = 0; i < x1.length; i++) {
          aux.add([ x1[i],x2[i] ]);           
      }
      
      setState(() {
        item = DBitem.fromMap(result);
        data1 = aux;
        chartData = [aux];
      });
  }

  void curveFit(int n, bool exp)
  {
      List<double> xdata = item.data[widget.axisIndex[0]];
      List<double> ydata = [];

      for (var i = 0; i < item.data[widget.axisIndex[1]].length; i++) {
        ydata.add(item.data[widget.axisIndex[1]][i]);
          if (exp) ydata[i] = log(ydata[i]);
      }

      Matrix Y = Matrix([ydata]).transpose();
      List<List<double>> aux = [];

      List<List<double>> xaux = [];
      for (var i = 0; i < xdata.length ; i++) {
        xaux.add([]);
        for (var j = 0; j <= n; j++) {
          xaux[i].add(pow(xdata[i],j));
        }
      }
      Matrix X = Matrix(xaux);
      Matrix theta = (X.transpose()*X).inverse()*X.transpose()*Y;

      var _x;
      for (var i = 0; i <= xdata.length*10 ; i++) {
        _x = xdata[0] + (xdata[xdata.length-1] - xdata[0])*i/(xdata.length*10);
        aux.add([ _x,0 ]);
        if (exp){
          aux[i][1] = pow(e, theta[0][0] + theta[1][0]*_x) ; 
        }else{
          for (var j = 0; j <= n; j++) {
            aux[i][1] += theta[j][0]*pow(_x,j);
          }
        }
      }

      setState(() {
        data2 = aux;
        Theta = [];
        for (var i = 0; i <= n; i++) {
          Theta.add(theta[i][0]);
        }
      });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Widget FitParametersPol(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(children: <Widget>[
          for (var i = 0; i < Theta.length; i++) 
          Text('coeficiente de x^$i: ${Theta[i].toStringAsFixed(3)}',
          textAlign: TextAlign.left, style: TextStyle(fontSize: 17, color: Colors.blueGrey[700]),),
        ]
      )
    );
  }

  Widget FitParametersExp(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(children: <Widget>[
          Text('y = e^(a + b*x)',
          textAlign: TextAlign.left, style: TextStyle(fontSize: 17, color: Colors.blueGrey[700]),),
          Text('coeficiente a: ${Theta[0].toStringAsFixed(3)}',
          textAlign: TextAlign.left, style: TextStyle(fontSize: 17, color: Colors.blueGrey[700]),),
          Text('coeficiente b: ${Theta[1].toStringAsFixed(3)}',
          textAlign: TextAlign.left, style: TextStyle(fontSize: 17, color: Colors.blueGrey[700]),)
        ]
      )
    );
  }

  Widget FitMenu()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        dropdown(),
        Switch(value: showFit, onChanged: (value){
            setState(() {
              if (value == false){
                chartData = [data1];
                showFit = false;
              }else{
                showFit = true;
                int n;
                bool exp = false;
                fitType = "pol";
                for (var i = 0; i < DropValues.length; i++) {
                  if(dropdownValue == DropValues[i]) n = i+1;
                }
                if(dropdownValue == DropValues[DropValues.length-1]){   
                  n=1; 
                  exp=true;
                  fitType = "exp";
                }
                curveFit(n, exp);
                chartData = [data1, data2];
              }
            });
          }),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
          endDrawer: NavDrawer(),
          appBar: AppBar( 
            title: Text('Gráfico do ${widget.projectName}') 
          ),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                SimpleLineChart(chartData, widget.title, widget.xlabel, widget.ylabel),
              ],
            )
          ),
      );
  }
}