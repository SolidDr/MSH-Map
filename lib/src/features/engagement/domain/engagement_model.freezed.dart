// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'engagement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EngagementPlace _$EngagementPlaceFromJson(Map<String, dynamic> json) {
  return _EngagementPlace.fromJson(json);
}

/// @nodoc
mixin _$EngagementPlace {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  EngagementType get type => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError; // Adresse
  String? get street => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError; // Kontakt
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError; // Details
  String? get description => throw _privateConstructorUsedError;
  String? get openingHours =>
      throw _privateConstructorUsedError; // Engagement-spezifisch
  List<EngagementNeed> get currentNeeds => throw _privateConstructorUsedError;
  List<AdoptableAnimal> get adoptableAnimals =>
      throw _privateConstructorUsedError; // Darstellung
  String? get imageUrl => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError; // Meta
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  String? get dataSource => throw _privateConstructorUsedError;

  /// Serializes this EngagementPlace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EngagementPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EngagementPlaceCopyWith<EngagementPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngagementPlaceCopyWith<$Res> {
  factory $EngagementPlaceCopyWith(
          EngagementPlace value, $Res Function(EngagementPlace) then) =
      _$EngagementPlaceCopyWithImpl<$Res, EngagementPlace>;
  @useResult
  $Res call(
      {String id,
      String name,
      EngagementType type,
      double latitude,
      double longitude,
      String? street,
      String? city,
      String? postalCode,
      String? phone,
      String? email,
      String? website,
      String? description,
      String? openingHours,
      List<EngagementNeed> currentNeeds,
      List<AdoptableAnimal> adoptableAnimals,
      String? imageUrl,
      bool isVerified,
      DateTime? lastUpdated,
      String? dataSource});
}

/// @nodoc
class _$EngagementPlaceCopyWithImpl<$Res, $Val extends EngagementPlace>
    implements $EngagementPlaceCopyWith<$Res> {
  _$EngagementPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EngagementPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? street = freezed,
    Object? city = freezed,
    Object? postalCode = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? currentNeeds = null,
    Object? adoptableAnimals = null,
    Object? imageUrl = freezed,
    Object? isVerified = null,
    Object? lastUpdated = freezed,
    Object? dataSource = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EngagementType,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      street: freezed == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      currentNeeds: null == currentNeeds
          ? _value.currentNeeds
          : currentNeeds // ignore: cast_nullable_to_non_nullable
              as List<EngagementNeed>,
      adoptableAnimals: null == adoptableAnimals
          ? _value.adoptableAnimals
          : adoptableAnimals // ignore: cast_nullable_to_non_nullable
              as List<AdoptableAnimal>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dataSource: freezed == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EngagementPlaceImplCopyWith<$Res>
    implements $EngagementPlaceCopyWith<$Res> {
  factory _$$EngagementPlaceImplCopyWith(_$EngagementPlaceImpl value,
          $Res Function(_$EngagementPlaceImpl) then) =
      __$$EngagementPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      EngagementType type,
      double latitude,
      double longitude,
      String? street,
      String? city,
      String? postalCode,
      String? phone,
      String? email,
      String? website,
      String? description,
      String? openingHours,
      List<EngagementNeed> currentNeeds,
      List<AdoptableAnimal> adoptableAnimals,
      String? imageUrl,
      bool isVerified,
      DateTime? lastUpdated,
      String? dataSource});
}

