import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ReportService.dart';

class ReportFormScreen extends StatefulWidget {
  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? photo1, photo2, photo3;

  Future<void> pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (index == 1) photo1 = File(pickedFile.path);
        if (index == 2) photo2 = File(pickedFile.path);
        if (index == 3) photo3 = File(pickedFile.path);
      });
    }
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate() && photo1 != null && photo2 != null && photo3 != null) {
      bool success = await ReportService.sendReport(
        category: categoryController.text,
        photo1: photo1!,
        photo2: photo2!,
        photo3: photo3!,
        description: descriptionController.text,
        latitude: "0.000", // Gantilah dengan lokasi asli
        longitude: "0.000",
        address: addressController.text,
        token: "TOKEN_KAMU", // Gantilah dengan token autentikasi
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Laporan berhasil dikirim")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim laporan")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kirim Laporan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: categoryController, decoration: InputDecoration(labelText: "Kategori")),
              TextFormField(controller: descriptionController, decoration: InputDecoration(labelText: "Keterangan")),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: "Alamat")),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(onPressed: () => pickImage(1), child: Text("Pilih Foto 1")),
                  ElevatedButton(onPressed: () => pickImage(2), child: Text("Pilih Foto 2")),
                  ElevatedButton(onPressed: () => pickImage(3), child: Text("Pilih Foto 3")),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: submitReport, child: Text("Kirim Laporan")),
            ],
          ),
        ),
      ),
    );
  }
}
