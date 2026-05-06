import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../l10n/app_localizations.dart'; // Import localizations

class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localizations

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.categorySelectionTitle), // Localized title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          final categories = provider.allCategories;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.showAllCategories
                            ? loc.categoryStatusAllSelected
                            : provider.selectedCategories.isEmpty
                                ? loc.categoryStatusNoneSelected
                                : loc.categoryStatusCount(
                                    provider.selectedCategories.length,
                                    categories.length),
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (provider.showAllCategories ||
                            provider.selectedCategories.length ==
                                categories.length) {
                          provider.clearAllCategories();
                        } else {
                          provider.selectAllCategories();
                        }
                      },
                      child: Text(
                        provider.showAllCategories ||
                                provider.selectedCategories.length ==
                                    categories.length
                            ? loc.categoryClearAll
                            : loc.categorySelectAll,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = provider.showAllCategories ||
                        provider.selectedCategories.contains(category);
                    final wordCount = provider.allWords
                        .where((w) => w.category == category)
                        .length;

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
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).indicatorColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          provider.toggleCategory(category);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        title: Text(
                          category,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          loc.categoryWordCount(wordCount), // Localized word count
                          style: TextStyle(
                              color: Theme.of(context).hintColor, fontSize: 12),
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
}