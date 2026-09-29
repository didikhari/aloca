import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Kelola Kategori',
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _SlidableCategoryTile(
              key: ValueKey(cat.id),
              category: cat,
              onTap: () => _showEditCategoryBottomSheet(context, ref, cat),
              onDelete: () => _handleDeleteCategory(context, ref, cat),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.textInverse,
        child: const Icon(Icons.add),
        onPressed: () => _showAddCategoryBottomSheet(context, ref),
      ),
    );
  }

  void _showEditCategoryBottomSheet(
      BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(ctx).size.width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dividerBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.brandPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Ubah Nama Kategori',
                        style: AppTypography.headingMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Tagihan & Utilitas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          textStyle: AppTypography.buttonLarge,
                        ),
                        onPressed: () {
                          final newName = nameController.text.trim();
                          if (newName.isNotEmpty) {
                            final updatedCat =
                                category.copyWith(name: newName);
                            ref
                                .read(categoryListProvider.notifier)
                                .updateCategory(updatedCat);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryBottomSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(ctx).size.width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dividerBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: AppColors.brandPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Tambah Kategori Baru',
                        style: AppTypography.headingMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Tagihan & Utilitas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          textStyle: AppTypography.buttonLarge,
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
                            ref
                                .read(categoryListProvider.notifier)
                                .addCategory(newCat);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDeleteCategory(
      BuildContext context, WidgetRef ref, Category category) {
    final allTransactions = HiveService.getAllTransactions();
    final allPlanned = HiveService.getAllPlannedExpenses();

    final hasTransactions =
        allTransactions.any((t) => t.categoryId == category.id);
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
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(categoryListProvider.notifier)
                  .deleteCategory(category.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Kategori "${category.name}" berhasil dihapus.'),
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

class _SlidableCategoryTile extends StatefulWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SlidableCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_SlidableCategoryTile> createState() => _SlidableCategoryTileState();
}

class _SlidableCategoryTileState extends State<_SlidableCategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0.0;
  static const double _actionWidth = 84.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0.0);
  }

  void _close() {
    _animateTo(0.0);
  }

  void _open() {
    _animateTo(-_actionWidth);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final isRevealed = _dragOffset < -10;

    Color color;
    try {
      color = Color(int.parse('FF${cat.colorHex.replaceAll('#', '')}',
          radix: 16));
    } catch (_) {
      color = AppColors.brandPrimary;
    }

    return ClipRRect(
      borderRadius: AppRadius.radiusCard,
      child: Stack(
        children: [
          // Background Red Delete Button
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _actionWidth,
            child: Material(
              color: AppColors.expenseRed,
              child: InkWell(
                onTap: () {
                  _close();
                  widget.onDelete();
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.textInverse,
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Foreground Sliding Card
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.primaryDelta!;
                if (_dragOffset > 0) _dragOffset = 0;
                if (_dragOffset < -_actionWidth) _dragOffset = -_actionWidth;
              });
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < -200 ||
                  _dragOffset < -_actionWidth / 2) {
                _open();
              } else {
                _close();
              }
            },
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surfaceWhite,
                onTap: () {
                  if (isRevealed) {
                    _close();
                  } else {
                    widget.onTap();
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Color Circle Indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Category Name
                    Expanded(
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Chevron Right Icon
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
