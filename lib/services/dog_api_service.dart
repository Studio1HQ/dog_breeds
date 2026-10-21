
import 'dart:convert';

import 'package:http/http.dart' as http;

class DogApiService {
  static const String _baseUrl = 'https://dog.ceo/api';

  final http.Client _client;

  DogApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<String>> fetchBreeds() async {
    final uri = Uri.parse('$_baseUrl/breeds/list/all');

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load dog breeds (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['status'] != 'success') {
      throw Exception('The Dog CEO API could not return the breeds.');
    }

    final breeds = decoded['message'] as Map<String, dynamic>;

    final breedNames = breeds.keys.toList()
      ..sort();

    if (breedNames.isEmpty) {
      throw Exception('No dog breeds were returned.');
    }

    return breedNames;
  }

  Future<List<String>> fetchBreedImages(
    String breed, {
    int count = 12,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/breed/${Uri.encodeComponent(breed)}'
      '/images/random/$count',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load $breed images (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['status'] != 'success') {
      throw Exception('The Dog CEO API could not return the images.');
    }

    final images = (decoded['message'] as List<dynamic>)
        .cast<String>();

    if (images.isEmpty) {
      throw Exception('No images were returned for $breed.');
    }

    return images;
  }

  void dispose() {
    _client.close();
  }
}
