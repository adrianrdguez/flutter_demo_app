import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/dog_model.dart';

class DogProvider extends ChangeNotifier {
  List<DogBreed> _breeds = [];
  bool _isLoading = false;
  String _error = '';

  List<DogBreed> get breeds => _breeds;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchBreeds() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/list/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final breedsMap = data['message'] as Map<String, dynamic>;

        _breeds = [];
        for (var entry in breedsMap.entries) {
          if ((entry.value as List).isEmpty) {
            _breeds.add(DogBreed(breed: entry.key));
          } else {
            for (var subBreed in entry.value) {
              _breeds.add(
                DogBreed(breed: entry.key, subBreed: subBreed.toString()),
              );
            }
          }
        }
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
        Uri.parse('https://dog.ceo/api/breed/$breed/images'),
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
}
