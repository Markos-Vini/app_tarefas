import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  late String _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndTasks();
  }

  Future<void> _loadUserIdAndTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('loggedInUserId') ?? '';

    List<String>? storedTasks = prefs.getStringList('tasks_$_userId');
    if (storedTasks != null) {
      tasks = storedTasks.map((task) => Task.fromJson(jsonDecode(task))).toList();
    }

    setState(() {});
  }

  void _addTask(Task task) async {
    setState(() {
      tasks.add(task);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedTasks = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks_$_userId', storedTasks);
  }

  void _editTask(Task task, int index) async {
    setState(() {
      tasks[index] = task;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedTasks = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks_$_userId', storedTasks);
  }

  void _deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedTasks = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks_$_userId', storedTasks);
  }

  Future<void> _navigateToTaskForm({Task? task, int? index}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      if (index != null) {
        _editTask(result, index);
      } else {
        _addTask(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[100]!, Colors.grey[400]!],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40), // Espaço para o topo
            Center(
              child: Text(
                'Lista de Atividades',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Divider(
              color: Colors.blue[400],
              thickness: 2,
              indent: 16,
              endIndent: 16,
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma atividade encontrada.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 8.0), // Espaço entre a linha e os cards
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToTaskForm(task: tasks[index], index: index),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // Ajustar margens dos cards
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Atividade: ',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tasks[index].name,
                                              
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Data: ',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(tasks[index].dateTime),
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Hora: ',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            DateFormat('HH:mm').format(tasks[index].dateTime),
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Local: ',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tasks[index].location,
                                              style: TextStyle(color: Colors.grey[600]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Container(
                                    height: 100,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(tasks[index].latitude, tasks[index].longitude),
                                        zoom: 15,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId('taskLocation_${index}'),
                                          position: LatLng(tasks[index].latitude, tasks[index].longitude),
                                        ),
                                      },
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteTask(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _navigateToTaskForm(),
                child: Text('NOVA ATIVIDADE'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Texto branco
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  minimumSize: Size(double.infinity, 50), // Definir largura mínima
                  textStyle: TextStyle(fontSize: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
