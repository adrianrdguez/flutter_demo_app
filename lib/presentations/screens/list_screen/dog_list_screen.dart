import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dog_provider.dart';
import '../detail_screen/dog_detail_screen.dart';

class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch breeds when the screen initializes
    Future.microtask(() => context.read<DogProvider>().fetchBreeds());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breeds'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, child) {
          if (dogProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dogProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dogProvider.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dogProvider.fetchBreeds(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dogProvider.fetchBreeds(),
            child: ListView.builder(
              itemCount: dogProvider.breeds.length,
              itemBuilder: (context, index) {
                final breed = dogProvider.breeds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      breed.displayName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      // Fetch images before navigating to detail screen
                      final images = await dogProvider.fetchBreedImages(
                        breed.breed,
                      );
                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DogDetailScreen(
                                breed: breed.copyWith(images: images),
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
