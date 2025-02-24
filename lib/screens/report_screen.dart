import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wargahub_frontend/config/constant.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedReportType;
  String? selectedCity;
  String? selectedDistrict;

  XFile? _foto1, _foto2, _foto3;
  bool isLoading = false;

List<Map<String, dynamic>> cityList = [];
  List<String> districtList = [];

  final ImagePicker _picker = ImagePicker();
  final List<String> reportTypes = ["Kebersihan", "Keamanan", "Sosial", "Fasilitas Umum"];

  

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

Future<void> fetchCities() async {
      print("Fetching cities...");
  try {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/cities"));
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    
    if (response.statusCode == 200) {
      // Parsing JSON dengan aman
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        cityList = data.map((city) => {
          "id": city['id'],
          "name": city['name'],
          "districts": city['districts'].map((d) => d['name']).toList(),
        }).toList();
      });
    } else {
      print("API Error: ${response.statusCode} - ${response.body}");
      throw Exception("Gagal mengambil data kota: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    print("Error: $e");
    print(stackTrace); // ✅ Lihat detail error
  }
}



    void fetchDistricts(String cityName) {
      final selectedCityData = cityList.firstWhere(
        (city) => city['name'] == cityName,
        orElse: () => <String, dynamic>{}, // ✅ Pastikan default adalah Map<String, dynamic>
      );
      
      if (selectedCityData.isNotEmpty) {
        setState(() {
          districtList = List<String>.from(selectedCityData['districts']);
        });
      } else {
        setState(() {
          districtList = [];
        });
      }
    }

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

  Future<void> submitReport() async {
    if (_foto1 == null || _foto2 == null || _foto3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua foto wajib diunggah!")),
      );
      return;
    }

    if (selectedReportType == null || descriptionController.text.isEmpty || 
        selectedCity == null || selectedDistrict == null || addressController.text.isEmpty) {
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
        ..fields['kota'] = selectedCity ?? ''  // ✅ Pastikan nilai dikirim
        ..fields['kecamatan'] = selectedDistrict ?? ''
        ..fields['alamat'] = addressController.text;

      request.files.add(await http.MultipartFile.fromPath("photo_1", _foto1!.path));
      request.files.add(await http.MultipartFile.fromPath("photo_2", _foto2!.path));
      request.files.add(await http.MultipartFile.fromPath("photo_3", _foto3!.path));

      print("Fields: ${request.fields}");

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

            print("Server Response: ${response.statusCode}");
      print("Response Data: $responseData");

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

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context, true);
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
                // 🔹 Jenis Laporan
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

                // 🔹 Keterangan
                Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),

                // 🔹 Foto (Wajib 3)
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

                // 🔹 Kota
                Text("Kota", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items: cityList.isNotEmpty
                      ? cityList.map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city['name'] as String,
                            child: Text(city['name'] as String),
                          );
                        }).toList()
                      : [],
                  onChanged: cityList.isNotEmpty
                      ? (value) {
                          setState(() {
                            selectedCity = value;
                            selectedDistrict = null;
                            fetchDistricts(value!);
                          });
                        }
                      : null,
                ),
                SizedBox(height: 16),

                // 🔹 Kecamatan
                Text("Kecamatan", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  items: districtList.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedDistrict = value),
                ),
                SizedBox(height: 16),

                // 🔹 Alamat (Input Field yang Ditambahkan)
                Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: addressController,  // ✅ Tambahkan input untuk alamat
                  decoration: InputDecoration(
                    hintText: "Masukkan alamat lengkap",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 🔹 Tombol Kirim
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


