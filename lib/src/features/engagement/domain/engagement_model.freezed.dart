// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'engagement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EngagementPlace {

 String get id; String get name; EngagementType get type; double get latitude; double get longitude;// Adresse
 String? get street; String? get city; String? get postalCode;// Kontakt
 String? get phone; String? get email; String? get website;// Details
 String? get description; String? get openingHours;// Engagement-spezifisch
 List<EngagementNeed> get currentNeeds; List<AdoptableAnimal> get adoptableAnimals;// Darstellung
 String? get imageUrl; bool get isVerified;// Meta
 DateTime? get lastUpdated; String? get dataSource;
/// Create a copy of EngagementPlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EngagementPlaceCopyWith<EngagementPlace> get copyWith => _$EngagementPlaceCopyWithImpl<EngagementPlace>(this as EngagementPlace, _$identity);

  /// Serializes this EngagementPlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngagementPlace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.description, description) || other.description == description)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&const DeepCollectionEquality().equals(other.currentNeeds, currentNeeds)&&const DeepCollectionEquality().equals(other.adoptableAnimals, adoptableAnimals)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,latitude,longitude,street,city,postalCode,phone,email,website,description,openingHours,const DeepCollectionEquality().hash(currentNeeds),const DeepCollectionEquality().hash(adoptableAnimals),imageUrl,isVerified,lastUpdated,dataSource]);

@override
String toString() {
  return 'EngagementPlace(id: $id, name: $name, type: $type, latitude: $latitude, longitude: $longitude, street: $street, city: $city, postalCode: $postalCode, phone: $phone, email: $email, website: $website, description: $description, openingHours: $openingHours, currentNeeds: $currentNeeds, adoptableAnimals: $adoptableAnimals, imageUrl: $imageUrl, isVerified: $isVerified, lastUpdated: $lastUpdated, dataSource: $dataSource)';
}


}

