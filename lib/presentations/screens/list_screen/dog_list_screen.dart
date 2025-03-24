import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dog_provider.dart';
import '../detail_screen/dog_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        actions: [
          Consumer<DogProvider>(
            builder: (context, dogProvider, child) {
              return Text('Page ${dogProvider.currentPage}');
            },
          ),
        ],
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, child) {
          if (dogProvider.error.isNotEmpty) {
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search breeds...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    dogProvider.setSearchTerm(value);
                    dogProvider.fetchBreeds(refresh: true);
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => dogProvider.fetchBreeds(refresh: true),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount:
                        dogProvider.breeds.length +
                        (dogProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= dogProvider.breeds.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final breed = dogProvider.breeds[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child:
                                    breed.images.isNotEmpty
                                        ? CachedNetworkImage(
                                          imageUrl: breed.images.first,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget: (context, url, error) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.error,
                                                  size: 50,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Error loading image',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.error,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                        : const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'No image available',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  breed.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
