import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_flutter/models/task.dart';
import 'package:app_flutter/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_custom_package/my_custom_package.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();

  
  String? nameValidator(String name) { // Alterado para público
    if (name.isEmpty) {
      return 'Por favor, insira o nome da tarefa';
    }
    // Retorne null se o nome for válido
    return null;
  }
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  final TaskHelper _taskHelper = TaskHelper();  // Adicionado para usar o TaskHelper

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _selectedDate = widget.task!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dateTime);
      _locationController.text = widget.task!.location;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      DateTime selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      String taskId = _taskHelper.generateTaskId(); // Gerar um ID único para a tarefa

      Task newTask = Task(
        id: taskId, // Adicionando o ID único à tarefa
        name: _nameController.text,
        dateTime: selectedDateTime,
        location: _locationController.text,
        imageUrl: _imageFile != null ? _imageFile!.path : null,
        address: '',
      );

      if (_imageFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String imageUrl = await _firebaseService.uploadImage(_imageFile!, fileName);
        newTask.imageUrl = imageUrl;
      }

      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome da Tarefa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da tarefa';
                  }
                  return null;
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Hora: ${_selectedTime.format(context)}'),
                onTap: () => _selectTime(context),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Localização'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização da tarefa';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('Selecionar Imagem'),
              ),
              if (_imageFile != null) ...[
                Image.file(_imageFile!),
              ],
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}