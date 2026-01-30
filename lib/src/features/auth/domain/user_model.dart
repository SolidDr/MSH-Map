import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User roles in the application
enum UserRole {
  customer,
  merchant,
}

/// User model representing authenticated users
@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(UserRole.customer) UserRole role,
    String? merchantId,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
