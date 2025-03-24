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

  // Update the base URL to point to your NestJS backend
  static const String baseUrl =
      'http://localhost:3000'; // Replace with your actual backend URL

  List<DogBreed> get breeds => _breeds;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get error => _error;
  int get currentPage => _currentPage;

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
      final response = await http.get(
        Uri.parse(
          '$baseUrl/dogs/breeds?page=$_currentPage&limit=$_itemsPerPage',
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
            newBreeds.add(DogBreed(breed: entry.key));
          } else {
            for (var subBreed in entry.value) {
              newBreeds.add(
                DogBreed(breed: entry.key, subBreed: subBreed.toString()),
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
        Uri.parse(
          '$baseUrl/dogs/breed/$breed/images',
        ), // Update to match your backend route
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

  // Add new method for random image
  Future<String?> fetchRandomBreedImage(String breed) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/dogs/breed/$breed/images/random',
        ), // Update to match your backend route
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
