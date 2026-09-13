import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/hive_service.dart';
import '../../models/category.dart';

final categoryListProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  void loadCategories() {
    state = HiveService.getAllCategories();
  }

  Future<void> addCategory(Category category) async {
    await HiveService.saveCategory(category);
    loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await HiveService.saveCategory(category);
    loadCategories();
  }

  Future<void> toggleCategoryActive(String categoryId) async {
    final cat = state.firstWhere((c) => c.id == categoryId);
    final updated = cat.copyWith(isActive: !cat.isActive);
    await HiveService.saveCategory(updated);
    loadCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await HiveService.deleteCategory(categoryId);
    loadCategories();
  }
}
