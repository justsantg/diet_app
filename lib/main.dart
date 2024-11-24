import 'package:diet_app/ActividadFisicaPage.dart';
import 'package:diet_app/ObjetivosSaludPage.dart';
import 'package:diet_app/SeguimientoDietaPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "IzaSyCu1s79ghpvs_jcYp3Ppi1egZo6Gqbw_9w",
  appId: "1:621136941396:android:d8c2711066cbc8d39778c1",
  messagingSenderId: "621136941396",
  projectId: "diet-app-ad560",
  storageBucket: "diet-app-ad560.appspot.com",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App de Fitness',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi App de Fitness'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton(
                context,
                'Actividad Física',
                Icons.fitness_center,
                ActividadFisicaPage(),
              ),
              SizedBox(height: 20),
              _buildButton(
                context,
                'Seguimiento de Dieta',
                Icons.restaurant_menu,
                SeguimientoDietaPage(),
              ),
              SizedBox(height: 20),
              _buildButton(
                context,
                'Objetivos de Salud',
                Icons.track_changes,
                ObjetivosSaludPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildButton(BuildContext context, String label, IconData icon, Widget page) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      icon: Icon(icon, size: 24), // Icono del botón
      label: Text(label, style: TextStyle(fontSize: 18)), // Texto del botón
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.teal, // Color del texto
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}