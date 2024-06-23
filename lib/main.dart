import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_flutter/screens/task_list_screen.dart';
import 'package:app_flutter/models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicialize o Firebase antes de runApp()
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aqui você pode inicializar a lista de tarefas conforme necessário
    List<Task> tasks = []; // Ou carregue suas tarefas de alguma fonte, como Firebase

    return MaterialApp(
      title: 'App de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.orange,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TaskListScreen(tasks: tasks), // Passe a lista de tarefas para TaskListScreen
      },
    );
  }
}
