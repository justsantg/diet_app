import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ObjetivosSaludPage extends StatefulWidget {
  @override
  _ObjetivosSaludPageState createState() => _ObjetivosSaludPageState();
}

class _ObjetivosSaludPageState extends State<ObjetivosSaludPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  double? _pesoIdeal;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    DocumentSnapshot snapshot = await _firestore.collection('health_goals').doc('usuario_id').get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        _pesoController.text = data['peso']?.toString() ?? '';
        _alturaController.text = data['altura']?.toString() ?? '';
      }
    }
  }

  Future<void> _guardarDatos() async {
    double peso = double.tryParse(_pesoController.text) ?? 0;
    double altura = double.tryParse(_alturaController.text) ?? 0;

    await _firestore.collection('health_goals').doc('usuario_id').set({
      'peso': peso,
      'altura': altura,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objetivos de Salud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Altura (cm)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _guardarDatos();
                _calcularPesoIdeal();
              },
              child: Text('Guardar y Calcular Peso Ideal'),
            ),
            SizedBox(height: 16),
            if (_pesoIdeal != null)
              Text('Peso Ideal: ${_pesoIdeal!.toStringAsFixed(2)} kg'),
            SizedBox(height: 16),
            Text('Actividad Física Registrada:'),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('physical_activity').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final actividades = snapshot.data!.docs;
                  List<Widget> actividadWidgets = [];
                  for (var actividad in actividades) {
                    final data = actividad.data() as Map<String, dynamic>?; // Aseguramos que data no sea nulo
                    if (data != null &&
                        data.containsKey('name') &&
                        data.containsKey('description') &&
                        data.containsKey('minutes')) {
                      final nombre = data['name']; // Cambiado a 'name'
                      final descripcion = data['description']; // Cambiado a 'description'
                      final minutos = data['minutes'].toString(); // Cambiado a 'minutes'

                      actividadWidgets.add(
                        ListTile(
                          title: Text(nombre),
                          subtitle: Text('$descripcion - $minutos minutos o repeticiones'),
                        ),
                      );
                    }
                  }

                                    return ListView(children: actividadWidgets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calcularPesoIdeal() {
    final String pesoStr = _pesoController.text;
    final String alturaStr = _alturaController.text;

    if (pesoStr.isNotEmpty && alturaStr.isNotEmpty) {
      double peso = double.tryParse(pesoStr) ?? 0;
      double altura = double.tryParse(alturaStr) ?? 0;

      // Convertir altura de cm a metros
      altura = altura / 100;

      // Calcular peso ideal usando la fórmula de Broca
      _pesoIdeal = altura * altura * 22; // Fórmula aproximada
      setState(() {});
    }
  }
}