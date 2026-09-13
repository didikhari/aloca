class AllocationTemplateItem {
  final String id;
  final String templateId;
  final String categoryId;
  final String method; // 'percentage', 'fixed', 'remaining'
  final double value; // percentage (e.g. 20.0) or fixed amount in Rp

  AllocationTemplateItem({
    required this.id,
    required this.templateId,
    required this.categoryId,
    required this.method,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'categoryId': categoryId,
      'method': method,
      'value': value,
    };
  }

  factory AllocationTemplateItem.fromMap(Map<String, dynamic> map) {
    return AllocationTemplateItem(
      id: map['id'] as String,
      templateId: map['templateId'] as String,
      categoryId: map['categoryId'] as String,
      method: map['method'] as String? ?? 'percentage',
      value: (map['value'] as num).toDouble(),
    );
  }
}

class AllocationTemplate {
  final String id;
  final String name;
  final bool isDefault;

  AllocationTemplate({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
    };
  }

  factory AllocationTemplate.fromMap(Map<String, dynamic> map) {
    return AllocationTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}
