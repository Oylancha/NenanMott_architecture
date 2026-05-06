import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word_model.dart';
import '../widgets/edit_word_dialog.dart';
import '../providers/translation_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_word_dialog.dart';
import '../providers/alphabet_provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

// Vocabulary Page
class VocabularyPage extends StatefulWidget {
  const VocabularyPage({Key? key}) : super(key: key);

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const String _searchKey = 'vocabulary_search_query'; 

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

  void _showAddWordDialog(BuildContext context, String? initialCategory) {
    showAddWordDialog(context, initialCategory: initialCategory);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final alphabetProvider = context.watch<AlphabetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.vocabularyTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWordDialog(context, null); // No initial category
        },
        child: const Icon(Icons.add),
        tooltip: loc.vocabularyAddWordTooltip,
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }

          final allCategories = provider.allCategories;
          final filteredCategories = _searchQuery.isEmpty
              ? allCategories
              : allCategories.where((category) {
                  if (category
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) {
                    return true;
                  }
                  return provider.allWords.any((word) =>
                      word.category == category &&
                      (
                          word
                                  .getTerm(true)
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              word
                                  .getTerm(false)
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              word.russian
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              (word.english ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              (word.french ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              (word.german ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase())));
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        loc.vocabularyStatTotal,
                        provider.vocabularyCount.toString(),
                        Icons.menu_book,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        loc.vocabularyStatLearned,
                        provider.learnedCount.toString(),
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
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
                      hintText: loc.vocabularySearchHint,
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
                      _saveSearchQuery(value); 
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.vocabularySearchNoneFound,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];

                          final totalWordsInCategory = provider.allWords
                              .where((w) => w.category == category)
                              .length;
                          final learnedWordsInCategory = provider.allWords
                              .where((w) =>
                                  w.category == category && w.isLearned)
                              .length;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryWordsPage(
                                    category: category,
                                    initialSearchQuery: _searchQuery,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.folder,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          loc.vocabularyCategoryStats(
                                              learnedWordsInCategory,
                                              totalWordsInCategory),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ],
                              ),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryWordsPage extends StatefulWidget {
  final String category;
  final String? initialSearchQuery;

  const CategoryWordsPage({
    Key? key,
    required this.category,
    this.initialSearchQuery,
  }) : super(key: key);

  @override
  State<CategoryWordsPage> createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? '';
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddWordDialog(BuildContext context, String? initialCategory) {
    showAddWordDialog(context, initialCategory: initialCategory);
  }

  Widget _buildWordImage(String? imageUrl, {double size = 80.0}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.image_not_supported,
            color: Theme.of(context).hintColor.withOpacity(0.5),
            size: size / 2),
      );
    }

    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else if (imageUrl.startsWith('/')) {
      imageWidget = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else {
      imageWidget =
          Icon(Icons.help, color: Theme.of(context).hintColor, size: size / 2);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = context.watch<TranslationProvider>();
    final loc = AppLocalizations.of(context)!;
    final alphabetProvider = context.watch<AlphabetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWordDialog(context, widget.category);
        },
        child: const Icon(Icons.add),
        tooltip: loc.vocabularyAddWordTooltip,
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          var wordsInCategory = provider.allWords
              .where((w) => w.category == widget.category)
              .toList();

          if (_searchQuery.isNotEmpty) {
            wordsInCategory = wordsInCategory
                .where((word) =>
                    word
                        .getTerm(true)
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    word
                        .getTerm(false)
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    word.russian
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    (word.english ?? '')
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    (word.french ?? '')
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    (word.german ?? '')
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    (word.exampleSentence
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ??
                        false))
                .toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
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
                      hintText: loc.vocabularySearchWordsHint,
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
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: wordsInCategory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.vocabularyWordsNoneFound,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        itemCount: wordsInCategory.length,
                        itemBuilder: (context, index) {
                          final word = wordsInCategory[index];

                          final correctTranslation =
                              provider.getCorrectTranslation(
                                  word, translationProvider.currentTarget);

                          return GestureDetector(
                            onTap: () {
                              _showWordDetailsDialog(
                                  context, word, provider, translationProvider);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildWordImage(word.imageUrl, size: 50),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                word.getTerm(
                                                    alphabetProvider.isCyrillic),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                                ),
                                              ),
                                            ),
                                            if (word.isCustom)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  loc.vocabularyCustomTag,
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          correctTranslation,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        if (word.exampleSentence != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            word.exampleSentence!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (word.audioUrl != null)
                                    IconButton(
                                      padding: const EdgeInsets.only(left: 8),
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.volume_up,
                                        color: Theme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        provider.playAudio(word.audioUrl);
                                      },
                                      tooltip: loc.vocabularyListenTooltip,
                                    ),
                                ],
                              ),
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

  void _showWordDetailsDialog(BuildContext context, Word word,
      WordProvider provider, TranslationProvider translationProvider) {
    final correctTranslation = provider.getCorrectTranslation(
        word, translationProvider.currentTarget);
    final loc = AppLocalizations.of(context)!;
    final alphabetProvider = context.read<AlphabetProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Row(
          children: [
            Expanded(
              child: Text(
                  word.getTerm(alphabetProvider.isCyrillic),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
            // --- ADDED: Reset Progress Button ---
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              tooltip: loc.learningResetProgress,
              onPressed: () {
                provider.resetWordProgress(word);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.learningSnackbarReset)),
                );
              },
            ),
            // --- END ADDED ---
            if (word.audioUrl != null)
              IconButton(
                icon: Icon(Icons.play_circle_filled,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  provider.playAudio(word.audioUrl);
                },
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (word.imageUrl != null) ...[
                Center(
                  child: _buildWordImage(word.imageUrl, size: 120),
                ),
                const SizedBox(height: 16),
              ],
              Text(loc.vocabularyDetailTranslation,
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontSize: 12)),
              Text(correctTranslation,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16)),
              if (word.exampleSentence != null) ...[
                const SizedBox(height: 16),
                Text(loc.vocabularyDetailExample,
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 12)),
                Row(
                  children: [
                    Expanded(
                      child: Text(word.exampleSentence!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                              fontSize: 14,
                              fontStyle: FontStyle.italic)),
                    ),
                    if (word.exampleAudioUrl != null)
                      IconButton(
                        icon: Icon(Icons.play_circle_filled,
                            color: Theme.of(context).primaryColor, size: 24),
                        onPressed: () {
                          provider.playAudio(word.exampleAudioUrl);
                        },
                      ),
                  ],
                ),
              ],
              if (word.exampleTranslation != null) ...[
                const SizedBox(height: 8),
                Text(word.exampleTranslation!,
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.vocabularyDetailCorrect,
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 12)),
                      Text('${word.correctCount}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.vocabularyDetailIncorrect,
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 12)),
                      Text('${word.incorrectCount}',
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor, // Red
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.vocabularyDetailLevel,
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 12)),
                      Text('${word.reviewLevel}',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteWord(word.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.learningSnackbarDeleted)),
              );
            },
            child: Text(loc.dialogDelete,
                style: TextStyle(color: Theme.of(context).indicatorColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditWordDialog(context, word, provider);
            },
            child: Text(loc.dialogEdit,
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.dialogClose,
                style: TextStyle(color: Theme.of(context).hintColor)),
          ),
        ],
      ),
    );
  }

  void _showEditWordDialog(
      BuildContext context, Word word, WordProvider provider) {
    showEditWordDialog(context, word);
  }
}