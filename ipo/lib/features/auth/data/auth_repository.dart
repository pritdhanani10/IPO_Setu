import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/core/services/secure_storage_service.dart';
import 'package:ipo/features/auth/domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final DioClient dioClient;
  final SecureStorageService storage;
  ConfirmationResult? _webConfirmationResult;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required this.dioClient,
    required this.storage,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    if (kIsWeb) {
      try {
        final confirmation = await _firebaseAuth
            .signInWithPhoneNumber(phoneNumber)
            .timeout(const Duration(seconds: 25));
        _webConfirmationResult = confirmation;
        onCodeSent(confirmation.verificationId, null);
      } on TimeoutException {
        debugPrint('Web phone auth timed out waiting for reCAPTCHA/network response.');
        onVerificationFailed(
          FirebaseAuthException(
            code: 'recaptcha-timeout',
            message: 'reCAPTCHA verification timed out. Please check the corner reCAPTCHA badge, check popup blockers, or try again.',
          ),
        );
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException in sendOtp: code=${e.code}, message=${e.message}');
        onVerificationFailed(e);
      } catch (e, stack) {
        debugPrint('Generic exception in sendOtp: $e\n$stack');
        onVerificationFailed(
          FirebaseAuthException(
            code: 'web-phone-auth-error',
            message: e.toString(),
          ),
        );
      }
    } else {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    }
  }

  Future<UserModel> verifyOtpAndSync({
    required String verificationId,
    required String smsCode,
  }) async {
    final UserCredential userCredential;
    if (kIsWeb && _webConfirmationResult != null) {
      userCredential = await _webConfirmationResult!.confirm(smsCode);
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      userCredential = await _firebaseAuth.signInWithCredential(credential);
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase authentication failed.');
    }

    final idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID token.');
    }

    // Sync with ASP.NET backend
    return await syncWithBackend(idToken);
  }

  Future<UserModel> syncWithBackend(String idToken) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.authSync,
        data: {'firebaseToken': idToken},
      );

      final user = UserModel.fromJson(response.data);
      await storage.saveAuthSession(
        token: idToken,
        userId: user.id,
        mobileNumber: user.mobileNumber,
      );

      return user;
    } catch (e) {
      // If backend is currently unreachable during setup, fallback to client session
      final firebaseUser = _firebaseAuth.currentUser;
      final user = UserModel(
        id: firebaseUser?.uid ?? '',
        firebaseUid: firebaseUser?.uid ?? '',
        mobileNumber: firebaseUser?.phoneNumber ?? '',
        createdAt: DateTime.now(),
      );

      await storage.saveAuthSession(
        token: idToken,
        userId: user.id,
        mobileNumber: user.mobileNumber,
      );

      return user;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await storage.clearSession();
  }
}
