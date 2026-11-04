import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/product/product_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_bar_field.dart';
import 'product_controller.dart';
import 'widgets/product_detail_sheet.dart';
import 'widgets/product_image.dart';
import 'widgets/stock_badge.dart';

class ProductView extends GetView<ProductController> {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              SearchBarField(
                controller: controller.searchController,
                query: controller.searchQuery,
                hint: "Search products by name or code...",
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              Obx(() {
                if (controller.categories.isEmpty) return const SizedBox.shrink();
                final selected = controller.selectedCategoryId.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: "All",
                          isSelected: selected == null,
                          onTap: () => controller.filterByCategory(null),
                        ),
                        ...controller.categories.map((cat) => _CategoryChip(
                              label: cat.name ?? "Category",
                              isSelected: selected == cat.id,
                              onTap: () => controller.filterByCategory(cat.id),
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.productList.isEmpty) {
              return const LoadingWidget(message: "Loading products...");
            }
            if (controller.errorMessage.isNotEmpty && controller.productList.isEmpty) {
              return ErrorStateWidget(message: controller.errorMessage.value, onRetry: controller.fetchProducts);
            }
            if (controller.filteredProductList.isEmpty) {
              final searching = controller.searchQuery.value.isNotEmpty;
              return EmptyStateWidget(
                title: "No Products Found",
                subtitle: searching
                    ? "No products match '${controller.searchQuery.value}'"
                    : "There are no products in the catalog yet.",
                icon: Icons.inventory_2_outlined,
                actionText: "Refresh",
                onAction: controller.fetchProducts,
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchProducts,
              color: AppColors.primary,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredProductList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = controller.filteredProductList[index];
                  return _ProductCard(product: product, onTap: () => ProductDetailSheet.show(product));
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(product: product, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (product.productCode != null && product.productCode!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.productCode!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            product.categoryName,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name ?? "Unnamed Product",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        StockBadge(product: product, showQuantity: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
