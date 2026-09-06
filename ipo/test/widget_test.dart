import 'package:flutter_test/flutter_test.dart';
import 'package:ipo/core/utils/formatters.dart';
import 'package:ipo/core/utils/pan_validator.dart';
import 'package:ipo/features/auth/domain/user_model.dart';
import 'package:ipo/features/market/domain/ipo_model.dart';

void main() {
  group('PAN Validator & Security Tests', () {
    test('Validates official 10-character Indian PAN format', () {
      expect(PanValidator.isValid('ABCDE1234F'), isTrue);
      expect(PanValidator.isValid('abcde1234f'), isTrue); // case insensitive
      expect(PanValidator.isValid('ABCD12345F'), isFalse); // wrong letter count
      expect(PanValidator.isValid('ABCDE12345'), isFalse); // ends with digit
      expect(PanValidator.isValid('12345ABCDE'), isFalse); // starts with digit
      expect(PanValidator.isValid(''), isFalse);
      expect(PanValidator.isValid(null), isFalse);
    });

    test('Masks PAN correctly concealing sensitive digits', () {
      expect(PanValidator.mask('ABCDE1234F'), equals('ABCDE****F'));
      expect(PanValidator.mask('PQRST9876K'), equals('PQRST****K'));
      expect(PanValidator.mask('invalid'), equals('**********'));
    });
  });

  group('Financial Formatters Tests', () {
    test('Formats currency with Indian rupee symbol', () {
      expect(Formatters.formatCurrency(14950), equals('₹14,950'));
      expect(Formatters.formatCurrency(null), equals('Not Available'));
    });

    test('Formats subscription multiples', () {
      expect(Formatters.formatMultiple(12.5), equals('12.50x'));
      expect(Formatters.formatMultiple(null), equals('Not Available'));
    });

    test('Formats shares count with commas', () {
      expect(Formatters.formatShares(14000), equals('14,000'));
      expect(Formatters.formatShares(null), equals('Not Available'));
    });
  });

  group('Domain Models Calculations & Safety Tests', () {
    test('Calculates minimum investment only when upper price and lot size are present', () {
      final ipoWithDetails = IpoModel.fromJson({
        'id': 'test-1',
        'companyName': 'Real Power Corp Ltd',
        'symbol': 'RPC',
        'category': 'mainboard',
        'status': 'open',
        'upperPrice': 500.0,
        'lotSize': 30,
        'lastUpdatedAt': DateTime.now().toIso8601String(),
      });

      expect(ipoWithDetails.minimumInvestment, equals(15000.0));

      final ipoMissingPrice = IpoModel.fromJson({
        'id': 'test-2',
        'companyName': 'Upcoming Enterprise Ltd',
        'symbol': 'UEL',
        'category': 'sme',
        'status': 'upcoming',
        'lastUpdatedAt': DateTime.now().toIso8601String(),
      });

      expect(ipoMissingPrice.minimumInvestment, isNull);
    });

    test('UserModel maps from backend sync response without email, name, or password', () {
      final user = UserModel.fromJson({
        'userId': '00000000-0000-0000-0000-000000000001',
        'firebaseUid': 'fb_uid_123',
        'mobileNumber': '+919876543210',
        'createdAt': DateTime.now().toIso8601String(),
      });

      expect(user.id, equals('00000000-0000-0000-0000-000000000001'));
      expect(user.firebaseUid, equals('fb_uid_123'));
      expect(user.mobileNumber, equals('+919876543210'));
    });
  });
}
