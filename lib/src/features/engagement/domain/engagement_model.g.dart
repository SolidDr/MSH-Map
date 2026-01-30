// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EngagementPlace _$EngagementPlaceFromJson(Map<String, dynamic> json) =>
    _EngagementPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$EngagementTypeEnumMap, json['type']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      street: json['street'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      openingHours: json['openingHours'] as String?,
      currentNeeds:
          (json['currentNeeds'] as List<dynamic>?)
              ?.map((e) => EngagementNeed.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      adoptableAnimals:
          (json['adoptableAnimals'] as List<dynamic>?)
              ?.map((e) => AdoptableAnimal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      dataSource: json['dataSource'] as String?,
    );

Map<String, dynamic> _$EngagementPlaceToJson(_EngagementPlace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$EngagementTypeEnumMap[instance.type]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'street': instance.street,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'description': instance.description,
      'openingHours': instance.openingHours,
      'currentNeeds': instance.currentNeeds,
      'adoptableAnimals': instance.adoptableAnimals,
      'imageUrl': instance.imageUrl,
      'isVerified': instance.isVerified,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'dataSource': instance.dataSource,
    };

const _$EngagementTypeEnumMap = {
  EngagementType.animalShelter: 'animalShelter',
  EngagementType.volunteer: 'volunteer',
  EngagementType.helpNeeded: 'helpNeeded',
  EngagementType.socialService: 'socialService',
  EngagementType.donation: 'donation',
  EngagementType.bloodDonation: 'bloodDonation',
  EngagementType.environment: 'environment',
};

_EngagementNeed _$EngagementNeedFromJson(Map<String, dynamic> json) =>
    _EngagementNeed(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      urgency: $enumDecode(_$UrgencyLevelEnumMap, json['urgency']),
      category: $enumDecode(_$NeedCategoryEnumMap, json['category']),
      neededBy: json['neededBy'] == null
          ? null
          : DateTime.parse(json['neededBy'] as String),
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      contactPerson: json['contactPerson'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toInt(),
      currentAmount: (json['currentAmount'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$EngagementNeedToJson(_EngagementNeed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'urgency': _$UrgencyLevelEnumMap[instance.urgency]!,
      'category': _$NeedCategoryEnumMap[instance.category]!,
      'neededBy': instance.neededBy?.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'contactPerson': instance.contactPerson,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'unit': instance.unit,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isActive': instance.isActive,
    };

const _$UrgencyLevelEnumMap = {
  UrgencyLevel.normal: 'normal',
  UrgencyLevel.elevated: 'elevated',
  UrgencyLevel.urgent: 'urgent',
  UrgencyLevel.critical: 'critical',
};

const _$NeedCategoryEnumMap = {
  NeedCategory.volunteers: 'volunteers',
  NeedCategory.money: 'money',
  NeedCategory.goods: 'goods',
  NeedCategory.food: 'food',
  NeedCategory.time: 'time',
  NeedCategory.transport: 'transport',
  NeedCategory.expertise: 'expertise',
  NeedCategory.fosterHome: 'fosterHome',
  NeedCategory.adoption: 'adoption',
  NeedCategory.other: 'other',
};

_AdoptableAnimal _$AdoptableAnimalFromJson(Map<String, dynamic> json) =>
    _AdoptableAnimal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AnimalTypeEnumMap, json['type']),
      breed: json['breed'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      size: json['size'] as String?,
      description: json['description'] as String?,
      character: json['character'] as String?,
      specialNeeds:
          (json['specialNeeds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      additionalImages:
          (json['additionalImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isUrgent: json['isUrgent'] as bool? ?? false,
      isReserved: json['isReserved'] as bool? ?? false,
      availableSince: json['availableSince'] == null
          ? null
          : DateTime.parse(json['availableSince'] as String),
      contactInfo: json['contactInfo'] as String?,
    );

Map<String, dynamic> _$AdoptableAnimalToJson(_AdoptableAnimal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$AnimalTypeEnumMap[instance.type]!,
      'breed': instance.breed,
      'age': instance.age,
      'gender': instance.gender,
      'size': instance.size,
      'description': instance.description,
      'character': instance.character,
      'specialNeeds': instance.specialNeeds,
      'imageUrl': instance.imageUrl,
      'additionalImages': instance.additionalImages,
      'isUrgent': instance.isUrgent,
      'isReserved': instance.isReserved,
      'availableSince': instance.availableSince?.toIso8601String(),
      'contactInfo': instance.contactInfo,
    };

const _$AnimalTypeEnumMap = {
  AnimalType.dog: 'dog',
  AnimalType.cat: 'cat',
  AnimalType.rabbit: 'rabbit',
  AnimalType.bird: 'bird',
  AnimalType.smallAnimal: 'smallAnimal',
  AnimalType.reptile: 'reptile',
  AnimalType.horse: 'horse',
  AnimalType.farm: 'farm',
  AnimalType.other: 'other',
};
