import 'package:dio/dio.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/features/allotment/domain/allotment_result_model.dart';

class AllotmentRepository {
  final DioClient dioClient;

  AllotmentRepository({required this.dioClient});

  Future<AllotmentCheckResultModel> checkAllotment({
    required String ipoId,
    required List<String> selectedPanIds,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.allotmentCheck,
        data: {
          'ipoId': ipoId,
          'selectedPanIds': selectedPanIds,
        },
      );

      return AllotmentCheckResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
