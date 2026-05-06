// lib/screens/image_search_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pixabay_image.dart';
import '../services/image_service.dart';
import '../l10n/app_localizations.dart'; // Import localizations

class ImageSearchDialog extends StatefulWidget {
  final String? initialSearchTerm;

  const ImageSearchDialog({Key? key, this.initialSearchTerm}) : super(key: key);

  @override
  State<ImageSearchDialog> createState() => _ImageSearchDialogState();
}

class _ImageSearchDialogState extends State<ImageSearchDialog> {
  final ImageService _imageService = ImageService();
  final TextEditingController _searchController = TextEditingController();
  List<PixabayImage> _images = [];
  bool _isLoading = false;
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchTerm != null &&
        widget.initialSearchTerm!.isNotEmpty) {
      _searchController.text = widget.initialSearchTerm!;
      _searchImages();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchImages() async {
    if (_searchController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _images = [];
    });
    final results = await _imageService.searchImages(_searchController.text);
    if (mounted) {
      setState(() {
        _images = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectImage(PixabayImage image) async {
    final loc = AppLocalizations.of(context)!; // Access localizations

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(loc.dialogConfirmTitle, // Localized
            style: const TextStyle(color: Colors.white)),
        content: Text(loc.dialogConfirmContent, // Localized
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.dialogCancel, // Localized
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.dialogSelect, // Localized
                style: const TextStyle(color: Color(0xFFFFB800))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _downloadingId = image.id.toString();
      });
      final String? filePath = await _imageService.downloadAndSaveImage(
        image.largeImageURL,
        'word_img',
      );
      if (mounted) {
        Navigator.pop(context, filePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localizations

    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.imageSearchHint, // Localized
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFFFB800)),
                  onPressed: _searchImages,
                ),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _searchImages(),
            ),
          ),
          // Image Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFB800)),
                  )
                : _images.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? loc.imageSearchPrompt // Localized
                              : loc.imageSearchNoneFound, // Localized
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final image = _images[index];
                          final bool isDownloading =
                              _downloadingId == image.id.toString();
                          return GestureDetector(
                            onTap: () => _selectImage(image),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    image.previewURL,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                      color: const Color(0xFF2C2C2E),
                                      child: const Icon(Icons.error,
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                                if (isDownloading)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xFFFFB800)),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Close Button
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(loc.dialogClose, // Localized
                style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}