import 'package:dio/dio.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/features/pans/domain/saved_pan_model.dart';

class PanRepository {
  final DioClient dioClient;

  PanRepository({required this.dioClient});

  Future<List<SavedPanModel>> getPans() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.pans);
      if (response.data is List) {
        return (response.data as List)
            .map((item) => SavedPanModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }

  Future<SavedPanModel> addPan(String pan, String? label) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.pans,
        data: {
          'pan': pan.trim().toUpperCase(),
          'label': label?.trim().isNotEmpty == true ? label!.trim() : null,
        },
      );
      return SavedPanModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }

  Future<bool> deletePan(String panId) async {
    try {
      final response = await dioClient.dio.delete('${ApiEndpoints.pans}/$panId');
      return response.statusCode == 204 || response.statusCode == 200;
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
