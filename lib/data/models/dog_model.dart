class DogBreed {
  final String breed;
  final String subBreed;
  final List<String> images;

  DogBreed({required this.breed, this.subBreed = '', this.images = const []});

  String get displayName => subBreed.isEmpty ? breed : '$breed ($subBreed)';

  DogBreed copyWith({String? breed, String? subBreed, List<String>? images}) {
    return DogBreed(
      breed: breed ?? this.breed,
      subBreed: subBreed ?? this.subBreed,
      images: images ?? this.images,
    );
  }
}
