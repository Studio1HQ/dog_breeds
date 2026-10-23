import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';

class DogBreedScreen extends StatefulWidget {
  const DogBreedScreen({super.key});

  @override
  State<DogBreedScreen> createState() => _DogBreedScreenState();
}

class _DogBreedScreenState extends State<DogBreedScreen> {
  final DogApiService _dogApiService = DogApiService();

  List<String> _breeds = [];
  List<String> _images = [];

  String? _selectedBreed;
  String? _errorMessage;

  bool _isLoadingBreeds = true;
  bool _isLoadingImages = false;

  int _imageRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _isLoadingBreeds = true;
      _errorMessage = null;
    });

    try {
      final breeds = await _dogApiService.fetchBreeds();

      if (!mounted) return;

      setState(() {
        _breeds = breeds;
        _isLoadingBreeds = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingBreeds = false;
        _errorMessage = 'Could not load dog breeds. Please try again.';
      });

      debugPrint('Breed request failed: $error');
    }
  }
  

  Future<void> _selectBreed(String? breed) async {
    if (breed == null) return;

    final requestId = ++_imageRequestId;

    setState(() {
      _selectedBreed = breed;
      _isLoadingImages = true;
      _images = [];
      _errorMessage = null;
    });

    try {
      final images = await _dogApiService.fetchBreedImages(breed, count: 12);

      if (!mounted || requestId != _imageRequestId) return;

      setState(() {
        _images = images;
        _isLoadingImages = false;
      });
    } catch (error) {
      if (!mounted || requestId != _imageRequestId) return;

      setState(() {
        _isLoadingImages = false;
        _errorMessage = 'Could not load $breed images. Please try again.';
      });

      debugPrint('Image request failed for $breed: $error');
    }
  }

  @override
  void dispose() {
    _dogApiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dog Breed Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Leave screen - lifecycle test',
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text('You left the Dog Breed Explorer.'),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_selectedBreed != null) {
              await _selectBreed(_selectedBreed);
            } else {
              await _loadBreeds();
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Find your favourite dogs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a breed to explore a gallery of adorable dogs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Select a breed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              if (_isLoadingBreeds)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_breeds.isEmpty)
                OutlinedButton.icon(
                  onPressed: _loadBreeds,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry loading breeds'),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedBreed,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Choose a dog breed',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    prefixIcon: const Icon(Icons.pets),
                  ),
                  items: _breeds.map((breed) {
                    return DropdownMenuItem<String>(
                      value: breed,
                      child: Text(breed[0].toUpperCase() + breed.substring(1)),
                    );
                  }).toList(),
                  onChanged: _selectBreed,
                ),

              const SizedBox(height: 24),

              if (_errorMessage != null) _buildErrorCard(theme),

              if (_isLoadingImages)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_images.isNotEmpty) ...[
                Text(
                  '${_selectedBreed![0].toUpperCase()}'
                  '${_selectedBreed!.substring(1)} Dogs',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_images.length} images',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _images.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const ColoredBox(
                                color: Color(0xFFF0F0F0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Color(0xFFF0F0F0),
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _selectBreed(_selectedBreed),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load new images'),
                ),
              ] else if (!_isLoadingBreeds &&
                  !_isLoadingImages &&
                  _errorMessage == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Select a breed to see its pictures.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _selectedBreed == null
                  ? _loadBreeds
                  : () => _selectBreed(_selectedBreed),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}
