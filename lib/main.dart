import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitemate - Alex Swan App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2e81da)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _searchQuery;
  late String url;
  Set<SearchResults> searchResults = {};

  bool isLoading = false;
  bool showResults = false;

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
      // This key is for demonstration purposes only and should not be used in production.
      // It would normally be stored in a secure location.
      url =
          'https://newsapi.org/v2/everything?q=$_searchQuery&sortBy=popularity&apiKey=183daca270264bad86fc5b72972fb82a';
    });
  }

  void _searchNews() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      searchResults.clear();
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      if (articles.isEmpty) {
        setState(() {
          isLoading = false;
          showResults = true;
        });
        return;
      }

      for (final article in articles) {
        searchResults.add(SearchResults.fromJson(article));
      }

      setState(() {
        isLoading = false;
        showResults = true;
      });
    } else {
      print('Failed to load news');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: showResults
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  showResults = false;
                }),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Stack(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!showResults && !isLoading)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to my demo app!',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Type a keyword and hit enter or click the search icon to search for related news.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SearchBar(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      minHeight: 60,
                    ),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search),
                    ),
                    onChanged: (value) => _setSearchQuery(value),
                    onSubmitted: (value) => _searchNews(),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  ),
                ],
              ),
            if (showResults)
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : searchResults.isEmpty
                        ? const Text('No results')
                        : ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final result = searchResults.elementAt(index);
                              return ListTile(
                                title: Text(result.title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(result.description),
                              );
                            },
                          ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchResults {
  final Object source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;

  SearchResults({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      source: json['source'],
      author: json['author'] ?? '',
      title: json['title'],
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }
}
