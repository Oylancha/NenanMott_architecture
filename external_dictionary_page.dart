// lib/screens/external_dictionary_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/external_word_model.dart';
import '../providers/external_dictionary_provider.dart';
import '../widgets/add_word_dialog.dart'; // Import the new public dialog
import '../providers/alphabet_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ExternalDictionaryPage extends StatefulWidget {
  const ExternalDictionaryPage({Key? key}) : super(key: key);

  @override
  State<ExternalDictionaryPage> createState() => _ExternalDictionaryPageState();
}

class _ExternalDictionaryPageState extends State<ExternalDictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const String _searchKey = 'external_dict_search_query';

  @override
  void initState() {
    super.initState();
    _loadSearchQuery();
  }

  Future<void> _loadSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuery = prefs.getString(_searchKey) ?? '';
    setState(() {
      _searchQuery = savedQuery;
      _searchController.text = savedQuery;
    });
  }

  void _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_searchKey, query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show a simple confirmation before opening the full add dialog
  void _showAddConfirmationDialog(BuildContext context, ExternalWord word) {
    final loc = AppLocalizations.of(context)!;
    // <-- 2. GET ALPHABET PROVIDER (can be read, doesn't need to watch)
    final alphabetProvider = context.read<AlphabetProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(loc.externalDictAddButton, // "Add to Library"
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text(
          // <-- 3. USE GETTERM()
          '${word.getTerm(alphabetProvider.isCyrillic)}\n${word.russian}',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(loc.dialogCancel, style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close this confirmation dialog
              // Open the full "Add Word" dialog, pre-filling data
              showAddWordDialog(
                context,
                initialChechen: word.chechen,
                initialChechenLatin: word.term_latin, // <-- 4. PASS LATIN
                initialRussian: word.russian,
                initialEnglish: word.english,
                initialFrench: word.french,
                initialGerman: word.german,
                initialTurkish: word.turkish, // Pass Turkish
                initialArabic: word.arabic,   // Pass Arabic
                initialCategory: 'External', // You can set a default category
              );
            },
            child: Text(loc.externalDictAddButton,
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.externalDictTitle), // "External Dictionary"
      ),
      // <-- 5. WRAP WITH ALPHABETPROVIDER CONSUMER
      body: Consumer2<ExternalDictionaryProvider, AlphabetProvider>(
        builder: (context, provider, alphabetProvider, _) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }

          final filteredWords = provider.getFilteredWords(_searchQuery);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: loc.externalDictSearchHint, // "Search external..."
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      border: InputBorder.none,
                      icon: Icon(Icons.search,
                          color: Theme.of(context).hintColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Theme.of(context).hintColor),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                                _saveSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _saveSearchQuery(value); // <-- 6. SAVE QUERY ON CHANGE
                    },
                  ),
                ),
              ),
              // Word List
              Expanded(
                child: filteredWords.isEmpty
                    ? Center(
                        child: Text(
                          loc.vocabularySearchNoneFound, // "Nothing found"
                          style: TextStyle(
                            color: Theme.of(context).hintColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                // <-- 6. USE GETTERM()
                                word.getTerm(alphabetProvider.isCyrillic),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              subtitle: Text(
                                word.russian,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              trailing: Icon(
                                Icons.add_circle_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                _showAddConfirmationDialog(context, word);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}