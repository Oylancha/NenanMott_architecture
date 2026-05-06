// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import '../l10n/app_localizations.dart';
import 'providers/word_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_menu_screen.dart';
import 'providers/translation_provider.dart';
import 'providers/locale_provider.dart'; 
import 'providers/external_dictionary_provider.dart'; 
import 'providers/alphabet_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart'; // <-- Import this

void main() async {
  // 3. Keep this line (you likely already have it)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Add this block to start Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [

        
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => AlphabetProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(
          create: (_) => WordProvider()..loadWords(), 
        ),
        ChangeNotifierProvider(
          create: (_) => ExternalDictionaryProvider()..loadWords(),
        ),
      ],
      child: const ChechenLearningApp(),
    ),
  );
}

class ChechenLearningApp extends StatelessWidget {
  const ChechenLearningApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 5. Consume ThemeProvider AND LocaleProvider
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'Chechen Learning',
          theme: themeProvider.themeData,
          
          // --- 6. ADD ALL LOCALIZATION CONFIG ---
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate, // Your app's strings
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru'), // Russian
            Locale('en'), // English
          ],
          // --- END OF CONFIG ---

          home: const MainMenuScreen(),
        );
      },
    );
  }
}