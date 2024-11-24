import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActividadFisicaPage extends StatefulWidget {
  @override
  _ActividadFisicaPageState createState() => _ActividadFisicaPageState();
}

class _ActividadFisicaPageState extends State<ActividadFisicaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController(); // Controlador para minutos o repeticiones
  String? _editingActivityId; // Para almacenar el ID de la actividad que se está editando

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividad Física'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding alrededor de los campos
        child: Column(
          children: <Widget>[
            // Campos de entrada en cascada
            TextField(
              controller: _activityController,
              decoration: InputDecoration(labelText: 'Actividad'),
            ),
            SizedBox(height: 8), // Espacio entre los campos
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 8), // Espacio entre los campos
            TextField(
              controller: _minutesController, // Campo para minutos o repeticiones
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Minutos o repeticiones realizadas'), // Cambiado aquí
            ),
            SizedBox(height: 16), // Espacio antes del botón
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Cambiar color del botón a azul
              ),
              child: Text('Agregar'),
              onPressed: _addOrUpdateActivity,
            ),
            SizedBox(height: 16), // Espacio entre el botón y la lista
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('physical_activity').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final activities = snapshot.data!.docs;
                  List<Widget> activityWidgets = [];
                  for (var activity in activities) {
                    final data = activity.data() as Map<String, dynamic>?; // Aseguramos que data no sea nulo
                    if (data != null && data.containsKey('name') && data.containsKey('description') && data.containsKey('minutes')) {
                      final activityName = data['name'];
                      final activityDescription = data['description'];
                      final activityMinutes = data['minutes'].toString(); // Convertir minutos a string para mostrar

                      activityWidgets.add(
                        ListTile(
                          title: Text(activityName),
                          subtitle: Text('$activityDescription - $activityMinutes minutos o repeticiones'),
                          onTap: () {
                            _showActivityDetails(context, activityName, activityDescription, activityMinutes);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editActivity(activity.id, activityName, activityDescription, activityMinutes);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteActivity(activity.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  return ListView(children: activityWidgets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrUpdateActivity() {
    final String activityName = _activityController.text;
    final String activityDescription = _descriptionController.text;
    final String activityMinutes = _minutesController.text; // Obtener minutos o repeticiones

    if (activityName.isNotEmpty && activityDescription.isNotEmpty && activityMinutes.isNotEmpty) {
      if (_editingActivityId != null) {
        // Editar actividad existente
        _firestore.collection('physical_activity').doc(        _editingActivityId).update({
          'name': activityName,
          'description': activityDescription,
          'minutes': int.tryParse(activityMinutes), // Convertir a int
        });
        _editingActivityId = null; // Resetear el ID después de editar
      } else {
        // Agregar nueva actividad
        _firestore.collection('physical_activity').add({
          'name': activityName,
          'description': activityDescription,
          'minutes': int.tryParse(activityMinutes), // Convertir a int
        });
      }

      // Limpiar los campos de entrada
      _activityController.clear();
      _descriptionController.clear();
      _minutesController.clear();
    }
  }

  void _editActivity(String id, String name, String description, String minutes) {
    _editingActivityId = id; // Guardar el ID de la actividad que se va a editar
    _activityController.text = name;
    _descriptionController.text = description;
    _minutesController.text = minutes; // Llenar el campo de minutos o repeticiones
  }

  void _deleteActivity(String id) {
    _firestore.collection('physical_activity').doc(id).delete();
  }

  void _showActivityDetails(BuildContext context, String title, String description, String minutes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('$description\n\nDuración: $minutes minutos o repeticiones realizadas'),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}