/// Notdienst-Informationen für Apotheken
class EmergencyService {
  const EmergencyService({
    required this.hasEmergencyService,
    this.isCurrentlyOnDuty = false,
    this.nextDutyDate,
    this.dutyHours,
  });

  factory EmergencyService.fromJson(Map<String, dynamic> json) {
    return EmergencyService(
      hasEmergencyService: json['hasEmergencyService'] as bool? ?? false,
      isCurrentlyOnDuty: json['isCurrentlyOnDuty'] as bool? ?? false,
      nextDutyDate: json['nextDutyDate'] != null
          ? DateTime.tryParse(json['nextDutyDate'] as String)
          : null,
      dutyHours: json['dutyHours'] as String?,
    );
  }

  /// Hat die Einrichtung grundsätzlich Notdienst
  final bool hasEmergencyService;

  /// Ist JETZT im Notdienst aktiv
  final bool isCurrentlyOnDuty;

  /// Nächster Notdienst-Tag
  final DateTime? nextDutyDate;

  /// Übliche Notdienst-Zeiten (z.B. "20:00 - 08:00")
  final String? dutyHours;

  Map<String, dynamic> toJson() {
    return {
      'hasEmergencyService': hasEmergencyService,
      'isCurrentlyOnDuty': isCurrentlyOnDuty,
      if (nextDutyDate != null)
        'nextDutyDate': nextDutyDate!.toIso8601String().split('T')[0],
      if (dutyHours != null) 'dutyHours': dutyHours,
    };
  }
}

/// Fitness-Angebot für Senioren
class FitnessOffer {
  const FitnessOffer({
    required this.name,
    this.description,
    this.day,
    this.time,
    this.location,
    this.cost,
    this.ageGroup,
    this.requiresRegistration = false,
  });

  factory FitnessOffer.fromJson(Map<String, dynamic> json) {
    return FitnessOffer(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      day: json['day'] as String?,
      time: json['time'] as String?,
      location: json['location'] as String?,
      cost: json['cost'] as String?,
      ageGroup: json['ageGroup'] as String?,
      requiresRegistration: json['requiresRegistration'] as bool? ?? false,
    );
  }

  final String name;
  final String? description;
  final String? day;
  final String? time;
  final String? location;
  final String? cost;
  final String? ageGroup;
  final bool requiresRegistration;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (day != null) 'day': day,
      if (time != null) 'time': time,
      if (location != null) 'location': location,
      if (cost != null) 'cost': cost,
      if (ageGroup != null) 'ageGroup': ageGroup,
      'requiresRegistration': requiresRegistration,
    };
  }
}