/// @nodoc
class __$$EngagementPlaceImplCopyWithImpl<$Res>
    extends _$EngagementPlaceCopyWithImpl<$Res, _$EngagementPlaceImpl>
    implements _$$EngagementPlaceImplCopyWith<$Res> {
  __$$EngagementPlaceImplCopyWithImpl(
      _$EngagementPlaceImpl _value, $Res Function(_$EngagementPlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of EngagementPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? street = freezed,
    Object? city = freezed,
    Object? postalCode = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? currentNeeds = null,
    Object? adoptableAnimals = null,
    Object? imageUrl = freezed,
    Object? isVerified = null,
    Object? lastUpdated = freezed,
    Object? dataSource = freezed,
  }) {
    return _then(_$EngagementPlaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EngagementType,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      street: freezed == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      currentNeeds: null == currentNeeds
          ? _value._currentNeeds
          : currentNeeds // ignore: cast_nullable_to_non_nullable
              as List<EngagementNeed>,
      adoptableAnimals: null == adoptableAnimals
          ? _value._adoptableAnimals
          : adoptableAnimals // ignore: cast_nullable_to_non_nullable
              as List<AdoptableAnimal>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dataSource: freezed == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EngagementPlaceImpl extends _EngagementPlace {
  const _$EngagementPlaceImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.latitude,
      required this.longitude,
      this.street,
      this.city,
      this.postalCode,
      this.phone,
      this.email,
      this.website,
      this.description,
      this.openingHours,
      final List<EngagementNeed> currentNeeds = const [],
      final List<AdoptableAnimal> adoptableAnimals = const [],
      this.imageUrl,
      this.isVerified = false,
      this.lastUpdated,
      this.dataSource})
      : _currentNeeds = currentNeeds,
        _adoptableAnimals = adoptableAnimals,
        super._();

  factory _$EngagementPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngagementPlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final EngagementType type;
  @override
  final double latitude;
  @override
  final double longitude;
// Adresse
  @override
  final String? street;
  @override
  final String? city;
  @override
  final String? postalCode;
// Kontakt
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
// Details
  @override
  final String? description;
  @override
  final String? openingHours;
// Engagement-spezifisch
  final List<EngagementNeed> _currentNeeds;
// Engagement-spezifisch
  @override
  @JsonKey()
  List<EngagementNeed> get currentNeeds {
    if (_currentNeeds is EqualUnmodifiableListView) return _currentNeeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentNeeds);
  }

  final List<AdoptableAnimal> _adoptableAnimals;
  @override
  @JsonKey()
  List<AdoptableAnimal> get adoptableAnimals {
    if (_adoptableAnimals is EqualUnmodifiableListView)
      return _adoptableAnimals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_adoptableAnimals);
  }

// Darstellung
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final bool isVerified;
// Meta
  @override
  final DateTime? lastUpdated;
  @override
  final String? dataSource;

  @override
  String toString() {
    return 'EngagementPlace(id: $id, name: $name, type: $type, latitude: $latitude, longitude: $longitude, street: $street, city: $city, postalCode: $postalCode, phone: $phone, email: $email, website: $website, description: $description, openingHours: $openingHours, currentNeeds: $currentNeeds, adoptableAnimals: $adoptableAnimals, imageUrl: $imageUrl, isVerified: $isVerified, lastUpdated: $lastUpdated, dataSource: $dataSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngagementPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            const DeepCollectionEquality()
                .equals(other._currentNeeds, _currentNeeds) &&
            const DeepCollectionEquality()
                .equals(other._adoptableAnimals, _adoptableAnimals) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        type,
        latitude,
        longitude,
        street,
        city,
        postalCode,
        phone,
        email,
        website,
        description,
        openingHours,
        const DeepCollectionEquality().hash(_currentNeeds),
        const DeepCollectionEquality().hash(_adoptableAnimals),
        imageUrl,
        isVerified,
        lastUpdated,
        dataSource
      ]);

  /// Create a copy of EngagementPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EngagementPlaceImplCopyWith<_$EngagementPlaceImpl> get copyWith =>
      __$$EngagementPlaceImplCopyWithImpl<_$EngagementPlaceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngagementPlaceImplToJson(
      this,
    );
  }
}

abstract class _EngagementPlace extends EngagementPlace {
  const factory _EngagementPlace(
      {required final String id,
      required final String name,
      required final EngagementType type,
      required final double latitude,
      required final double longitude,
      final String? street,
      final String? city,
      final String? postalCode,
      final String? phone,
      final String? email,
      final String? website,
      final String? description,
      final String? openingHours,
      final List<EngagementNeed> currentNeeds,
      final List<AdoptableAnimal> adoptableAnimals,
      final String? imageUrl,
      final bool isVerified,
      final DateTime? lastUpdated,
      final String? dataSource}) = _$EngagementPlaceImpl;
  const _EngagementPlace._() : super._();

