import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeguimientoDietaPage extends StatefulWidget {
  @override
  _SeguimientoDietaPageState createState() => _SeguimientoDietaPageState();
}

class _SeguimientoDietaPageState extends State<SeguimientoDietaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _editingFoodId; // Para almacenar el ID de la comida que se está editando

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento de Dieta'),
        actions: [
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: () => _showTotalCalories(context), // Botón para calcular calorías
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _foodController,
              decoration: InputDecoration(labelText: 'Nombre de la Comida'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Calorías'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Agregar Comida'),
              onPressed: _addOrUpdateFood,
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('diet_monitoring').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final foods = snapshot.data!.docs;
                  List<Widget> foodWidgets = [];
                  for (var food in foods) {
                    final data = food.data() as Map<String, dynamic>?;
                    if (data != null &&
                        data.containsKey('name') &&
                        data.containsKey('calories') &&
                        data.containsKey('description')) {
                      final foodName = data['name'];
                      final foodCalories = data['calories'].toString();
                      final foodDescription = data['description'];

                      foodWidgets.add(
                        ListTile(
                          title: Text(foodName),
                          subtitle: Text('$foodDescription - $foodCalories calorías'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editFood(food.id, foodName, foodCalories, foodDescription);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteFood(food.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  return ListView(children: foodWidgets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrUpdateFood() {
    final String foodName = _foodController.text;
    final String foodCalories = _caloriesController.text;
    final String foodDescription = _descriptionController.text;

    if (foodName.isNotEmpty && foodCalories.isNotEmpty && foodDescription.isNotEmpty) {
      if (_editingFoodId != null) {
        // Editar comida existente
        _firestore.collection('diet_monitoring').doc(_editingFoodId).update({
          'name': foodName,
          'calories': int.tryParse(foodCalories), // Convertir a int
          'description': foodDescription,
        });
        _editingFoodId = null; // Resetear el ID después de editar
      } else {
        // Agregar nueva comida
        _firestore.collection('diet_monitoring').add({
                    'name': foodName,
          'calories': int.tryParse(foodCalories), // Convertir a int
          'description': foodDescription,
        });
      }

      // Limpiar los campos de entrada
      _foodController.clear();
      _caloriesController.clear();
      _descriptionController.clear();
    }
  }

  void _editFood(String id, String name, String calories, String description) {
    _editingFoodId = id; // Guardar el ID de la comida que se va a editar
    _foodController.text = name;
    _caloriesController.text = calories; // Llenar el campo de calorías
    _descriptionController.text = description; // Llenar el campo de descripción
  }

  void _deleteFood(String id) {
    _firestore.collection('diet_monitoring').doc(id).delete();
  }

  void _showTotalCalories(BuildContext context) {
    // Método para calcular y mostrar el total de calorías
    _firestore.collection('diet_monitoring').get().then((snapshot) {
      int totalCalories = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('calories')) {
          totalCalories += (data['calories'] as num).toInt(); // Convertir a int
        }
      }

      // Mostrar el total de calorías en un diálogo
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Total de Calorías'),
            content: Text('Total de calorías consumidas: $totalCalories'),
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
    });
  }
}