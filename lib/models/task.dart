import 'package:flutter/foundation.dart';

class Task {
  final String id; // Adicionando campo de ID
  final String name;
  final DateTime dateTime;
  final String location;
  String? imageUrl;
  final String address;

  Task({
    required this.id, // Inicializando o campo de ID
    required this.name,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    required this.address,
  });
}
