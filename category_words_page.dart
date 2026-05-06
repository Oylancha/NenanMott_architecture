import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../l10n/app_localizations.dart'; // <-- 1. IMPORT

class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // <-- 2. GET LOCALIZATIONS

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.categorySelectionTitle), // <-- 3. USE IT
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          final categories = provider.allCategories;

          // 4. CHOOSE STATUS STRING
          final String statusText;
          if (provider.showAllCategories) {
            statusText = loc.categoryStatusAllSelected;
          } else if (provider.selectedCategories.isEmpty) {
            statusText = loc.categoryStatusNoneSelected;
          } else {
            statusText = loc.categoryStatusCount(
                provider.selectedCategories.length, categories.length);
          }

          // 5. CHOOSE BUTTON TEXT
          final String buttonText = (provider.showAllCategories ||
                  provider.selectedCategories.length == categories.length)
              ? loc.categoryClearAll
              : loc.categorySelectAll;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        statusText, // <-- 6. USE IT
                        style: TextStyle(color: Theme.of(context).hintColor), // THEME
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
                        buttonText, // <-- 7. USE IT
                        style: TextStyle(color: Theme.of(context).primaryColor), // THEME
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
                        color: Theme.of(context).cardColor, // THEME
                        borderRadius: BorderRadius.circular(16), // THEME
                        boxShadow: [ // THEME
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).indicatorColor // THEME (Red lining)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          provider.toggleCategory(category);
                        },
                        activeColor: Theme.of(context).primaryColor, // THEME
                        title: Text(
                          category,
                          style: TextStyle( // THEME
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          loc.categoryWordCount(wordCount), // <-- 8. USE IT
                          style: TextStyle( // THEME
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