/// Minimal category representation for matching spreadsheet items to user categories.
class AvailableCategory {
  final int id;
  final String name;
  final String categoryType;

  const AvailableCategory({
    required this.id,
    required this.name,
    required this.categoryType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          categoryType == other.categoryType;

  @override
  int get hashCode => Object.hash(id, name, categoryType);

  @override
  String toString() => 'AvailableCategory($id: $name ($categoryType))';
}

/// The result of the smart matcher evaluating a raw spreadsheet label.
class SmartMatchResult {
  final String originalLabel;
  final String cleanName;
  final int? dueDay;
  final String suggestedCategoryName;
  final String suggestedCategoryType;
  final int? matchedCategoryId;
  final double confidence;
  final bool isDebt;

  const SmartMatchResult({
    required this.originalLabel,
    required this.cleanName,
    this.dueDay,
    required this.suggestedCategoryName,
    required this.suggestedCategoryType,
    this.matchedCategoryId,
    required this.confidence,
    this.isDebt = false,
  });

  bool get isAmbiguous => confidence < 0.7;

  SmartMatchResult copyWith({
    String? originalLabel,
    String? cleanName,
    int? dueDay,
    String? suggestedCategoryName,
    String? suggestedCategoryType,
    int? matchedCategoryId,
    double? confidence,
    bool? isDebt,
  }) {
    return SmartMatchResult(
      originalLabel: originalLabel ?? this.originalLabel,
      cleanName: cleanName ?? this.cleanName,
      dueDay: dueDay ?? this.dueDay,
      suggestedCategoryName:
          suggestedCategoryName ?? this.suggestedCategoryName,
      suggestedCategoryType:
          suggestedCategoryType ?? this.suggestedCategoryType,
      matchedCategoryId: matchedCategoryId ?? this.matchedCategoryId,
      confidence: confidence ?? this.confidence,
      isDebt: isDebt ?? this.isDebt,
    );
  }

  @override
  String toString() =>
      'SmartMatchResult("$cleanName", due: $dueDay, cat: "$suggestedCategoryName", type: $suggestedCategoryType, conf: $confidence)';
}
