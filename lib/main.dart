import 'package:flutter/material.dart';
import 'package:myLAB/services/db.dart';
import 'pages/home.dart';

void main() async {
    
    WidgetsFlutterBinding.ensureInitialized();
    await DB.init();
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'myLAB',
            theme: ThemeData(
              primaryColor: Colors.blueGrey,
              accentColor: Colors.blueGrey,
              accentIconTheme: IconThemeData(color: Colors.white),
            ),
            home: MyHomePage(title: 'myLAB'),
        );
    }
}