import 'package:flutter/material.dart';
import '../models/report.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;

  ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.category,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(report.description),
            SizedBox(height: 10),
            Text('Status: ${report.status}', style: TextStyle(color: Colors.blue)),
            SizedBox(height: 10),
            Text('Alamat: ${report.address}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'http://your-laravel-api.com/storage/${report.photo1}',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Image.network(
                  'http://your-laravel-api.com/storage/${report.photo2}',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Image.network(
                  'http://your-laravel-api.com/storage/${report.photo3}',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tambahkan aksi jika ingin melakukan sesuatu di detail laporan
              },
              child: Text('Aksi Tambahan'),
            ),
          ],
        ),
      ),
    );
  }
}
