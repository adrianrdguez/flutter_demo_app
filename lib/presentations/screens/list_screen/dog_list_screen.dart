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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => context.read<DogProvider>().fetchBreeds());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DogProvider>().fetchBreeds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breeds'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, _) {
          if (dogProvider.error.isNotEmpty && dogProvider.breeds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dogProvider.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dogProvider.fetchBreeds(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dogProvider.fetchBreeds(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  dogProvider.breeds.length + (dogProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= dogProvider.breeds.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text('Loading page ${dogProvider.currentPage}...'),
                      ],
                    ),
                  );
                }

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
