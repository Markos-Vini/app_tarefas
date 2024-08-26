import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  bool _uploading = false;
  String? _imageUrl;

  Future<void> _selectAndUploadImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  Future<void> _uploadImageToFirebase() async {
    setState(() {
      _uploading = true;
    });

    try {
      if (_imageFile != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = ref.putFile(_imageFile!);

        await uploadTask.whenComplete(() async {
          _imageUrl = await ref.getDownloadURL();
        });

        print('Imagem carregada com sucesso: $_imageUrl');
      }
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload de Imagem'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('Nenhuma imagem selecionada.')
                : Image.file(
                    _imageFile!,
                    height: 200,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectAndUploadImage,
              child: Text('Selecionar Imagem'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploading ? null : _uploadImageToFirebase,
              child: _uploading ? CircularProgressIndicator() : Text('Enviar Imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
