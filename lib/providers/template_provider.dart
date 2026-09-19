import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/hive_service.dart';
import '../../models/allocation_template.dart';

final templateListProvider =
    StateNotifierProvider<TemplateListNotifier, List<AllocationTemplate>>(
        (ref) {
  return TemplateListNotifier();
});

class TemplateListNotifier extends StateNotifier<List<AllocationTemplate>> {
  TemplateListNotifier() : super([]) {
    loadTemplates();
  }

  void loadTemplates() {
    state = HiveService.getAllTemplates();
  }

  Future<void> saveTemplate(
      AllocationTemplate template, List<AllocationTemplateItem> items) async {
    await HiveService.saveTemplate(template, items);
    loadTemplates();
  }
}