  factory _EngagementPlace.fromJson(Map<String, dynamic> json) =
      _$EngagementPlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  EngagementType get type;
  @override
  double get latitude;
  @override
  double get longitude; // Adresse
  @override
  String? get street;
  @override
  String? get city;
  @override
  String? get postalCode; // Kontakt
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website; // Details
  @override
  String? get description;
  @override
  String? get openingHours; // Engagement-spezifisch
  @override
  List<EngagementNeed> get currentNeeds;
  @override
  List<AdoptableAnimal> get adoptableAnimals; // Darstellung
  @override
  String? get imageUrl;
  @override
  bool get isVerified; // Meta
  @override
  DateTime? get lastUpdated;
  @override
  String? get dataSource;

  /// Create a copy of EngagementPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EngagementPlaceImplCopyWith<_$EngagementPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EngagementNeed _$EngagementNeedFromJson(Map<String, dynamic> json) {
  return _EngagementNeed.fromJson(json);
}

/// @nodoc
mixin _$EngagementNeed {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  UrgencyLevel get urgency => throw _privateConstructorUsedError;
  NeedCategory get category => throw _privateConstructorUsedError; // Zeitrahmen
  DateTime? get neededBy => throw _privateConstructorUsedError;
  DateTime? get validUntil => throw _privateConstructorUsedError; // Details
  String? get contactPerson => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  String? get contactEmail =>
      throw _privateConstructorUsedError; // Quantität (wenn messbar)
  int? get targetAmount => throw _privateConstructorUsedError;
  int? get currentAmount => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError; // Meta
  DateTime? get createdAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this EngagementNeed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EngagementNeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EngagementNeedCopyWith<EngagementNeed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngagementNeedCopyWith<$Res> {
  factory $EngagementNeedCopyWith(
          EngagementNeed value, $Res Function(EngagementNeed) then) =
      _$EngagementNeedCopyWithImpl<$Res, EngagementNeed>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      UrgencyLevel urgency,
      NeedCategory category,
      DateTime? neededBy,
      DateTime? validUntil,
      String? contactPerson,
      String? contactPhone,
      String? contactEmail,
      int? targetAmount,
      int? currentAmount,
      String? unit,
      DateTime? createdAt,
      bool isActive});
}

/// @nodoc
class _$EngagementNeedCopyWithImpl<$Res, $Val extends EngagementNeed>
    implements $EngagementNeedCopyWith<$Res> {
  _$EngagementNeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EngagementNeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? urgency = null,
    Object? category = null,
    Object? neededBy = freezed,
    Object? validUntil = freezed,
    Object? contactPerson = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? targetAmount = freezed,
    Object? currentAmount = freezed,
    Object? unit = freezed,
    Object? createdAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NeedCategory,
      neededBy: freezed == neededBy
          ? _value.neededBy
          : neededBy // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contactPerson: freezed == contactPerson
          ? _value.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: freezed == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      currentAmount: freezed == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EngagementNeedImplCopyWith<$Res>
    implements $EngagementNeedCopyWith<$Res> {
  factory _$$EngagementNeedImplCopyWith(_$EngagementNeedImpl value,
          $Res Function(_$EngagementNeedImpl) then) =
      __$$EngagementNeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      UrgencyLevel urgency,
      NeedCategory category,
      DateTime? neededBy,
      DateTime? validUntil,
      String? contactPerson,
      String? contactPhone,
      String? contactEmail,
      int? targetAmount,
      int? currentAmount,
      String? unit,
      DateTime? createdAt,
      bool isActive});
}

