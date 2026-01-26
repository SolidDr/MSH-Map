import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'upload_controller.dart';

/// Upload screen for merchants to upload menu images
class MenuUploadScreen extends ConsumerWidget {
  const MenuUploadScreen({super.key});

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
                ref.read(uploadControllerProvider.notifier).pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                ref.read(uploadControllerProvider.notifier).pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);

    ref.listen<UploadState>(uploadControllerProvider, (previous, next) {
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
        title: const Text('Lunch Radar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(uploadControllerProvider.notifier).reset();
            context.go('/');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lunch Radar Header
            _buildLunchRadarHeader(context),
            const SizedBox(height: 32),

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

  Widget _buildLunchRadarHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icon und Titel
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lunch Radar',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Dein Mittagstisch, digital',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Was ist Lunch Radar?
            _buildInfoSection(
              context,
              icon: Icons.lightbulb_outline,
              iconColor: Colors.orange,
              title: 'Was ist Lunch Radar?',
              description:
                  'Lunch Radar macht Mittagsangebote sichtbar. Restaurants können ihre Tagesgerichte einfach per Foto hochladen – unsere KI erkennt automatisch die Gerichte und Preise.',
            ),
            const SizedBox(height: 16),

            // Für wen ist es?
            _buildInfoSection(
              context,
              icon: Icons.people_outline,
              iconColor: Colors.blue,
              title: 'Für wen ist es?',
              description:
                  'Für Gastronomen, die ihre Mittagskarte schnell teilen möchten, und für Gäste, die auf einen Blick sehen wollen, was es heute in der Nähe gibt.',
            ),
            const SizedBox(height: 16),

            // Ziele
            _buildInfoSection(
              context,
              icon: Icons.flag_outlined,
              iconColor: Colors.green,
              title: 'Unsere Ziele',
              description:
                  'Lokale Gastronomie stärken, Mittagspause vereinfachen und spontane Entscheidungen erleichtern – alles auf einer Karte.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea(
    BuildContext context,
    WidgetRef ref,
    UploadState state,
  ) {
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
    BuildContext context,
    WidgetRef ref,
    UploadState state,
  ) {
    if (state is UploadImageSelected) {
      return ElevatedButton.icon(
        onPressed: () {
          ref.read(uploadControllerProvider.notifier).processImage();
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
              ref.read(uploadControllerProvider.notifier).processImage();
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
