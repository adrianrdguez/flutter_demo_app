import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/dog_model.dart';

class DogProvider extends ChangeNotifier {
  List<DogBreed> _breeds = [];
  bool _isLoading = false;
  bool _hasMore = true; // Track if more items are available
  int _currentPage = 1; // Track current page
  static const int _itemsPerPage = 10; // Items per page
  String _error = '';
  String _searchTerm = '';

  static const String baseUrl = 'http://localhost:3000';

  List<DogBreed> get breeds => _breeds;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get error => _error;
  int get currentPage => _currentPage;
  String get searchTerm => _searchTerm;

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> fetchBreeds({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _breeds = [];
      _hasMore = true;
    }

    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (_currentPage == 1) _error = '';
    notifyListeners();

    try {
      final searchParam = _searchTerm.isNotEmpty ? '&search=$_searchTerm' : '';
      final response = await http.get(
        Uri.parse(
          '$baseUrl/dogs/breeds?page=$_currentPage&limit=$_itemsPerPage$searchParam',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final breedsMap = data['data']['message'] as Map<String, dynamic>;
        final metadata = data['metadata'];
        final totalPages = metadata['totalPages'] as int;

        final List<DogBreed> newBreeds = [];
        for (var entry in breedsMap.entries) {
          if ((entry.value as List).isEmpty) {
            // Fetch random image for this breed
            final image = await fetchRandomBreedImage(entry.key);
            newBreeds.add(
              DogBreed(breed: entry.key, images: image != null ? [image] : []),
            );
          } else {
            for (var subBreed in entry.value) {
              // Fetch random image for this subbreed
              final image = await fetchRandomBreedImage(
                '${entry.key}/${subBreed}',
              );
              newBreeds.add(
                DogBreed(
                  breed: entry.key,
                  subBreed: subBreed.toString(),
                  images: image != null ? [image] : [],
                ),
              );
            }
          }
        }

        _breeds.addAll(newBreeds);
        _hasMore = _currentPage < totalPages;
        _currentPage++;
      } else {
        _error = 'Failed to load breeds';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> fetchBreedImages(String breed) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dogs/breed/$breed/images'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['message']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> fetchRandomBreedImage(String breed) async {
    try {
      // URL encode the breed name to handle special characters and slashes
      final encodedBreed = Uri.encodeComponent(breed);
      final url = '$baseUrl/dogs/breed/$encodedBreed/images';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = List<String>.from(data['message']);
        if (images.isNotEmpty) {
          // Get a random image from the list
          final random =
              images[DateTime.now().millisecondsSinceEpoch % images.length];
          return random;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
