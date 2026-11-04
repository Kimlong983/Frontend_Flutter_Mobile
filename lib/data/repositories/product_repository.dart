import '../../constants/constant_uri.dart';
import '../../core/services/api_service.dart';
import '../../models/product/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
}

class ProductRepositoryImpl implements ProductRepository {
  final ApiService apiService;

  ProductRepositoryImpl({required this.apiService});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await apiService.get(ConstantUri.products);
    if (response is! List) return [];
    return response.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
