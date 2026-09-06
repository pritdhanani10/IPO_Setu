import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyMobile = 'verified_mobile';

  Future<void> saveAuthSession({
    required String token,
    required String userId,
    required String mobileNumber,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyMobile, value: mobileNumber);
  }

  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getUserId() async => await _storage.read(key: _keyUserId);
  Future<String?> getMobile() async => await _storage.read(key: _keyMobile);

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
