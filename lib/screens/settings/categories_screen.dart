import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/custom_card.dart';

import '../../core/database/hive_service.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final cat = categories[index];
            Color color;
            try {
              color = Color(int.parse('FF${cat.colorHex.replaceAll('#', '')}', radix: 16));
            } catch (_) {
              color = const Color(0xFF00A884);
            }

            return CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                    tooltip: 'Ubah Nama Kategori',
                    onPressed: () => _showEditCategoryDialog(context, ref, cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    tooltip: 'Hapus Kategori',
                    onPressed: () => _handleDeleteCategory(context, ref, cat),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A884),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddCategoryDialog(context, ref),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Nama Kategori'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Misal: Tagihan & Utilitas',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  final updatedCat = category.copyWith(name: newName);
                  ref.read(categoryListProvider.notifier).updateCategory(updatedCat);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nama Kategori (misal: Tagihan)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  const uuid = Uuid();
                  final newCat = Category(
                    id: 'cat_${uuid.v4()}',
                    name: name,
                    colorHex: '#3B82F6',
                    displayOrder: 99,
                  );
                  ref.read(categoryListProvider.notifier).addCategory(newCat);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteCategory(BuildContext context, WidgetRef ref, Category category) {
    final allTransactions = HiveService.getAllTransactions();
    final allPlanned = HiveService.getAllPlannedExpenses();

    final hasTransactions = allTransactions.any((t) => t.categoryId == category.id);
    final hasPlanned = allPlanned.any((pe) => pe.categoryId == category.id);

    if (hasTransactions || hasPlanned) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kategori Tidak Dapat Dihapus'),
          content: Text(
            'Kategori "${category.name}" tidak dapat dihapus karena sudah memiliki riwayat transaksi atau rencana pengeluaran.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(categoryListProvider.notifier).deleteCategory(category.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kategori "${category.name}" berhasil dihapus.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
