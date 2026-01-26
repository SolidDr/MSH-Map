import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dish_model.freezed.dart';
part 'dish_model.g.dart';

/// Individual dish within a menu
@freezed
class DishModel with _$DishModel {
  const factory DishModel({
    required String id,
    required String name,
    String? description,
    double? price,
    String? category,
  }) = _DishModel;

  factory DishModel.fromJson(Map<String, dynamic> json) =>
      _$DishModelFromJson(json);
}

/// Menu containing multiple dishes from a merchant
@freezed
class MenuModel with _$MenuModel {
  const MenuModel._();

  const factory MenuModel({
    required String id,
    required String merchantId,
    required String merchantName,
    required List<DishModel> dishes,
    required DateTime date,
    String? imageUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _MenuModel;

  factory MenuModel.fromJson(Map<String, dynamic> json) =>
      _$MenuModelFromJson(json);

  /// Create from Firestore document
  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      merchantId: data['merchantId'] as String,
      merchantName: data['merchantName'] as String,
      dishes: (data['dishes'] as List<dynamic>)
          .map((d) => DishModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() => {
        'merchantId': merchantId,
        'merchantName': merchantName,
        'dishes': dishes.map((d) => d.toJson()).toList(),
        'date': Timestamp.fromDate(date),
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