/// @nodoc
abstract mixin class $EngagementPlaceCopyWith<$Res>  {
  factory $EngagementPlaceCopyWith(EngagementPlace value, $Res Function(EngagementPlace) _then) = _$EngagementPlaceCopyWithImpl;
@useResult
$Res call({
 String id, String name, EngagementType type, double latitude, double longitude, String? street, String? city, String? postalCode, String? phone, String? email, String? website, String? description, String? openingHours, List<EngagementNeed> currentNeeds, List<AdoptableAnimal> adoptableAnimals, String? imageUrl, bool isVerified, DateTime? lastUpdated, String? dataSource
});




}
/// @nodoc
class _$EngagementPlaceCopyWithImpl<$Res>
    implements $EngagementPlaceCopyWith<$Res> {
  _$EngagementPlaceCopyWithImpl(this._self, this._then);

  final EngagementPlace _self;
  final $Res Function(EngagementPlace) _then;

/// Create a copy of EngagementPlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? latitude = null,Object? longitude = null,Object? street = freezed,Object? city = freezed,Object? postalCode = freezed,Object? phone = freezed,Object? email = freezed,Object? website = freezed,Object? description = freezed,Object? openingHours = freezed,Object? currentNeeds = null,Object? adoptableAnimals = null,Object? imageUrl = freezed,Object? isVerified = null,Object? lastUpdated = freezed,Object? dataSource = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EngagementType,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,currentNeeds: null == currentNeeds ? _self.currentNeeds : currentNeeds // ignore: cast_nullable_to_non_nullable
as List<EngagementNeed>,adoptableAnimals: null == adoptableAnimals ? _self.adoptableAnimals : adoptableAnimals // ignore: cast_nullable_to_non_nullable
as List<AdoptableAnimal>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EngagementPlace].
extension EngagementPlacePatterns on EngagementPlace {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EngagementPlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EngagementPlace() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EngagementPlace value)  $default,){
final _that = this;
switch (_that) {
case _EngagementPlace():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EngagementPlace value)?  $default,){
final _that = this;
switch (_that) {
case _EngagementPlace() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  EngagementType type,  double latitude,  double longitude,  String? street,  String? city,  String? postalCode,  String? phone,  String? email,  String? website,  String? description,  String? openingHours,  List<EngagementNeed> currentNeeds,  List<AdoptableAnimal> adoptableAnimals,  String? imageUrl,  bool isVerified,  DateTime? lastUpdated,  String? dataSource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EngagementPlace() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.latitude,_that.longitude,_that.street,_that.city,_that.postalCode,_that.phone,_that.email,_that.website,_that.description,_that.openingHours,_that.currentNeeds,_that.adoptableAnimals,_that.imageUrl,_that.isVerified,_that.lastUpdated,_that.dataSource);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  EngagementType type,  double latitude,  double longitude,  String? street,  String? city,  String? postalCode,  String? phone,  String? email,  String? website,  String? description,  String? openingHours,  List<EngagementNeed> currentNeeds,  List<AdoptableAnimal> adoptableAnimals,  String? imageUrl,  bool isVerified,  DateTime? lastUpdated,  String? dataSource)  $default,) {final _that = this;
switch (_that) {
case _EngagementPlace():
return $default(_that.id,_that.name,_that.type,_that.latitude,_that.longitude,_that.street,_that.city,_that.postalCode,_that.phone,_that.email,_that.website,_that.description,_that.openingHours,_that.currentNeeds,_that.adoptableAnimals,_that.imageUrl,_that.isVerified,_that.lastUpdated,_that.dataSource);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  EngagementType type,  double latitude,  double longitude,  String? street,  String? city,  String? postalCode,  String? phone,  String? email,  String? website,  String? description,  String? openingHours,  List<EngagementNeed> currentNeeds,  List<AdoptableAnimal> adoptableAnimals,  String? imageUrl,  bool isVerified,  DateTime? lastUpdated,  String? dataSource)?  $default,) {final _that = this;
switch (_that) {
case _EngagementPlace() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.latitude,_that.longitude,_that.street,_that.city,_that.postalCode,_that.phone,_that.email,_that.website,_that.description,_that.openingHours,_that.currentNeeds,_that.adoptableAnimals,_that.imageUrl,_that.isVerified,_that.lastUpdated,_that.dataSource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EngagementPlace extends EngagementPlace {
  const _EngagementPlace({required this.id, required this.name, required this.type, required this.latitude, required this.longitude, this.street, this.city, this.postalCode, this.phone, this.email, this.website, this.description, this.openingHours, final  List<EngagementNeed> currentNeeds = const [], final  List<AdoptableAnimal> adoptableAnimals = const [], this.imageUrl, this.isVerified = false, this.lastUpdated, this.dataSource}): _currentNeeds = currentNeeds,_adoptableAnimals = adoptableAnimals,super._();
  factory _EngagementPlace.fromJson(Map<String, dynamic> json) => _$EngagementPlaceFromJson(json);

@override final  String id;
@override final  String name;
@override final  EngagementType type;
@override final  double latitude;
@override final  double longitude;
// Adresse
@override final  String? street;
@override final  String? city;
@override final  String? postalCode;
// Kontakt
@override final  String? phone;
@override final  String? email;
@override final  String? website;
// Details
@override final  String? description;
@override final  String? openingHours;
// Engagement-spezifisch
 final  List<EngagementNeed> _currentNeeds;
// Engagement-spezifisch
@override@JsonKey() List<EngagementNeed> get currentNeeds {
  if (_currentNeeds is EqualUnmodifiableListView) return _currentNeeds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currentNeeds);
}

 final  List<AdoptableAnimal> _adoptableAnimals;
@override@JsonKey() List<AdoptableAnimal> get adoptableAnimals {
  if (_adoptableAnimals is EqualUnmodifiableListView) return _adoptableAnimals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adoptableAnimals);
}

// Darstellung
@override final  String? imageUrl;
@override@JsonKey() final  bool isVerified;
// Meta
@override final  DateTime? lastUpdated;
@override final  String? dataSource;

/// Create a copy of EngagementPlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EngagementPlaceCopyWith<_EngagementPlace> get copyWith => __$EngagementPlaceCopyWithImpl<_EngagementPlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EngagementPlaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EngagementPlace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.description, description) || other.description == description)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&const DeepCollectionEquality().equals(other._currentNeeds, _currentNeeds)&&const DeepCollectionEquality().equals(other._adoptableAnimals, _adoptableAnimals)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,latitude,longitude,street,city,postalCode,phone,email,website,description,openingHours,const DeepCollectionEquality().hash(_currentNeeds),const DeepCollectionEquality().hash(_adoptableAnimals),imageUrl,isVerified,lastUpdated,dataSource]);

@override
String toString() {
  return 'EngagementPlace(id: $id, name: $name, type: $type, latitude: $latitude, longitude: $longitude, street: $street, city: $city, postalCode: $postalCode, phone: $phone, email: $email, website: $website, description: $description, openingHours: $openingHours, currentNeeds: $currentNeeds, adoptableAnimals: $adoptableAnimals, imageUrl: $imageUrl, isVerified: $isVerified, lastUpdated: $lastUpdated, dataSource: $dataSource)';
}


}

