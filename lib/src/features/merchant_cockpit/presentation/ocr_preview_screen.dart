import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/openai_service.dart';
import '../../authentication/presentation/auth_controller.dart';
import 'cockpit_controller.dart';

/// Screen to preview and edit OCR results
class OcrPreviewScreen extends ConsumerWidget {
  const OcrPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(cockpitControllerProvider);
    final authState = ref.watch(authControllerProvider);

    // Listen for state changes
    ref.listen<UploadState>(cockpitControllerProvider, (previous, next) {
      if (next is UploadSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menü erfolgreich veröffentlicht!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(cockpitControllerProvider.notifier).reset();
        context.go('/feed');
      } else if (next is UploadError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    // Handle saving state
    if (uploadState is UploadSaving) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speichern...')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menü wird veröffentlicht...'),
            ],
          ),
        ),
      );
    }

    // Redirect if no OCR result
    if (uploadState is! UploadOcrComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/upload');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final result = uploadState.result;

    // Get merchant info from auth state
    String merchantId = 'demo_merchant';
    String merchantName = 'Demo Restaurant';
    if (authState is AuthAuthenticated) {
      merchantId = authState.user.uid;
      merchantName = authState.user.displayName ?? authState.user.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erkannte Gerichte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(cockpitControllerProvider.notifier).backToImageSelected();
            context.go('/upload');
          },
        ),
      ),
      body: Column(
        children: [
          // Image preview
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(uploadState.image),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Text(
                '${result.items.length} Gerichte erkannt',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menu items list
          Expanded(
            child: result.isEmpty
                ? _buildEmptyState(context)
                : _buildMenuItemsList(context, result.items),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: result.isEmpty
                ? null
                : () {
                    ref.read(cockpitControllerProvider.notifier).saveMenu(
                          merchantId: merchantId,
                          merchantName: merchantName,
                        );
                  },
            icon: const Icon(Icons.publish),
            label: const Text('Veröffentlichen'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Gerichte erkannt',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Versuche ein anderes Foto',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList(BuildContext context, List<ParsedMenuItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: item.description != null
                ? Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: item.price != null
                ? Text(
                    '${item.price!.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
            leading: item.category != null
                ? Chip(
                    label: Text(
                      item.category!,
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  )
                : null,
          ),
        );
      },
    );
  }
}