/// @nodoc
class __$$EngagementNeedImplCopyWithImpl<$Res>
    extends _$EngagementNeedCopyWithImpl<$Res, _$EngagementNeedImpl>
    implements _$$EngagementNeedImplCopyWith<$Res> {
  __$$EngagementNeedImplCopyWithImpl(
      _$EngagementNeedImpl _value, $Res Function(_$EngagementNeedImpl) _then)
      : super(_value, _then);

  /// Create a copy of EngagementNeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? urgency = null,
    Object? category = null,
    Object? neededBy = freezed,
    Object? validUntil = freezed,
    Object? contactPerson = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? targetAmount = freezed,
    Object? currentAmount = freezed,
    Object? unit = freezed,
    Object? createdAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_$EngagementNeedImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NeedCategory,
      neededBy: freezed == neededBy
          ? _value.neededBy
          : neededBy // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contactPerson: freezed == contactPerson
          ? _value.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: freezed == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      currentAmount: freezed == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EngagementNeedImpl extends _EngagementNeed {
  const _$EngagementNeedImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.urgency,
      required this.category,
      this.neededBy,
      this.validUntil,
      this.contactPerson,
      this.contactPhone,
      this.contactEmail,
      this.targetAmount,
      this.currentAmount,
      this.unit,
      this.createdAt,
      this.isActive = true})
      : super._();

  factory _$EngagementNeedImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngagementNeedImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final UrgencyLevel urgency;
  @override
  final NeedCategory category;
// Zeitrahmen
  @override
  final DateTime? neededBy;
  @override
  final DateTime? validUntil;
// Details
  @override
  final String? contactPerson;
  @override
  final String? contactPhone;
  @override
  final String? contactEmail;
// Quantität (wenn messbar)
  @override
  final int? targetAmount;
  @override
  final int? currentAmount;
  @override
  final String? unit;
// Meta
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'EngagementNeed(id: $id, title: $title, description: $description, urgency: $urgency, category: $category, neededBy: $neededBy, validUntil: $validUntil, contactPerson: $contactPerson, contactPhone: $contactPhone, contactEmail: $contactEmail, targetAmount: $targetAmount, currentAmount: $currentAmount, unit: $unit, createdAt: $createdAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngagementNeedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.urgency, urgency) || other.urgency == urgency) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.neededBy, neededBy) ||
                other.neededBy == neededBy) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      urgency,
      category,
      neededBy,
      validUntil,
      contactPerson,
      contactPhone,
      contactEmail,
      targetAmount,
      currentAmount,
      unit,
      createdAt,
      isActive);

  /// Create a copy of EngagementNeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EngagementNeedImplCopyWith<_$EngagementNeedImpl> get copyWith =>
      __$$EngagementNeedImplCopyWithImpl<_$EngagementNeedImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngagementNeedImplToJson(
      this,
    );
  }
}

abstract class _EngagementNeed extends EngagementNeed {
  const factory _EngagementNeed(
      {required final String id,
      required final String title,
      required final String description,
      required final UrgencyLevel urgency,
      required final NeedCategory category,
      final DateTime? neededBy,
      final DateTime? validUntil,
      final String? contactPerson,
      final String? contactPhone,
      final String? contactEmail,
      final int? targetAmount,
      final int? currentAmount,
      final String? unit,
      final DateTime? createdAt,
      final bool isActive}) = _$EngagementNeedImpl;
  const _EngagementNeed._() : super._();

  factory _EngagementNeed.fromJson(Map<String, dynamic> json) =
      _$EngagementNeedImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  UrgencyLevel get urgency;
  @override
  NeedCategory get category; // Zeitrahmen
  @override
  DateTime? get neededBy;
  @override
  DateTime? get validUntil; // Details
  @override
  String? get contactPerson;
  @override
  String? get contactPhone;
  @override
  String? get contactEmail; // Quantität (wenn messbar)
  @override
  int? get targetAmount;
  @override
  int? get currentAmount;
  @override
  String? get unit; // Meta
  @override
  DateTime? get createdAt;
  @override
  bool get isActive;

  /// Create a copy of EngagementNeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EngagementNeedImplCopyWith<_$EngagementNeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdoptableAnimal _$AdoptableAnimalFromJson(Map<String, dynamic> json) {
  return _AdoptableAnimal.fromJson(json);
}