/// @nodoc
abstract mixin class _$EngagementPlaceCopyWith<$Res> implements $EngagementPlaceCopyWith<$Res> {
  factory _$EngagementPlaceCopyWith(_EngagementPlace value, $Res Function(_EngagementPlace) _then) = __$EngagementPlaceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, EngagementType type, double latitude, double longitude, String? street, String? city, String? postalCode, String? phone, String? email, String? website, String? description, String? openingHours, List<EngagementNeed> currentNeeds, List<AdoptableAnimal> adoptableAnimals, String? imageUrl, bool isVerified, DateTime? lastUpdated, String? dataSource
});




}
/// @nodoc
class __$EngagementPlaceCopyWithImpl<$Res>
    implements _$EngagementPlaceCopyWith<$Res> {
  __$EngagementPlaceCopyWithImpl(this._self, this._then);

  final _EngagementPlace _self;
  final $Res Function(_EngagementPlace) _then;

/// Create a copy of EngagementPlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? latitude = null,Object? longitude = null,Object? street = freezed,Object? city = freezed,Object? postalCode = freezed,Object? phone = freezed,Object? email = freezed,Object? website = freezed,Object? description = freezed,Object? openingHours = freezed,Object? currentNeeds = null,Object? adoptableAnimals = null,Object? imageUrl = freezed,Object? isVerified = null,Object? lastUpdated = freezed,Object? dataSource = freezed,}) {
  return _then(_EngagementPlace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EngagementType,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,currentNeeds: null == currentNeeds ? _self._currentNeeds : currentNeeds // ignore: cast_nullable_to_non_nullable
as List<EngagementNeed>,adoptableAnimals: null == adoptableAnimals ? _self._adoptableAnimals : adoptableAnimals // ignore: cast_nullable_to_non_nullable
as List<AdoptableAnimal>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EngagementNeed {

 String get id; String get title; String get description; UrgencyLevel get urgency; NeedCategory get category;// Zeitrahmen
 DateTime? get neededBy; DateTime? get validUntil;// Details
 String? get contactPerson; String? get contactPhone; String? get contactEmail;// Quantität (wenn messbar)
 int? get targetAmount; int? get currentAmount; String? get unit;// Meta
 DateTime? get createdAt; bool get isActive;
/// Create a copy of EngagementNeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EngagementNeedCopyWith<EngagementNeed> get copyWith => _$EngagementNeedCopyWithImpl<EngagementNeed>(this as EngagementNeed, _$identity);

  /// Serializes this EngagementNeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngagementNeed&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.category, category) || other.category == category)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,urgency,category,neededBy,validUntil,contactPerson,contactPhone,contactEmail,targetAmount,currentAmount,unit,createdAt,isActive);

@override
String toString() {
  return 'EngagementNeed(id: $id, title: $title, description: $description, urgency: $urgency, category: $category, neededBy: $neededBy, validUntil: $validUntil, contactPerson: $contactPerson, contactPhone: $contactPhone, contactEmail: $contactEmail, targetAmount: $targetAmount, currentAmount: $currentAmount, unit: $unit, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $EngagementNeedCopyWith<$Res>  {
  factory $EngagementNeedCopyWith(EngagementNeed value, $Res Function(EngagementNeed) _then) = _$EngagementNeedCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, UrgencyLevel urgency, NeedCategory category, DateTime? neededBy, DateTime? validUntil, String? contactPerson, String? contactPhone, String? contactEmail, int? targetAmount, int? currentAmount, String? unit, DateTime? createdAt, bool isActive
});




}
/// @nodoc
class _$EngagementNeedCopyWithImpl<$Res>
    implements $EngagementNeedCopyWith<$Res> {
  _$EngagementNeedCopyWithImpl(this._self, this._then);

  final EngagementNeed _self;
  final $Res Function(EngagementNeed) _then;

/// Create a copy of EngagementNeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? urgency = null,Object? category = null,Object? neededBy = freezed,Object? validUntil = freezed,Object? contactPerson = freezed,Object? contactPhone = freezed,Object? contactEmail = freezed,Object? targetAmount = freezed,Object? currentAmount = freezed,Object? unit = freezed,Object? createdAt = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as UrgencyLevel,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as NeedCategory,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int?,currentAmount: freezed == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EngagementNeed].
extension EngagementNeedPatterns on EngagementNeed {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EngagementNeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EngagementNeed() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EngagementNeed value)  $default,){
final _that = this;
switch (_that) {
case _EngagementNeed():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EngagementNeed value)?  $default,){
final _that = this;
switch (_that) {
case _EngagementNeed() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  UrgencyLevel urgency,  NeedCategory category,  DateTime? neededBy,  DateTime? validUntil,  String? contactPerson,  String? contactPhone,  String? contactEmail,  int? targetAmount,  int? currentAmount,  String? unit,  DateTime? createdAt,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EngagementNeed() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.urgency,_that.category,_that.neededBy,_that.validUntil,_that.contactPerson,_that.contactPhone,_that.contactEmail,_that.targetAmount,_that.currentAmount,_that.unit,_that.createdAt,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  UrgencyLevel urgency,  NeedCategory category,  DateTime? neededBy,  DateTime? validUntil,  String? contactPerson,  String? contactPhone,  String? contactEmail,  int? targetAmount,  int? currentAmount,  String? unit,  DateTime? createdAt,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _EngagementNeed():
return $default(_that.id,_that.title,_that.description,_that.urgency,_that.category,_that.neededBy,_that.validUntil,_that.contactPerson,_that.contactPhone,_that.contactEmail,_that.targetAmount,_that.currentAmount,_that.unit,_that.createdAt,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  UrgencyLevel urgency,  NeedCategory category,  DateTime? neededBy,  DateTime? validUntil,  String? contactPerson,  String? contactPhone,  String? contactEmail,  int? targetAmount,  int? currentAmount,  String? unit,  DateTime? createdAt,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _EngagementNeed() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.urgency,_that.category,_that.neededBy,_that.validUntil,_that.contactPerson,_that.contactPhone,_that.contactEmail,_that.targetAmount,_that.currentAmount,_that.unit,_that.createdAt,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EngagementNeed extends EngagementNeed {
  const _EngagementNeed({required this.id, required this.title, required this.description, required this.urgency, required this.category, this.neededBy, this.validUntil, this.contactPerson, this.contactPhone, this.contactEmail, this.targetAmount, this.currentAmount, this.unit, this.createdAt, this.isActive = true}): super._();
  factory _EngagementNeed.fromJson(Map<String, dynamic> json) => _$EngagementNeedFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  UrgencyLevel urgency;
@override final  NeedCategory category;
// Zeitrahmen
@override final  DateTime? neededBy;
@override final  DateTime? validUntil;
// Details
@override final  String? contactPerson;
@override final  String? contactPhone;
@override final  String? contactEmail;
// Quantität (wenn messbar)
@override final  int? targetAmount;
@override final  int? currentAmount;
@override final  String? unit;
// Meta
@override final  DateTime? createdAt;
@override@JsonKey() final  bool isActive;

/// Create a copy of EngagementNeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EngagementNeedCopyWith<_EngagementNeed> get copyWith => __$EngagementNeedCopyWithImpl<_EngagementNeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EngagementNeedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EngagementNeed&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.category, category) || other.category == category)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,urgency,category,neededBy,validUntil,contactPerson,contactPhone,contactEmail,targetAmount,currentAmount,unit,createdAt,isActive);

@override
String toString() {
  return 'EngagementNeed(id: $id, title: $title, description: $description, urgency: $urgency, category: $category, neededBy: $neededBy, validUntil: $validUntil, contactPerson: $contactPerson, contactPhone: $contactPhone, contactEmail: $contactEmail, targetAmount: $targetAmount, currentAmount: $currentAmount, unit: $unit, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$EngagementNeedCopyWith<$Res> implements $EngagementNeedCopyWith<$Res> {
  factory _$EngagementNeedCopyWith(_EngagementNeed value, $Res Function(_EngagementNeed) _then) = __$EngagementNeedCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, UrgencyLevel urgency, NeedCategory category, DateTime? neededBy, DateTime? validUntil, String? contactPerson, String? contactPhone, String? contactEmail, int? targetAmount, int? currentAmount, String? unit, DateTime? createdAt, bool isActive
});




}
/// @nodoc
class __$EngagementNeedCopyWithImpl<$Res>
    implements _$EngagementNeedCopyWith<$Res> {
  __$EngagementNeedCopyWithImpl(this._self, this._then);

  final _EngagementNeed _self;
  final $Res Function(_EngagementNeed) _then;

/// Create a copy of EngagementNeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? urgency = null,Object? category = null,Object? neededBy = freezed,Object? validUntil = freezed,Object? contactPerson = freezed,Object? contactPhone = freezed,Object? contactEmail = freezed,Object? targetAmount = freezed,Object? currentAmount = freezed,Object? unit = freezed,Object? createdAt = freezed,Object? isActive = null,}) {
  return _then(_EngagementNeed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as UrgencyLevel,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as NeedCategory,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int?,currentAmount: freezed == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AdoptableAnimal {

 String get id; String get name; AnimalType get type;// Eigenschaften
 String? get breed; String? get age; String? get gender; String? get size;// Beschreibung
 String? get description; String? get character; List<String> get specialNeeds;// Bilder
 String? get imageUrl; List<String> get additionalImages;// Status
 bool get isUrgent; bool get isReserved; DateTime? get availableSince;// Kontakt
 String? get contactInfo;
/// Create a copy of AdoptableAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdoptableAnimalCopyWith<AdoptableAnimal> get copyWith => _$AdoptableAnimalCopyWithImpl<AdoptableAnimal>(this as AdoptableAnimal, _$identity);

  /// Serializes this AdoptableAnimal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdoptableAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.size, size) || other.size == size)&&(identical(other.description, description) || other.description == description)&&(identical(other.character, character) || other.character == character)&&const DeepCollectionEquality().equals(other.specialNeeds, specialNeeds)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.additionalImages, additionalImages)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.isReserved, isReserved) || other.isReserved == isReserved)&&(identical(other.availableSince, availableSince) || other.availableSince == availableSince)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,breed,age,gender,size,description,character,const DeepCollectionEquality().hash(specialNeeds),imageUrl,const DeepCollectionEquality().hash(additionalImages),isUrgent,isReserved,availableSince,contactInfo);

@override
String toString() {
  return 'AdoptableAnimal(id: $id, name: $name, type: $type, breed: $breed, age: $age, gender: $gender, size: $size, description: $description, character: $character, specialNeeds: $specialNeeds, imageUrl: $imageUrl, additionalImages: $additionalImages, isUrgent: $isUrgent, isReserved: $isReserved, availableSince: $availableSince, contactInfo: $contactInfo)';
}


}

/// @nodoc
abstract mixin class $AdoptableAnimalCopyWith<$Res>  {
  factory $AdoptableAnimalCopyWith(AdoptableAnimal value, $Res Function(AdoptableAnimal) _then) = _$AdoptableAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String name, AnimalType type, String? breed, String? age, String? gender, String? size, String? description, String? character, List<String> specialNeeds, String? imageUrl, List<String> additionalImages, bool isUrgent, bool isReserved, DateTime? availableSince, String? contactInfo
});




}
/// @nodoc
class _$AdoptableAnimalCopyWithImpl<$Res>
    implements $AdoptableAnimalCopyWith<$Res> {
  _$AdoptableAnimalCopyWithImpl(this._self, this._then);

  final AdoptableAnimal _self;
  final $Res Function(AdoptableAnimal) _then;

/// Create a copy of AdoptableAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? breed = freezed,Object? age = freezed,Object? gender = freezed,Object? size = freezed,Object? description = freezed,Object? character = freezed,Object? specialNeeds = null,Object? imageUrl = freezed,Object? additionalImages = null,Object? isUrgent = null,Object? isReserved = null,Object? availableSince = freezed,Object? contactInfo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AnimalType,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,specialNeeds: null == specialNeeds ? _self.specialNeeds : specialNeeds // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,additionalImages: null == additionalImages ? _self.additionalImages : additionalImages // ignore: cast_nullable_to_non_nullable
as List<String>,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,isReserved: null == isReserved ? _self.isReserved : isReserved // ignore: cast_nullable_to_non_nullable
as bool,availableSince: freezed == availableSince ? _self.availableSince : availableSince // ignore: cast_nullable_to_non_nullable
as DateTime?,contactInfo: freezed == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdoptableAnimal].
extension AdoptableAnimalPatterns on AdoptableAnimal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdoptableAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdoptableAnimal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdoptableAnimal value)  $default,){
final _that = this;
switch (_that) {
case _AdoptableAnimal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdoptableAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _AdoptableAnimal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  AnimalType type,  String? breed,  String? age,  String? gender,  String? size,  String? description,  String? character,  List<String> specialNeeds,  String? imageUrl,  List<String> additionalImages,  bool isUrgent,  bool isReserved,  DateTime? availableSince,  String? contactInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdoptableAnimal() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.breed,_that.age,_that.gender,_that.size,_that.description,_that.character,_that.specialNeeds,_that.imageUrl,_that.additionalImages,_that.isUrgent,_that.isReserved,_that.availableSince,_that.contactInfo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  AnimalType type,  String? breed,  String? age,  String? gender,  String? size,  String? description,  String? character,  List<String> specialNeeds,  String? imageUrl,  List<String> additionalImages,  bool isUrgent,  bool isReserved,  DateTime? availableSince,  String? contactInfo)  $default,) {final _that = this;
switch (_that) {
case _AdoptableAnimal():
return $default(_that.id,_that.name,_that.type,_that.breed,_that.age,_that.gender,_that.size,_that.description,_that.character,_that.specialNeeds,_that.imageUrl,_that.additionalImages,_that.isUrgent,_that.isReserved,_that.availableSince,_that.contactInfo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  AnimalType type,  String? breed,  String? age,  String? gender,  String? size,  String? description,  String? character,  List<String> specialNeeds,  String? imageUrl,  List<String> additionalImages,  bool isUrgent,  bool isReserved,  DateTime? availableSince,  String? contactInfo)?  $default,) {final _that = this;
switch (_that) {
case _AdoptableAnimal() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.breed,_that.age,_that.gender,_that.size,_that.description,_that.character,_that.specialNeeds,_that.imageUrl,_that.additionalImages,_that.isUrgent,_that.isReserved,_that.availableSince,_that.contactInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdoptableAnimal extends AdoptableAnimal {
  const _AdoptableAnimal({required this.id, required this.name, required this.type, this.breed, this.age, this.gender, this.size, this.description, this.character, final  List<String> specialNeeds = const [], this.imageUrl, final  List<String> additionalImages = const [], this.isUrgent = false, this.isReserved = false, this.availableSince, this.contactInfo}): _specialNeeds = specialNeeds,_additionalImages = additionalImages,super._();
  factory _AdoptableAnimal.fromJson(Map<String, dynamic> json) => _$AdoptableAnimalFromJson(json);

@override final  String id;
@override final  String name;
@override final  AnimalType type;
// Eigenschaften
@override final  String? breed;
@override final  String? age;
@override final  String? gender;
@override final  String? size;
// Beschreibung
@override final  String? description;
@override final  String? character;
 final  List<String> _specialNeeds;
@override@JsonKey() List<String> get specialNeeds {
  if (_specialNeeds is EqualUnmodifiableListView) return _specialNeeds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialNeeds);
}

// Bilder
@override final  String? imageUrl;
 final  List<String> _additionalImages;
@override@JsonKey() List<String> get additionalImages {
  if (_additionalImages is EqualUnmodifiableListView) return _additionalImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_additionalImages);
}

// Status
@override@JsonKey() final  bool isUrgent;
@override@JsonKey() final  bool isReserved;
@override final  DateTime? availableSince;
// Kontakt
@override final  String? contactInfo;

/// Create a copy of AdoptableAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdoptableAnimalCopyWith<_AdoptableAnimal> get copyWith => __$AdoptableAnimalCopyWithImpl<_AdoptableAnimal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdoptableAnimalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdoptableAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.size, size) || other.size == size)&&(identical(other.description, description) || other.description == description)&&(identical(other.character, character) || other.character == character)&&const DeepCollectionEquality().equals(other._specialNeeds, _specialNeeds)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._additionalImages, _additionalImages)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.isReserved, isReserved) || other.isReserved == isReserved)&&(identical(other.availableSince, availableSince) || other.availableSince == availableSince)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,breed,age,gender,size,description,character,const DeepCollectionEquality().hash(_specialNeeds),imageUrl,const DeepCollectionEquality().hash(_additionalImages),isUrgent,isReserved,availableSince,contactInfo);

@override
String toString() {
  return 'AdoptableAnimal(id: $id, name: $name, type: $type, breed: $breed, age: $age, gender: $gender, size: $size, description: $description, character: $character, specialNeeds: $specialNeeds, imageUrl: $imageUrl, additionalImages: $additionalImages, isUrgent: $isUrgent, isReserved: $isReserved, availableSince: $availableSince, contactInfo: $contactInfo)';
}


}

/// @nodoc
abstract mixin class _$AdoptableAnimalCopyWith<$Res> implements $AdoptableAnimalCopyWith<$Res> {
  factory _$AdoptableAnimalCopyWith(_AdoptableAnimal value, $Res Function(_AdoptableAnimal) _then) = __$AdoptableAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, AnimalType type, String? breed, String? age, String? gender, String? size, String? description, String? character, List<String> specialNeeds, String? imageUrl, List<String> additionalImages, bool isUrgent, bool isReserved, DateTime? availableSince, String? contactInfo
});




}
/// @nodoc
class __$AdoptableAnimalCopyWithImpl<$Res>
    implements _$AdoptableAnimalCopyWith<$Res> {
  __$AdoptableAnimalCopyWithImpl(this._self, this._then);

  final _AdoptableAnimal _self;
  final $Res Function(_AdoptableAnimal) _then;

/// Create a copy of AdoptableAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? breed = freezed,Object? age = freezed,Object? gender = freezed,Object? size = freezed,Object? description = freezed,Object? character = freezed,Object? specialNeeds = null,Object? imageUrl = freezed,Object? additionalImages = null,Object? isUrgent = null,Object? isReserved = null,Object? availableSince = freezed,Object? contactInfo = freezed,}) {
  return _then(_AdoptableAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AnimalType,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,specialNeeds: null == specialNeeds ? _self._specialNeeds : specialNeeds // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,additionalImages: null == additionalImages ? _self._additionalImages : additionalImages // ignore: cast_nullable_to_non_nullable
as List<String>,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,isReserved: null == isReserved ? _self.isReserved : isReserved // ignore: cast_nullable_to_non_nullable
as bool,availableSince: freezed == availableSince ? _self.availableSince : availableSince // ignore: cast_nullable_to_non_nullable
as DateTime?,contactInfo: freezed == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
