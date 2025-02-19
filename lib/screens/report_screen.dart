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
  List<File> images = [];
  String? currentLocation;
  double? latitude;
  double? longitude;
  bool isLoading = false;

  final List<String> reportTypes = [
    "Kebersihan",
    "Keamanan",
    "Sosial",
    "Fasilitas Umum",
  ];

  final picker = ImagePicker();

  /// Fungsi untuk memilih gambar dari galeri
  Future<void> pickImage() async {
    if (images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maksimal 3 gambar!")),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  /// Fungsi untuk mendapatkan lokasi pengguna dengan akurasi tinggi
  Future<void> getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aktifkan layanan lokasi!")),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Izin lokasi ditolak!")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Izin lokasi diblokir secara permanen!")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      Placemark place = placemarks.first;

      setState(() {
        currentLocation = "${place.street}, ${place.locality}, ${place.subAdministrativeArea}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lokasi diperoleh!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
      );
    }
  }

  /// Fungsi untuk mengirim laporan ke API
  Future<void> submitReport() async {
    if (selectedReportType == null || images.length < 3 || descriptionController.text.isEmpty || currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap lengkapi semua data!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');  // Mengambil token

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
      ..fields['category'] = selectedReportType!
      ..fields['description'] = descriptionController.text
      ..fields['location'] = currentLocation!
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString();

    for (var i = 0; i < images.length; i++) {
      request.files.add(await http.MultipartFile.fromPath("images[]", images[i].path));
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var decodedData = jsonDecode(responseData);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Laporan berhasil dikirim!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decodedData['message'] ?? "Gagal mengirim laporan!")),
        );
      }
    } catch (e) {
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
              DropdownButtonFormField<String>(
                value: selectedReportType,
                items: reportTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedReportType = value;
                  });
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),

              Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),

              Text("Foto (Minimal 3)", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Pilih Gambar"),
              ),
              Wrap(
                spacing: 10,
                children: images.map((image) {
                  return Stack(
                    children: [
                      Image.file(image, width: 80, height: 80, fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              images.remove(image);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: getLocation,
                icon: Icon(Icons.location_on),
                label: Text("Dapatkan Lokasi"),
              ),
              Text(currentLocation ?? "Belum ada lokasi"),
              SizedBox(height: 16),

              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submitReport,
                      child: Text("Kirim Laporan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
