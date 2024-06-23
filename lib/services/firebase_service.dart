import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String fileName) async {
    // Verifique se o Firebase foi inicializado corretamente antes de usar _storage
    try {
      var snapshot = await _storage.ref().child(fileName).putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      rethrow; // ou lide com o erro conforme necessário
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Implemente a lógica para deletar imagem do Firebase Storage
  }
}
