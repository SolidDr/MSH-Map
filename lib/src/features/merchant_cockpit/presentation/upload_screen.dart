import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cockpit_controller.dart';

/// Upload screen for merchants to upload menu images
class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                ref.read(cockpitControllerProvider.notifier).pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                ref.read(cockpitControllerProvider.notifier).pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(cockpitControllerProvider);

    ref.listen<UploadState>(cockpitControllerProvider, (previous, next) {
      if (next is UploadError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next is UploadOcrComplete) {
        context.go('/ocr-preview');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü hochladen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(cockpitControllerProvider.notifier).reset();
            context.go('/feed');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview or upload area
            _buildImageArea(context, ref, uploadState),
            const SizedBox(height: 24),

            // Action buttons based on state
            _buildActionButtons(context, ref, uploadState),

            const SizedBox(height: 24),

            // Info card
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea(
      BuildContext context, WidgetRef ref, UploadState state) {
    if (state is UploadImageSelected ||
        state is UploadProcessing ||
        state is UploadError && state.image != null) {
      final image = state is UploadImageSelected
          ? state.image
          : state is UploadProcessing
              ? state.image
              : (state as UploadError).image!;

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (state is UploadProcessing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Analysiere Speisekarte...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: state is UploadProcessing
                  ? null
                  : () => _showImageSourceDialog(context, ref),
              icon: const Icon(Icons.edit),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // Initial state - show upload prompt
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showImageSourceDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tippe um ein Foto aufzunehmen\noder aus der Galerie zu wählen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, UploadState state) {
    if (state is UploadImageSelected) {
      return ElevatedButton.icon(
        onPressed: () {
          ref.read(cockpitControllerProvider.notifier).processImage();
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Mit KI analysieren'),
      );
    }

    if (state is UploadProcessing) {
      return const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state is UploadError && state.image != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ref.read(cockpitControllerProvider.notifier).processImage();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "So funktioniert's",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('1. Fotografiere dein Tagesmenü'),
            const SizedBox(height: 4),
            const Text('2. Die KI erkennt die Gerichte automatisch'),
            const SizedBox(height: 4),
            const Text('3. Überprüfe und veröffentliche'),
          ],
        ),
      ),
    );
  }
}
