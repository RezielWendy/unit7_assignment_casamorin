import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List> futureCharacters;
  late ExpandedTileController _expandedTileController;

  @override
  void initState() {
    super.initState();
    _expandedTileController = ExpandedTileController();
    futureCharacters = fetchDisneyCharacters();
  }

  Future<List> fetchDisneyCharacters() async {
    final url = Uri.parse('https://api.disneyapi.dev/character');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return data['data'] as List;
        } else {
          throw Exception('No characters found in the response.');
        }
      } else {
        throw Exception(
            'Failed to load characters. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching characters: $e');
    }
  }

  @override
  void dispose() {
    _expandedTileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disney Characters"),
        backgroundColor: const Color.fromARGB(255, 222, 112, 112),
      ),
      body: FutureBuilder<List>(
        future: futureCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final characters = snapshot.data!;
            return ExpandedTileList.builder(
              itemCount: characters.length,
              itemBuilder: (context, index, controller) {
                final character = characters[index];
                final name = character['name'] ?? 'Unknown';
                final imageUrl = character['imageUrl'] ?? '';
                final films = (character['films'] as List?)?.join(', ') ??
                    'No films available';
                final shortFilms =
                    (character['shortFilms'] as List?)?.join(', ') ??
                        'No short films available';
                final tvShows = (character['tvShows'] as List?)?.join(', ') ??
                    'No TV shows available';
                final videoGames =
                    (character['videoGames'] as List?)?.join(', ') ??
                        'No video games available';
                final parkAttractions =
                    (character['parkAttractions'] as List?)?.join(', ') ??
                        'No park attractions available';
                final allies = (character['allies'] as List?)?.join(', ') ??
                    'No allies available';
                final enemies = (character['enemies'] as List?)?.join(', ') ??
                    'No enemies available';

                final description = '''
Films: $films
Short Films: $shortFilms
TV Shows: $tvShows
Video Games: $videoGames
Park Attractions: $parkAttractions
Allies: $allies
Enemies: $enemies
''';

                return ExpandedTile(
                  controller: _expandedTileController,
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  leading: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 177,
                          height: 127,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.image_not_supported),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Source: ${character['sourceUrl'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No characters found.'));
          }
        },
      ),
    );
  }
}
