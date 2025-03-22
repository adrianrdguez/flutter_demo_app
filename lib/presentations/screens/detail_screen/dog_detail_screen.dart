import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/dog_model.dart';

class DogDetailScreen extends StatelessWidget {
  final DogBreed breed;

  const DogDetailScreen({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.displayName.toUpperCase()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          breed.images.isEmpty
              ? const Center(child: Text('No images available for this breed'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: breed.images.first,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.error, size: 50),
                      ),
                    ),

                    // Breed Information
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Breed Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Main Breed: ${breed.breed.toUpperCase()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (breed.subBreed.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Sub Breed: ${breed.subBreed.toUpperCase()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Image Gallery
                    if (breed.images.length > 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'More Images',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              breed.images.length - 1, // Skip the first image
                          itemBuilder: (context, index) {
                            final imageUrl = breed.images[index + 1];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        _showFullScreenImage(context, imageUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget:
                                        (context, url, error) =>
                                            const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
