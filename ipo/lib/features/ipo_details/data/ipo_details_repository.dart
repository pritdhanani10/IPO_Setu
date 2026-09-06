import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/features/auth/presentation/auth_controller.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/features/ipo_details/domain/ipo_detail_model.dart';

final ipoDetailsRepositoryProvider = Provider<IpoDetailsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return IpoDetailsRepository(dioClient: dioClient);
});

final ipoDetailProvider = FutureProvider.autoDispose.family<IpoDetailModel?, String>((ref, ipoId) async {
  final repository = ref.watch(ipoDetailsRepositoryProvider);
  return await repository.getIpoDetails(ipoId);
});

class IpoDetailsRepository {
  final DioClient dioClient;

  IpoDetailsRepository({required this.dioClient});

  Future<IpoDetailModel?> getIpoDetails(String ipoId) async {
    try {
      final response = await dioClient.dio.get('${ApiEndpoints.ipos}/$ipoId');
      if (response.data is Map<String, dynamic>) {
        return IpoDetailModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
