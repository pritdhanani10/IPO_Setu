import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/core/services/secure_storage_service.dart';
import 'package:ipo/features/auth/data/auth_repository.dart';
import 'package:ipo/features/auth/domain/auth_state.dart';
import 'package:ipo/features/auth/domain/user_model.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dioClient: dioClient, storage: storage);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    checkInitialSession();
  }

  Future<void> checkInitialSession() async {
    final currentFbUser = _repository.currentFirebaseUser;
    if (currentFbUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: currentFbUser.uid,
          firebaseUid: currentFbUser.uid,
          mobileNumber: currentFbUser.phoneNumber ?? '',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp(String mobileNumber) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    // Ensure +91 Indian country code
    final formattedPhone = mobileNumber.startsWith('+') ? mobileNumber : '+91$mobileNumber';

    try {
      await _repository.sendOtp(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: formattedPhone,
          );
        },
        onVerificationFailed: (e) {
          final msg = (e.message != null && e.message!.isNotEmpty && e.message != 'Error')
              ? e.message!
              : 'Verification error [${e.code}]. Please verify settings or try again.';
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: msg,
          );
        },
        onVerificationCompleted: (credential) async {
          if (credential.smsCode != null && state.verificationId != null) {
            await verifyOtp(credential.smsCode!);
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
        resendToken: state.resendToken,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Session expired. Please request OTP again.');
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _repository.verifyOtpAndSync(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetToPhoneInput() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
