class UserModel {
  final String id;
  final String firebaseUid;
  final String mobileNumber;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.mobileNumber,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? json['id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
