// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word_model.dart';
import 'learn_menu_page.dart';
import 'vocabulary_page.dart';
import 'tts_page.dart';
import 'settings_page.dart';
import 'learning_screen.dart';
import '../l10n/app_localizations.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = 0;
  late PageController _pageController; // <-- 1. ADD A PAGE CONTROLLER

  @override
  void initState() {
    super.initState();
    // 2. INITIALIZE THE CONTROLLER
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordProvider>().loadWords();
    });
  }

  // 3. DISPOSE THE CONTROLLER
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // This list of pages remains the same
    final List<Widget> pages = [
      const LearnMenuPage(),
      const VocabularyPage(),
      const TtsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      // 4. REPLACE THE BODY WITH A PAGEVIEW
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          if (provider.studyMode != StudyMode.none) {
            return const LearningScreen();
          }
          
          // Use PageView to allow swiping
          return PageView(
            controller: _pageController,
            children: pages,
            // 5. UPDATE THE INDEX WHEN THE USER SWIPES
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<WordProvider>(
        builder: (context, provider, _) {
          if (provider.studyMode != StudyMode.none) {
            return const SizedBox.shrink();
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // 6. ANIMATE TO THE PAGE WHEN A TAB IS TAPPED
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.school),
                label: loc.bottomNavLearn,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.book),
                label: loc.bottomNavDictionary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.volume_up_outlined),
                label: loc.bottomNavTts,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: loc.bottomNavSettings,
              ),
            ],
          );
        },
      ),
    );
  }
}