/// @nodoc
mixin _$AdoptableAnimal {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AnimalType get type => throw _privateConstructorUsedError; // Eigenschaften
  String? get breed => throw _privateConstructorUsedError;
  String? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError; // Beschreibung
  String? get description => throw _privateConstructorUsedError;
  String? get character => throw _privateConstructorUsedError;
  List<String> get specialNeeds => throw _privateConstructorUsedError; // Bilder
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get additionalImages =>
      throw _privateConstructorUsedError; // Status
  bool get isUrgent => throw _privateConstructorUsedError;
  bool get isReserved => throw _privateConstructorUsedError;
  DateTime? get availableSince => throw _privateConstructorUsedError; // Kontakt
  String? get contactInfo => throw _privateConstructorUsedError;

  /// Serializes this AdoptableAnimal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdoptableAnimal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdoptableAnimalCopyWith<AdoptableAnimal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdoptableAnimalCopyWith<$Res> {
  factory $AdoptableAnimalCopyWith(
          AdoptableAnimal value, $Res Function(AdoptableAnimal) then) =
      _$AdoptableAnimalCopyWithImpl<$Res, AdoptableAnimal>;
  @useResult
  $Res call(
      {String id,
      String name,
      AnimalType type,
      String? breed,
      String? age,
      String? gender,
      String? size,
      String? description,
      String? character,
      List<String> specialNeeds,
      String? imageUrl,
      List<String> additionalImages,
      bool isUrgent,
      bool isReserved,
      DateTime? availableSince,
      String? contactInfo});
}

/// @nodoc
class _$AdoptableAnimalCopyWithImpl<$Res, $Val extends AdoptableAnimal>
    implements $AdoptableAnimalCopyWith<$Res> {
  _$AdoptableAnimalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdoptableAnimal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? breed = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? size = freezed,
    Object? description = freezed,
    Object? character = freezed,
    Object? specialNeeds = null,
    Object? imageUrl = freezed,
    Object? additionalImages = null,
    Object? isUrgent = null,
    Object? isReserved = null,
    Object? availableSince = freezed,
    Object? contactInfo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnimalType,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      character: freezed == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as String?,
      specialNeeds: null == specialNeeds
          ? _value.specialNeeds
          : specialNeeds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value.additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      isReserved: null == isReserved
          ? _value.isReserved
          : isReserved // ignore: cast_nullable_to_non_nullable
              as bool,
      availableSince: freezed == availableSince
          ? _value.availableSince
          : availableSince // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contactInfo: freezed == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdoptableAnimalImplCopyWith<$Res>
    implements $AdoptableAnimalCopyWith<$Res> {
  factory _$$AdoptableAnimalImplCopyWith(_$AdoptableAnimalImpl value,
          $Res Function(_$AdoptableAnimalImpl) then) =
      __$$AdoptableAnimalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      AnimalType type,
      String? breed,
      String? age,
      String? gender,
      String? size,
      String? description,
      String? character,
      List<String> specialNeeds,
      String? imageUrl,
      List<String> additionalImages,
      bool isUrgent,
      bool isReserved,
      DateTime? availableSince,
      String? contactInfo});
}

