// /// unduh file dari flutterviz- seret dan jatuhkan alat. Untuk detail lebih lanjut Kunjungi https://fluttereviz.io/nönnimport 'package:flutter/material.dart';

// class LprMasuk extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffebebeb),
//       appBar: AppBar(
//         elevation: 4,
//         centerTitle: false,
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xffb2dfff),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.zero,
//         ),
//         title: Text(
//           "Laporan Masuk",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             fontStyle: FontStyle.normal,
//             fontSize: 18,
//             color: Color(0xff000000),
//           ),
//         ),
//         leading: Icon(
//           Icons.arrow_back,
//           color: Color(0xff212435),
//           size: 24,
//         ),
//       ),
//       body: ListView(
//         scrollDirection: Axis.vertical,
//         padding: EdgeInsets.all(8),
//         shrinkWrap: true,
//         physics: ClampingScrollPhysics(),
//         children: [
//           Card(
//             margin: EdgeInsets.all(0),
//             color: Color(0xffffffff),
//             shadowColor: Color(0xff000000),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 MaterialButton(
//                   onPressed: () {},
//                   color: Color(0xffb2dfff),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                     side: BorderSide(color: Color(0xff000000), width: 1),
//                   ),
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     "Semua",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       fontStyle: FontStyle.normal,
//                     ),
//                   ),
//                   textColor: Color(0xff000000),
//                   height: 40,
//                   minWidth: 140,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
//                   child: MaterialButton(
//                     onPressed: () {},
//                     color: Color(0xffafdbfb),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       side: BorderSide(color: Color(0xff000000), width: 1),
//                     ),
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       "Ditolak",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         fontStyle: FontStyle.normal,
//                       ),
//                     ),
//                     textColor: Color(0xff000000),
//                     height: 40,
//                     minWidth: 140,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
//                   child: MaterialButton(
//                     onPressed: () {},
//                     color: Color(0xffb2dfff),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       side: BorderSide(color: Color(0xff000000), width: 1),
//                     ),
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       "Diterima",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         fontStyle: FontStyle.normal,
//                       ),
//                     ),
//                     textColor: Color(0xff000000),
//                     height: 40,
//                     minWidth: 140,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Card(
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//             color: Color(0xffffffff),
//             shadowColor: Color(0xff000000),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Text(
//                           "Pantau Bencana Banjir - Jakarta",
//                           textAlign: TextAlign.start,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.normal,
//                             fontSize: 16,
//                             color: Color(0xff000000),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Hujan yang mengguyur wilayah DKI Jakarta dan sekitarnya dari Minggu 26 Februari hingga Senin 27 Februari 2023 menyebabkan banjir terjadi tak bisa dihindari.",
//                             textAlign: TextAlign.start,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff7a7a7a),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "DKI Jakarta",
//                             textAlign: TextAlign.start,
//                             maxLines: 2,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff000000),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.more_vert,
//                     color: Color(0xff212435),
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Card(
//             margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
//             color: Color(0xffffffff),
//             shadowColor: Color(0xff000000),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Text(
//                           "Maling di Bogor Terekam CCTV Bobol Toko Kue",
//                           textAlign: TextAlign.start,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.normal,
//                             fontSize: 16,
//                             color: Color(0xff000000),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Aksi maling terekam CCTV membobol sebuah toko kue di Tajurhalang, Kabupaten Bogor. Polisi turun tangan melakukan penyelidikan",
//                             textAlign: TextAlign.start,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff7a7a7a),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Bogor",
//                             textAlign: TextAlign.start,
//                             maxLines: 2,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff000000),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
//                           child: Text(
//                             "",
//                             textAlign: TextAlign.start,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 11,
//                               color: Color(0xff000000),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.more_vert,
//                     color: Color(0xff212435),
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Card(
//             margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
//             color: Color(0xffffffff),
//             shadowColor: Color(0xff000000),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Text(
//                           "Banjir bandang dan tanah longsor yang tewaskan 20 orang di Pekalongan –",
//                           textAlign: TextAlign.start,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.normal,
//                             fontSize: 16,
//                             color: Color(0xff000000),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Sebanyak 20 orang meninggal dunia dan 14 orang lainnya mengalami luka di Petungkriyono, Kabupaten Pekalongan, akibat banjir bandang dan tanah longsor yang menerjang wilayah Jawa Tengah itu, Senin (20/1).",
//                             textAlign: TextAlign.start,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff7a7a7a),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Jawa Tengah",
//                             textAlign: TextAlign.start,
//                             maxLines: 2,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff000000),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.more_vert,
//                     color: Color(0xff212435),
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Card(
//             margin: EdgeInsets.all(0),
//             color: Color(0xffffffff),
//             shadowColor: Color(0xff000000),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Text(
//                           "Kondisi Jalan Rusak Berat di Kota Semarang",
//                           textAlign: TextAlign.start,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.normal,
//                             fontSize: 16,
//                             color: Color(0xff000000),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             " kondisi jalan yang kurang baik/ rusak dapat mengakibatkan terjadinya peningkatan angka kecelakaan.",
//                             textAlign: TextAlign.start,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff7a7a7a),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                           child: Text(
//                             "Semarang",
//                             textAlign: TextAlign.start,
//                             maxLines: 2,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontStyle: FontStyle.normal,
//                               fontSize: 12,
//                               color: Color(0xff000000),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.more_vert,
//                     color: Color(0xff212435),
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
