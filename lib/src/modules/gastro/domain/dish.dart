import 'package:cloud_firestore/cloud_firestore.dart';

/// Individual dish within a menu
class DishModel {

  const DishModel({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.category,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        category: json['category'] as String?,
      );
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
      };
}

/// Menu containing multiple dishes from a merchant
class MenuModel {

  const MenuModel({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.dishes,
    required this.date,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id: json['id'] as String,
        merchantId: json['merchantId'] as String,
        merchantName: json['merchantName'] as String,
        dishes: (json['dishes'] as List<dynamic>)
            .map((d) => DishModel.fromJson(d as Map<String, dynamic>))
            .toList(),
        date: DateTime.parse(json['date'] as String),
        imageUrl: json['imageUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

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
  final String id;
  final String merchantId;
  final String merchantName;
  final List<DishModel> dishes;
  final DateTime date;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantId': merchantId,
        'merchantName': merchantName,
        'dishes': dishes.map((d) => d.toJson()).toList(),
        'date': date.toIso8601String(),
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
      };

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
