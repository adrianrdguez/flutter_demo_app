# Flutter Dog Breeds App

A Flutter application that displays a collection of dog breeds using the dog.ceo API. The app features a modern UI with a grid layout, search functionality, and infinite scrolling with pagination.

## Features

- Grid view of dog breeds with images
- Search functionality to filter breeds
- Infinite scrolling with pagination
- Pull-to-refresh functionality
- Detailed view for each breed
- Error handling and loading states
- Responsive design

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- A running instance of the NestJS backend (see [Backend Setup](#backend-setup))

### Repository

[![Backend](https://img.shields.io/badge/Backend-barkibu__backend-green)](https://github.com/adrianrdguez/barkibu_backend)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/adrianrdguez/flutter_demo_app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd flutter_demo_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Update the backend URL in `lib/presentations/providers/dog_provider.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:3000';
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Backend Setup

The app requires a NestJS backend that wraps the dog.ceo API. The backend should provide the following endpoints:

- `GET /dogs/breeds?page={page}&limit={limit}&search={searchTerm}` - Get paginated list of breeds
- `GET /dogs/breed/{breed}/images` - Get images for a specific breed
- `GET /dogs/breed/{breed}/images/random` - Get a random image for a breed

## License

This project is licensed under the MIT License - see the LICENSE file for details.