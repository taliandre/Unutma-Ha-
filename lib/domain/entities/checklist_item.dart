class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.iconCode,
    required this.isRequired,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String category;
  final int iconCode;
  final bool isRequired;
  final DateTime createdAt;

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    int? iconCode,
    bool? isRequired,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      isRequired: isRequired ?? this.isRequired,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
