import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/hive_service.dart';
import '../../core/services/excel_service.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final lastBackupStr = HiveService.getSetting('last_backup_date');
    DateTime? lastBackup;
    if (lastBackupStr != null) {
      lastBackup = DateTime.tryParse(lastBackupStr);
    }

    final daysSinceBackup = lastBackup != null
        ? DateTime.now().difference(lastBackup).inDays
        : null;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore Excel',
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 14-Day Backup Status Card
              CustomCard(
                backgroundColor:
                    (daysSinceBackup == null || daysSinceBackup > 14)
                        ? AppColors.warningBgLight
                        : AppColors.statusUnderBudgetBg,
                child: Row(
                  children: [
                    Icon(
                      (daysSinceBackup == null || daysSinceBackup > 14)
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_outlined,
                      color: (daysSinceBackup == null || daysSinceBackup > 14)
                          ? AppColors.warningAmberDark
                          : AppColors.statusUnderBudgetFg,
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            daysSinceBackup == null
                                ? 'Belum Ada Backup Tersimpan'
                                : (daysSinceBackup > 14
                                    ? 'Backup Terakhir $daysSinceBackup Hari Yang Lalu'
                                    : 'Data Keuangan Terbackup Sesuai Rencana'),
                            style: AppTypography.headingSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lastBackup != null
                                ? 'Terakhir dikirim ke file Excel pada ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(lastBackup)}'
                                : 'Lakukan backup berkala ke Google Drive / HP Anda.',
                            style: AppTypography.labelStandard,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Export Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.file_upload_outlined,
                            color: AppColors.brandPrimary),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Export Data ke Excel (.xlsx)',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headingSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Menghasilkan workbook Excel berisi 7 sheet terstruktur (FinancialPeriods, Income, Categories, Allocations, Templates, TemplateItems, Transactions). Anda dapat menyimpannya ke Google Drive atau penyimpanan HP.',
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: AppColors.textInverse,
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text('Export & Simpan Excel'),
                        onPressed: _isLoading ? null : _handleExport,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Import & Restore Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.file_download_outlined,
                            color: AppColors.infoBlue),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Import / Restore Data dari Excel',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headingSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Memulihkan database lokal dari file backup Excel. Proses ini akan menggantikan (Replace All) data lokal aplikasi saat ini setelah Anda melakukan konfirmasi.',
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.infoBlue,
                          side: const BorderSide(color: AppColors.infoBlue),
                        ),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Pilih File Excel Backup'),
                        onPressed: _isLoading ? null : _handleImport,
                      ),
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

  void _handleExport() async {
    setState(() => _isLoading = true);
    final filePath = await ExcelService.exportData();
    setState(() => _isLoading = false);

    if (mounted && filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File Excel berhasil di-generate & dibagikan!')),
      );
    }
  }

  void _handleImport() async {
    setState(() => _isLoading = true);
    final res = await ExcelService.importAndValidate();
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == false) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Gagal Membaca File'),
          content: Text(res['message'] as String),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Explicit Confirmation Dialog before Replace All
    final summaryText = res['summaryText'] as String;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Restore Data'),
          content: Text(
            '$summaryText\n\n'
            'PERINGATAN: Tindakan ini akan MENIMPA SELURUH (Replace All) data keuangan di HP ini dengan isi dari file backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
                foregroundColor: AppColors.textInverse,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await HiveService.replaceDatabase(
                  periods: res['periods'],
                  incomes: res['incomes'],
                  categories: res['categories'],
                  templates: res['templates'],
                  templateItems: res['templateItems'],
                  allocations: res['allocations'],
                  transactions: res['transactions'],
                  plannedExpenses: res['plannedExpenses'] ?? [],
                );

                ref.read(periodListProvider.notifier).loadPeriods();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data berhasil dipulihkan dari Excel!')),
                  );
                }
              },
              child: const Text('Timpah & Restore'),
            ),
          ],
        );
      },
    );
  }
}
