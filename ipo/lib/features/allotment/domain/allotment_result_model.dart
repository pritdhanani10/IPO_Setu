class PanResultModel {
  final String maskedPan;
  final String status; // ALLOTTED | NOT_ALLOTTED | NOT_AVAILABLE
  final int? shares;
  final double? amount;
  final String? message;

  const PanResultModel({
    required this.maskedPan,
    required this.status,
    this.shares,
    this.amount,
    this.message,
  });

  factory PanResultModel.fromJson(Map<String, dynamic> json) {
    return PanResultModel(
      maskedPan: json['maskedPan'] ?? '',
      status: json['status'] ?? 'NOT_AVAILABLE',
      shares: json['shares'] as int?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      message: json['message'],
    );
  }
}

class AllotmentCheckResultModel {
  final String companyName;
  final bool officialCheckRequired;
  final String? message;
  final String? officialStatusUrl;
  final List<PanResultModel> results;
  final int totalPansChecked;
  final int allottedCount;
  final int notAllottedCount;
  final int unavailableCount;

  const AllotmentCheckResultModel({
    required this.companyName,
    required this.officialCheckRequired,
    this.message,
    this.officialStatusUrl,
    required this.results,
    required this.totalPansChecked,
    required this.allottedCount,
    required this.notAllottedCount,
    required this.unavailableCount,
  });

  factory AllotmentCheckResultModel.fromJson(Map<String, dynamic> json) {
    return AllotmentCheckResultModel(
      companyName: json['companyName'] ?? '',
      officialCheckRequired: json['officialCheckRequired'] ?? true,
      message: json['message'],
      officialStatusUrl: json['officialStatusUrl'],
      results: json['results'] != null
          ? (json['results'] as List).map((r) => PanResultModel.fromJson(r as Map<String, dynamic>)).toList()
          : [],
      totalPansChecked: json['totalPansChecked'] ?? 0,
      allottedCount: json['allottedCount'] ?? 0,
      notAllottedCount: json['notAllottedCount'] ?? 0,
      unavailableCount: json['unavailableCount'] ?? 0,
    );
  }
}
