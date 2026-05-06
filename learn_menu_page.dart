// lib/screens/learn_menu_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/word_provider.dart';
import '../providers/external_dictionary_provider.dart'; // <-- 1. IMPORT
import 'category_selection_page.dart';
import 'external_dictionary_page.dart'; // <-- 2. IMPORT

// Learn Menu Page
class LearnMenuPage extends StatelessWidget {
  const LearnMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 3. GET LOC

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.learnMenuTitle), // 4. USE IT
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }

          // 5. WRAP in a second Consumer for the external dictionary
          return Consumer<ExternalDictionaryProvider>(
            builder: (context, externalProvider, _) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Category selection button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategorySelectionPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .scaffoldBackgroundColor, // THEME
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // THEME
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shadowColor: Theme.of(context).shadowColor, // THEME
                          elevation: 4, // Elevation for shadow
                        ),
                        icon: Icon(Icons.filter_list,
                            color: Theme.of(context).primaryColor), // THEME
                        label: Text(
                          // 6. USE LOC
                          provider.showAllCategories
                              ? loc.learnMenuAllCategories
                              : provider.selectedCategories.isEmpty
                                  ? loc.learnMenuNoCategories
                                  : loc.learnMenuCategoryCount(
                                      provider.selectedCategories.length),
                          style: TextStyle( // THEME
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Learn new words card
                    _buildModeCard(
                      context,
                      loc.learnMenuLearnNew, // 7. USE LOC
                      provider.newWordsCount,
                      Icons.add_circle_outline,
                      provider.newWordsCount > 0
                          ? () {
                              // ... (existing logic)
                              if (provider.reachedNewWordsLimit) {
                                showDialog(
                                  context: context,
                                  builder: (context) => DailyGoalReachedDialog(
                                    isNewWords: true,
                                    wordsCompleted:
                                        provider.todayNewWordsLearned,
                                    onContinue: () {
                                      Navigator.pop(context);
                                      provider.setDailyLimits(
                                        provider.dailyNewWordsLimit + 5,
                                        provider.dailyReviewLimit,
                                      );
                                      provider.startLearningNewWords();
                                    },
                                    onReview: () {
                                      Navigator.pop(context);
                                      provider.startReviewingWords();
                                    },
                                    onBackToMenu: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              } else {
                                provider.startLearningNewWords();
                              }
                            }
                          : null, // Disable if 0
                    ),

                    const SizedBox(height: 20),

                    // Review words card
                    _buildModeCard(
                      context,
                      loc.learnMenuReview, // 8. USE LOC
                      provider.reviewWordsCount,
                      Icons.refresh,
                      provider.reviewWordsCount > 0
                          ? () {
                              // ... (existing logic)
                              if (provider.reachedReviewLimit) {
                                showDialog(
                                  context: context,
                                  builder: (context) => DailyGoalReachedDialog(
                                    isNewWords: false,
                                    wordsCompleted:
                                        provider.todayWordsReviewed,
                                    onContinue: () {},
                                    onReview: () {},
                                    onBackToMenu: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              } else {
                                provider.startReviewingWords();
                              }
                            }
                          : null, // Disable if 0
                    ),

                    const SizedBox(height: 20),

                    // Browse All Words card
                    _buildModeCard(
                      context,
                      loc.learnMenuBrowse, // 9. USE LOC
                      provider.browsableWordsCount,
                      Icons.collections_bookmark_outlined,
                      provider.browsableWordsCount > 0
                          ? () {
                              provider.startBrowsing();
                            }
                          : null, // Disable if 0 words
                    ),

                    const SizedBox(height: 20), // 10. ADDED SPACING

                    // 11. ADDED NEW EXTERNAL DICTIONARY CARD
                    _buildModeCard(
                      context,
                      loc.learnMenuExternalDictionary, // New loc string
                      externalProvider.wordCount,
                      Icons.data_exploration_outlined,
                      externalProvider.wordCount > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ExternalDictionaryPage(),
                                ),
                              );
                            }
                          : null,
                    ),

                    // Stats section
                    const StatsSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    bool isEnabled = onPressed != null && count > 0;
    final loc = AppLocalizations.of(context)!; // Get loc for subtitle

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // THEME
            borderRadius: BorderRadius.circular(30), // THEME
            boxShadow: [
              // THEME
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(
              color: isEnabled
                  ? Theme.of(context).primaryColor.withOpacity(0.3) // THEME
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2), // THEME
                  borderRadius: BorderRadius.circular(30), // THEME
                ),
                child: Icon(icon,
                    color: Theme.of(context).primaryColor, size: 32), // THEME
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color, // THEME
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.learnMenuWordsAvailable(count), // 12. USE LOC
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor, // THEME
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isEnabled
                    ? Theme.of(context).hintColor // THEME
                    : Theme.of(context).disabledColor, // THEME
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MODIFIED: Converted to StatefulWidget ---
class StatsSection extends StatefulWidget {
  const StatsSection({Key? key}) : super(key: key);

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  int _selectedPeriodIndex = 0;
  // Labels are now from loc
  // final List<String> _periodLabels = [ ... ] // REMOVED

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 13. GET LOC
    final List<String> _periodLabels = [ // 14. MOVED and USED LOC
      loc.learnMenuPeriod7Days,
      loc.learnMenuPeriod30Days,
      loc.learnMenuPeriod90Days,
      loc.learnMenuPeriodAllTime,
    ];

    return Consumer<WordProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                loc.learnMenuStatsTitle, // 15. USE LOC
                style: TextStyle(
                  color: Theme.of(context).hintColor, // THEME
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildStreakCard(provider, loc), // 16. PASS LOC
              const SizedBox(height: 12),
              _buildDetailedStatsCard(provider, loc, _periodLabels), // 17. PASS LOC
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(WordProvider provider, AppLocalizations loc) { // 18. ACCEPT LOC
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // THEME
        borderRadius: BorderRadius.circular(30), // THEME
        boxShadow: [
          // THEME
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = DateTime.now().subtract(Duration(days: 6 - index));
              final isToday = index == 6;
              final hasActivity = index >= (7 - provider.currentStreak);

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasActivity
                          ? Theme.of(context)
                              .disabledColor
                              .withOpacity(0.5) // THEME
                          : Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).dividerColor, // THEME
                        width: 2,
                      ),
                    ),
                    child: isToday
                        ? Icon(
                            Icons.arrow_drop_up,
                            color: Theme.of(context).primaryColor, // THEME
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayInitial(day.weekday),
                    style: TextStyle(
                      color: Theme.of(context).hintColor, // THEME
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 16),
          Divider(color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Current Streak
              Column(
                children: [
                  Text(
                    loc.learnMenuCurrentStreak, // 19. USE LOC
                    style:
                        TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.learnMenuStreakDays(provider.currentStreak), // 20. USE LOC
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Best Streak
              Column(
                children: [
                  Text(
                    loc.learnMenuBestStreak, // 21. USE LOC
                    style:
                        TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.learnMenuStreakDays(provider.bestStreak), // 22. USE LOC
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard(
      WordProvider provider, AppLocalizations loc, List<String> periodLabels) { // 23. ACCEPT LOC
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // THEME
        borderRadius: BorderRadius.circular(30), // THEME
        boxShadow: [
          // THEME
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: provider.dailyNewWordsLimit > 0
                          ? provider.todayNewWordsLearned /
                              provider.dailyNewWordsLimit
                          : 0,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).disabledColor, // THEME
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor, // THEME
                      ),
                    ),
                    Center(
                      child: Text(
                        '${provider.todayNewWordsLearned}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color, // THEME
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.learnMenuLearnedToday, // 24. USE LOC
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color, // THEME
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      loc.learnMenuTodayProgress( // 25. USE LOC
                          provider.todayNewWordsLearned,
                          provider.dailyNewWordsLimit),
                      style: TextStyle(color: Theme.of(context).hintColor), // THEME
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(periodLabels.length, (index) {
              final label = periodLabels[index]; // 26. USE LIST
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriodIndex = index;
                  });
                },
                child: _PeriodTab(
                  label: label,
                  isSelected: index == _selectedPeriodIndex,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            loc.learnMenuLearningNow(provider.learningNowCount), // 27. USE LOC
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14), // THEME
          ),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            final bool showAllTime = _selectedPeriodIndex == 3;
            final String periodStat = '0';

            return Column(
              children: [
                _buildStatRow(
                  '${provider.totalWordsLearned}',
                  showAllTime ? '${provider.totalWordsLearned}' : periodStat,
                  '',
                  '',
                  Colors.pink,
                  loc.learnMenuStatNewWords, // 28. USE LOC
                ),
                _buildStatRow(
                  '${provider.reviewedWordsTotal}',
                  showAllTime ? '${provider.reviewedWordsTotal}' : periodStat,
                  '',
                  '',
                  Colors.orange,
                  loc.learnMenuStatReviewed, // 29. USE LOC
                ),
                _buildStatRow(
                  '${provider.masteredWords}',
                  showAllTime ? '${provider.masteredWords}' : periodStat,
                  '',
                  '',
                  Colors.green,
                  loc.learnMenuStatMastered, // 30. USE LOC
                ),
                _buildStatRow(
                  '${provider.alreadyKnownWords}',
                  showAllTime ? '${provider.alreadyKnownWords}' : periodStat,
                  '',
                  '',
                  Theme.of(context).hintColor, // THEME
                  loc.learnMenuStatKnown, // 31. USE LOC
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String total, String period, String label1, String label2,
      Color color, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              total,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color, // THEME
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              period,
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16), // THEME
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14), // THEME
          ),
        ],
      ),
    );
  }

  String _getDayInitial(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _PeriodTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).disabledColor.withOpacity(0.5) // THEME
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).textTheme.bodyLarge?.color // THEME
              : Theme.of(context).hintColor, // THEME
          fontSize: 12,
        ),
      ),
    );
  }
}

class DailyGoalReachedDialog extends StatelessWidget {
  final bool isNewWords;
  final int wordsCompleted;
  final VoidCallback onContinue;
  final VoidCallback onReview;
  final VoidCallback onBackToMenu;

  const DailyGoalReachedDialog({
    Key? key,
    required this.isNewWords,
    required this.wordsCompleted,
    required this.onContinue,
    required this.onReview,
    required this.onBackToMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 32. GET LOC

    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor, // THEME
      shape: Theme.of(context).dialogTheme.shape, // THEME
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2), // THEME
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 48,
                color: Theme.of(context).primaryColor, // THEME
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.learnMenuGoalTitle, // 33. USE LOC
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color, // THEME
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isNewWords
                  ? loc.learnMenuGoalContentNew(wordsCompleted) // 34. USE LOC
                  : loc.learnMenuGoalContentReview(wordsCompleted), // 35. USE LOC
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor, // THEME
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isNewWords) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: Theme.of(context).elevatedButtonTheme.style, // THEME
                  child: Text(
                    loc.learnMenuGoalContinue, // 36. USE LOC
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).disabledColor, // THEME
                    foregroundColor:
                        Theme.of(context).textTheme.bodyLarge?.color, // THEME
                    shape: RoundedRectangleBorder(
                      // THEME
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    loc.learnMenuGoalReview, // 37. USE LOC
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color, // THEME
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onBackToMenu,
                child: Text(
                  loc.learnMenuGoalBackToMenu, // 38. USE LOC
                  style: TextStyle(
                    color: Theme.of(context).hintColor, // THEME
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedStatsPage extends StatelessWidget {
  const DetailedStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 39. GET LOC

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.learnMenuStatsPageTitle), // 40. USE IT
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          loc.learnMenuStatsComingSoon, // 41. USE IT
          style: TextStyle(color: Theme.of(context).hintColor), // THEME
        ),
      ),
    );
  }
}