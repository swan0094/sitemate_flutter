import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      home: const MyHomePage(title: 'Sitemate - Alex Swan App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _searchQuery;
  late String url;

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // This key is for demonstration purposes only and should not be used in production.
      // It would normally be stored in a secure location.
      url =
          'https://newsapi.org/v2/everything?q=$_searchQuery&from=$formattedDate&sortBy=popularity&apiKey=183daca270264bad86fc5b72972fb82a';
    });
  }

  void _searchNews() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
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
              onChanged: (value) => _setSearchQuery,
              onSubmitted: (value) => _searchNews,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
    );
  }
}
