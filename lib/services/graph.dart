import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {

  List<charts.Series<List, num>> seriesList = [];
  final List<List<List<num>>> data;
  final String title;
  final String xlabel;
  final String ylabel;

  SimpleLineChart(this.data, this.title, this.xlabel, this.ylabel){

    List colors = [charts.MaterialPalette.black, charts.MaterialPalette.indigo.shadeDefault];
    ;
    for (var i = 0; i < data.length; i++) {
      
      if (i==1) {
        seriesList.add(new charts.Series<List<num>, num>(
          id: 'Sales',
          colorFn: (_, __) => colors[i],
          domainFn: (List<num> r, _) => r[0],
          measureFn: (List<num> r, _) => r[1],
          data: data[i],
        ));
      } else seriesList.add(new charts.Series<List<num>, num>(
        id: 'Sales',
        colorFn: (_, __) => colors[i],
        domainFn: (List<num> r, _) => r[0],
        measureFn: (List<num> r, _) => r[1],
        data: data[i],
      )..setAttribute(charts.rendererIdKey, 'customPoint'));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: charts.NumericComboChart(
          seriesList, 
          defaultRenderer: new charts.LineRendererConfig(),
        // Custom renderer configuration for the point series.
        customSeriesRenderers: [
          new charts.PointRendererConfig(
              customRendererId: 'customPoint')
          ],
          animate: false,
          behaviors: [
            new charts.ChartTitle(title,
                behaviorPosition: charts.BehaviorPosition.top,
                titleOutsideJustification: charts.OutsideJustification.start,
                innerPadding: 18),
            new charts.ChartTitle(xlabel,
                behaviorPosition: charts.BehaviorPosition.bottom,
                titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
            new charts.ChartTitle(ylabel,
                behaviorPosition: charts.BehaviorPosition.start,
                titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
          ],
        ),
    );
  }
}