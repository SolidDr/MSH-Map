import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';

/// Kategorie der Gesundheitseinrichtung
enum HealthCategory {
  doctor('Arzt', Icons.medical_services, MshColors.categoryDoctor),
  pharmacy('Apotheke', Icons.local_pharmacy, MshColors.categoryPharmacy),
  hospital('Krankenhaus', Icons.local_hospital, MshColors.categoryHospital),
  physiotherapy('Physiotherapie', Icons.spa, MshColors.categoryPhysiotherapy),
  fitness('Fitness', Icons.fitness_center, MshColors.categoryFitnessSenior),
  careService('Pflegedienst', Icons.elderly, MshColors.categoryCareService),
  medicalSupply('Sanitätshaus', Icons.medical_information, MshColors.categoryHealth);

  const HealthCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// Fachrichtung des Arztes
enum DoctorSpecialization {
  allgemein('Allgemeinmedizin'),
  innere('Innere Medizin'),
  kardio('Kardiologie'),
  ortho('Orthopädie'),
  neuro('Neurologie'),
  augen('Augenheilkunde'),
  hno('HNO'),
  haut('Dermatologie'),
  uro('Urologie'),
  gyn('Gynäkologie'),
  zahn('Zahnarzt'),
  kinder('Kinderheilkunde'),
  psycho('Psychiatrie/Psychotherapie');

  const DoctorSpecialization(this.label);

  final String label;

  static DoctorSpecialization? fromString(String? value) {
    if (value == null) return null;
    for (final spec in DoctorSpecialization.values) {
      if (spec.name == value || spec.label.toLowerCase() == value.toLowerCase()) {
        return spec;
      }
    }
    return null;
  }
}
