class SavedPanModel {
  final String id;
  final String maskedPan;
  final String? label;
  final DateTime createdAt;

  const SavedPanModel({
    required this.id,
    required this.maskedPan,
    this.label,
    required this.createdAt,
  });

  factory SavedPanModel.fromJson(Map<String, dynamic> json) {
    return SavedPanModel(
      id: json['id'] ?? '',
      maskedPan: json['maskedPan'] ?? '',
      label: json['label'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
