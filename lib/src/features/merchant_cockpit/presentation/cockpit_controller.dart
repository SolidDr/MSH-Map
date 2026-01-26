import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/image_picker_service.dart';
import '../../../core/services/openai_service.dart';
import '../../feed/data/dish_repository.dart';
import '../../feed/domain/dish_model.dart';

/// State for the upload process
sealed class UploadState {
  const UploadState();
}

class UploadInitial extends UploadState {
  const UploadInitial();
}

class UploadImageSelected extends UploadState {
  final File image;
  const UploadImageSelected(this.image);
}

class UploadProcessing extends UploadState {
  final File image;
  const UploadProcessing(this.image);
}

class UploadOcrComplete extends UploadState {
  final File image;
  final OcrResult result;
  const UploadOcrComplete(this.image, this.result);
}

class UploadError extends UploadState {
  final String message;
  final File? image;
  const UploadError(this.message, {this.image});
}

class UploadSaving extends UploadState {
  final File image;
  final OcrResult result;
  const UploadSaving(this.image, this.result);
}

class UploadSuccess extends UploadState {
  final MenuModel menu;
  const UploadSuccess(this.menu);
}

/// Provider for the cockpit controller
final cockpitControllerProvider =
    StateNotifierProvider<CockpitController, UploadState>((ref) {
  return CockpitController(
    ref.watch(imagePickerServiceProvider),
    ref.watch(openAiServiceProvider),
    ref.watch(menuRepositoryProvider),
  );
});

/// Controller for the merchant cockpit upload flow
class CockpitController extends StateNotifier<UploadState> {
  final ImagePickerService _imagePicker;
  final OpenAiService _openAiService;
  final MenuRepository _menuRepository;

  CockpitController(this._imagePicker, this._openAiService, this._menuRepository)
      : super(const UploadInitial());

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    try {
      final image = await _imagePicker.pickFromCamera();
      if (image != null) {
        state = UploadImageSelected(image);
      }
    } on Exception catch (e) {
      state = UploadError('Kamera-Fehler: $e');
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      final image = await _imagePicker.pickFromGallery();
      if (image != null) {
        state = UploadImageSelected(image);
      }
    } on Exception catch (e) {
      state = UploadError('Galerie-Fehler: $e');
    }
  }

  /// Process the selected image with OCR
  Future<void> processImage() async {
    final currentState = state;
    if (currentState is! UploadImageSelected &&
        currentState is! UploadOcrComplete) {
      return;
    }

    final image = currentState is UploadImageSelected
        ? currentState.image
        : (currentState as UploadOcrComplete).image;

    state = UploadProcessing(image);

    try {
      final result = await _openAiService.extractMenuFromImage(image);

      if (result.hasError) {
        state = UploadError(result.error!, image: image);
      } else {
        state = UploadOcrComplete(image, result);
      }
    } on Exception catch (e) {
      state = UploadError('OCR-Fehler: $e', image: image);
    }
  }

  /// Reset to initial state
  void reset() {
    state = const UploadInitial();
  }

  /// Go back to image selected state (from OCR result)
  void backToImageSelected() {
    final currentState = state;
    if (currentState is UploadOcrComplete) {
      state = UploadImageSelected(currentState.image);
    } else if (currentState is UploadError && currentState.image != null) {
      state = UploadImageSelected(currentState.image!);
    }
  }

  /// Save the menu to Firestore
  Future<void> saveMenu({
    required String merchantId,
    required String merchantName,
  }) async {
    final currentState = state;
    if (currentState is! UploadOcrComplete) {
      return;
    }

    state = UploadSaving(currentState.image, currentState.result);

    try {
      // Convert ParsedMenuItems to DishModels
      final dishes = currentState.result.items
          .asMap()
          .entries
          .map((entry) => DishModel(
                id: 'dish_${entry.key}',
                name: entry.value.name,
                description: entry.value.description,
                price: entry.value.price,
                category: entry.value.category,
              ))
          .toList();

      final menu = await _menuRepository.saveMenu(
        merchantId: merchantId,
        merchantName: merchantName,
        dishes: dishes,
        date: DateTime.now(),
      );

      state = UploadSuccess(menu);
    } on Exception catch (e) {
      state = UploadError(
        'Speichern fehlgeschlagen: $e',
        image: currentState.image,
      );
    }
  }
}
