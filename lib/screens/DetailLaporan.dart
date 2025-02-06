// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DetailLaporan extends StatefulWidget {
//   final int reportId; // Id laporan untuk fetch data dari backend
//   DetailLaporan({required this.reportId});

//   @override
//   _DetailLaporanState createState() => _DetailLaporanState();
// }

// class _DetailLaporanState extends State<DetailLaporan> {
//   late Map<String, dynamic> reportData = {};
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchReportData();
//   }

//   Future<void> fetchReportData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://example.com/api/report/${widget.reportId}'),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           reportData = json.decode(response.body);
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (error) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching data: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffffffff),
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: false,
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xffb8e3ff),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.zero,
//         ),
//         title: Text(
//           "Detail Laporan",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             fontSize: 15,
//             color: Color(0xff000000),
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xff212435)),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeader(),
//                   _buildDivider(),
//                   _buildDetailRow("Jenis Laporan", reportData['jenis_laporan']),
//                   _buildDivider(),
//                   _buildDetailRow("Alamat", reportData['alamat']),
//                   _buildDivider(),
//                   _buildDetailRow("Keterangan", reportData['keterangan']),
//                   _buildDivider(),
//                   _buildDetailRow("Lokasi", reportData['lokasi']),
//                   _buildDivider(),
//                   _buildImages(reportData['images']),
//                   _buildNextButton(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   reportData['name'] ?? 'Nama Pelapor',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 24,
//                     color: Color(0xff000000),
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   reportData['email'] ?? 'Email Pelapor',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 16,
//                     color: Color(0xff8e8e8e),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(
//               reportData['photo_url'] ?? 'https://picsum.photos/250?image=1',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String title, String? value) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                     color: Color(0xff000000),
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   value ?? '-',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: Color(0xff8e8e8e),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Divider(
//       color: Color(0xffc2c1c1),
//       height: 1,
//       thickness: 1,
//       indent: 16,
//       endIndent: 16,
//     );
//   }

//   Widget _buildImages(List<dynamic>? images) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Foto",
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//               color: Color(0xff000000),
//             ),
//           ),
//           SizedBox(height: 10),
//           if (images != null && images.isNotEmpty)
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: images.map((url) {
//                 return Image.network(
//                   url,
//                   height: 100,
//                   width: 140,
//                   fit: BoxFit.cover,
//                 );
//               }).toList(),
//             )
//           else
//             Text(
//               "Tidak ada foto tersedia.",
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//                 color: Color(0xff8e8e8e),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNextButton() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Lakukan sesuatu saat tombol "Selanjutnya" ditekan
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Color(0xff9bceff),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
//           child: Text("Selanjutnya"),
//         ),
//       ),
//     );
//   }
// }
