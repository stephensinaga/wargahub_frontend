class ReportHistory {
  final String status;
  final String updatedBy;
  final DateTime updatedAt;

  ReportHistory({required this.status, required this.updatedBy, required this.updatedAt});

  factory ReportHistory.fromJson(Map<String, dynamic> json) {
    return ReportHistory(
      status: json['status'],
      updatedBy: json['user']['name'], // Pastikan backend mengirim user.name
      updatedAt: DateTime.parse(json['created_at']),
    );
  }
}
