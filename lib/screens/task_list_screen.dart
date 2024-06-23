import 'package:app_flutter/screens/calendar_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/models/task.dart';
import 'package:app_flutter/screens/task_form_screen.dart';
import 'package:app_flutter/services/firebase_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;

  TaskListScreen({required this.tasks});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isMapExpanded = false;

  void _deleteTask(int index) {
    setState(() {
      Task taskToDelete = widget.tasks.removeAt(index);

      if (taskToDelete.imageUrl != null) {
        _firebaseService.deleteImage(taskToDelete.imageUrl!);
      }
    });
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
    ).then((editedTask) {
      if (editedTask != null && editedTask is Task) {
        setState(() {
          final index = widget.tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            widget.tasks[index] = editedTask;
          }
        });
      }
    });
  }

  Future<LatLng> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      Location firstLocation = locations.first;
      return LatLng(firstLocation.latitude, firstLocation.longitude);
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
      return LatLng(-23.5505199, -46.6333094);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen(tasks: widget.tasks)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          String formattedDate = DateFormat('dd/MM/yyyy').format(task.dateTime);
          String formattedTime = DateFormat('HH:mm').format(task.dateTime);

          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(task.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: $formattedDate'),
                      Text('Hora: $formattedTime'),
                      if (task.imageUrl != null) ...[
                        Image.network(
                          task.imageUrl!,
                          height: 100,
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMapExpanded = !_isMapExpanded;
                    });
                  },
                  child: Container(
                    height: _isMapExpanded ? 300 : 100,
                    child: FutureBuilder<LatLng>(
                      future: _getCoordinatesFromAddress(task.address),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text('Erro ao carregar o mapa'));
                        }

                        LatLng location = snapshot.data ?? LatLng(0, 0);

                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: location,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(task.name),
                              position: location,
                            ),
                          },
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                          ].toSet(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskFormScreen()),
          ).then((newTask) async {
            if (newTask != null && newTask is Task) {
              setState(() {
                widget.tasks.add(newTask);
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}