/// @nodoc
class __$$AdoptableAnimalImplCopyWithImpl<$Res>
    extends _$AdoptableAnimalCopyWithImpl<$Res, _$AdoptableAnimalImpl>
    implements _$$AdoptableAnimalImplCopyWith<$Res> {
  __$$AdoptableAnimalImplCopyWithImpl(
      _$AdoptableAnimalImpl _value, $Res Function(_$AdoptableAnimalImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdoptableAnimal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? breed = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? size = freezed,
    Object? description = freezed,
    Object? character = freezed,
    Object? specialNeeds = null,
    Object? imageUrl = freezed,
    Object? additionalImages = null,
    Object? isUrgent = null,
    Object? isReserved = null,
    Object? availableSince = freezed,
    Object? contactInfo = freezed,
  }) {
    return _then(_$AdoptableAnimalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnimalType,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      character: freezed == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as String?,
      specialNeeds: null == specialNeeds
          ? _value._specialNeeds
          : specialNeeds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value._additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      isReserved: null == isReserved
          ? _value.isReserved
          : isReserved // ignore: cast_nullable_to_non_nullable
              as bool,
      availableSince: freezed == availableSince
          ? _value.availableSince
          : availableSince // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contactInfo: freezed == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdoptableAnimalImpl extends _AdoptableAnimal {
  const _$AdoptableAnimalImpl(
      {required this.id,
      required this.name,
      required this.type,
      this.breed,
      this.age,
      this.gender,
      this.size,
      this.description,
      this.character,
      final List<String> specialNeeds = const [],
      this.imageUrl,
      final List<String> additionalImages = const [],
      this.isUrgent = false,
      this.isReserved = false,
      this.availableSince,
      this.contactInfo})
      : _specialNeeds = specialNeeds,
        _additionalImages = additionalImages,
        super._();

  factory _$AdoptableAnimalImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdoptableAnimalImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final AnimalType type;
// Eigenschaften
  @override
  final String? breed;
  @override
  final String? age;
  @override
  final String? gender;
  @override
  final String? size;
// Beschreibung
  @override
  final String? description;
  @override
  final String? character;
  final List<String> _specialNeeds;
  @override
  @JsonKey()
  List<String> get specialNeeds {
    if (_specialNeeds is EqualUnmodifiableListView) return _specialNeeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialNeeds);
  }

// Bilder
  @override
  final String? imageUrl;
  final List<String> _additionalImages;
  @override
  @JsonKey()
  List<String> get additionalImages {
    if (_additionalImages is EqualUnmodifiableListView)
      return _additionalImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_additionalImages);
  }

// Status
  @override
  @JsonKey()
  final bool isUrgent;
  @override
  @JsonKey()
  final bool isReserved;
  @override
  final DateTime? availableSince;
// Kontakt
  @override
  final String? contactInfo;

  @override
  String toString() {
    return 'AdoptableAnimal(id: $id, name: $name, type: $type, breed: $breed, age: $age, gender: $gender, size: $size, description: $description, character: $character, specialNeeds: $specialNeeds, imageUrl: $imageUrl, additionalImages: $additionalImages, isUrgent: $isUrgent, isReserved: $isReserved, availableSince: $availableSince, contactInfo: $contactInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdoptableAnimalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.breed, breed) || other.breed == breed) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.character, character) ||
                other.character == character) &&
            const DeepCollectionEquality()
                .equals(other._specialNeeds, _specialNeeds) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._additionalImages, _additionalImages) &&
            (identical(other.isUrgent, isUrgent) ||
                other.isUrgent == isUrgent) &&
            (identical(other.isReserved, isReserved) ||
                other.isReserved == isReserved) &&
            (identical(other.availableSince, availableSince) ||
                other.availableSince == availableSince) &&
            (identical(other.contactInfo, contactInfo) ||
                other.contactInfo == contactInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      breed,
      age,
      gender,
      size,
      description,
      character,
      const DeepCollectionEquality().hash(_specialNeeds),
      imageUrl,
      const DeepCollectionEquality().hash(_additionalImages),
      isUrgent,
      isReserved,
      availableSince,
      contactInfo);

  /// Create a copy of AdoptableAnimal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdoptableAnimalImplCopyWith<_$AdoptableAnimalImpl> get copyWith =>
      __$$AdoptableAnimalImplCopyWithImpl<_$AdoptableAnimalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdoptableAnimalImplToJson(
      this,
    );
  }
}

abstract class _AdoptableAnimal extends AdoptableAnimal {
  const factory _AdoptableAnimal(
      {required final String id,
      required final String name,
      required final AnimalType type,
      final String? breed,
      final String? age,
      final String? gender,
      final String? size,
      final String? description,
      final String? character,
      final List<String> specialNeeds,
      final String? imageUrl,
      final List<String> additionalImages,
      final bool isUrgent,
      final bool isReserved,
      final DateTime? availableSince,
      final String? contactInfo}) = _$AdoptableAnimalImpl;
  const _AdoptableAnimal._() : super._();

  factory _AdoptableAnimal.fromJson(Map<String, dynamic> json) =
      _$AdoptableAnimalImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  AnimalType get type; // Eigenschaften
  @override
  String? get breed;
  @override
  String? get age;
  @override
  String? get gender;
  @override
  String? get size; // Beschreibung
  @override
  String? get description;
  @override
  String? get character;
  @override
  List<String> get specialNeeds; // Bilder
  @override
  String? get imageUrl;
  @override
  List<String> get additionalImages; // Status
  @override
  bool get isUrgent;
  @override
  bool get isReserved;
  @override
  DateTime? get availableSince; // Kontakt
  @override
  String? get contactInfo;

  /// Create a copy of AdoptableAnimal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdoptableAnimalImplCopyWith<_$AdoptableAnimalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
