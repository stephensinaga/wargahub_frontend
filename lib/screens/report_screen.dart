import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wargahub_frontend/config/constant.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController descriptionController = TextEditingController();
  String? selectedReportType;
  XFile? _foto1, _foto2, _foto3;
  String? currentLocation;
  double? latitude;
  double? longitude;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final List<String> reportTypes = ["Kebersihan", "Keamanan", "Sosial", "Fasilitas Umum"];

  Future<void> pickImage(int fotoIndex) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (fotoIndex == 1) _foto1 = pickedFile;
        if (fotoIndex == 2) _foto2 = pickedFile;
        if (fotoIndex == 3) _foto3 = pickedFile;
      });
    }
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Aktifkan layanan lokasi!")));
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Izin lokasi diblokir secara permanen!")));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      Placemark place = placemarks.first;

      setState(() {
        currentLocation = "${place.street}, ${place.locality}, ${place.subAdministrativeArea}";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lokasi diperoleh!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mendapatkan lokasi: $e")));
    }
  }

  Future<void> submitReport() async {
    // Pastikan semua foto sudah dipilih
    if (_foto1 == null || _foto2 == null || _foto3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua foto wajib diunggah!")),
      );
      return;
    }

    // Pastikan data lainnya sudah diisi
    if (selectedReportType == null || descriptionController.text.isEmpty || currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap lengkapi semua data!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Anda harus login terlebih dahulu!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      var uri = Uri.parse("${ApiConstants.baseUrl}/reports");

      var request = http.MultipartRequest("POST", uri)
        ..headers['Authorization'] = "Bearer $token"
        ..fields['jenis_laporan'] = selectedReportType!
        ..fields['keterangan'] = descriptionController.text
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['alamat'] = currentLocation!;

      request.files.add(await http.MultipartFile.fromPath("photo_1", _foto1!.path));
      request.files.add(await http.MultipartFile.fromPath("photo_2", _foto2!.path));
      request.files.add(await http.MultipartFile.fromPath("photo_3", _foto3!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      dynamic decodedData;
      try {
        decodedData = jsonDecode(responseData);
      } catch (e) {
        print("Error parsing JSON: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memproses respons dari server!")),
        );
        return;
      }

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Laporan berhasil dikirim!")),
        );

        // **Tunggu 1 detik sebelum kembali ke HomeScreen agar refresh terjadi**
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context, true); // Kirim nilai "true" agar HomeScreen tahu harus refresh
        });
      } else {
        String errorMessage = decodedData['message'] ?? "Gagal mengirim laporan!";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buat Laporan")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jenis Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: reportTypes.map((type) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: selectedReportType == type,
                      onSelected: (selected) {
                        setState(() {
                          selectedReportType = selected ? type : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: descriptionController, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(height: 16),
              Text("Foto (Wajib 3)", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _imagePickerWidget(1, _foto1),
                  _imagePickerWidget(2, _foto2),
                  _imagePickerWidget(3, _foto3),
                ],
              ),
              SizedBox(height: 16),
              Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: getLocation, icon: Icon(Icons.location_on), label: Text("Dapatkan Lokasi")),
              Text(currentLocation ?? "Belum ada lokasi"),
              SizedBox(height: 16),
              isLoading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: submitReport, child: Text("Kirim Laporan")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerWidget(int index, XFile? imageFile) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: imageFile == null 
          ? Icon(Icons.camera_alt, color: Colors.grey) 
          : Image.file(File(imageFile.path), fit: BoxFit.cover),
      ),
    );
  }
}