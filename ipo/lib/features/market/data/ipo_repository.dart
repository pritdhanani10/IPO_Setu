import 'package:dio/dio.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/network/dio_client.dart';
import 'package:ipo/features/market/domain/ipo_model.dart';

class IpoRepository {
  final DioClient dioClient;

  IpoRepository({required this.dioClient});

  Future<List<IpoModel>> getIpos({
    String? status,
    String? category,
    String? search,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.ipos,
        queryParameters: {
          if (status != null && status.isNotEmpty && status.toLowerCase() != 'all')
            'status': status.toLowerCase(),
          if (category != null && category.isNotEmpty && category.toLowerCase() != 'all')
            'category': category.toLowerCase(),
          if (search != null && search.isNotEmpty)
            'search': search,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => IpoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
