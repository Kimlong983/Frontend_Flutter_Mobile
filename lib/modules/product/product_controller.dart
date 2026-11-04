import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/product_repository.dart';
import '../../models/product/product_category_model.dart';
import '../../models/product/product_model.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository;

  ProductController({required this.productRepository});

  final productList = <ProductModel>[].obs;
  final filteredProductList = <ProductModel>[].obs;
  final categories = <ProductCategoryModel>[].obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategoryId = Rxn<int>(); // null = all categories

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final items = await productRepository.getProducts();
      productList.assignAll(items);

      // GET /api/products embeds the category, so derive the filter chips from it.
      final byId = <int, ProductCategoryModel>{};
      for (final p in items) {
        if (p.category?.id != null) byId[p.category!.id!] = p.category!;
      }
      categories.assignAll(byId.values);
      if (!byId.containsKey(selectedCategoryId.value)) selectedCategoryId.value = null;

      _applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  void filterByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final categoryId = selectedCategoryId.value;

    filteredProductList.assignAll(productList.where((p) {
      final matchesSearch = query.isEmpty ||
          (p.name?.toLowerCase().contains(query) ?? false) ||
          (p.productCode?.toLowerCase().contains(query) ?? false) ||
          (p.description?.toLowerCase().contains(query) ?? false);
      final matchesCategory = categoryId == null || p.category?.id == categoryId;
      return matchesSearch && matchesCategory;
    }));
  }
}
