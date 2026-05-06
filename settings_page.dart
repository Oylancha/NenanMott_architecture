import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../providers/word_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/translation_provider.dart';
import '../services/backup_service.dart';
import '../l10n/app_localizations.dart'; 
import '../providers/locale_provider.dart';
import '../providers/alphabet_provider.dart';
import '../providers/auth_provider.dart';

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final alphabetProvider = context.watch<AlphabetProvider>();
    final translationProvider = context.watch<TranslationProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final loc = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsPageTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Dark Theme Tile ---
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(loc.settingsDarkTheme,
                  style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color)),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // --- Cloud Backup Tile ---
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.cloud_upload,
                          color: Theme.of(context).primaryColor),
                      title: Text(
                        loc.settingsBackupTitle, // Localized
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        authProvider.isLoggedIn
                            ? loc.settingsBackupSignedInAs(authProvider.user?.email ?? 'User') // Localized
                            : loc.settingsBackupSignInPrompt, // Localized
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                    if (authProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (!authProvider.isLoggedIn)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthProvider>().signInWithGoogle();
                            },
                            icon: const Icon(Icons.login),
                            label: Text(loc.settingsBackupSignInButton), // Localized
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).cardColor,
                              foregroundColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      // Signed In Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            // --- BACKUP BUTTON ---
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final user = authProvider.user;
                                  if (user == null) return;

                                  final backupService = BackupService();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(loc.settingsBackupInProgress)), // Localized
                                  );

                                  try {
                                    await backupService.backupDatabase(user.uid);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.settingsBackupSuccess), // Localized
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.settingsBackupFailure(e.toString())), // Localized
                                          backgroundColor: Theme.of(context).indicatorColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.upload),
                                label: Text(loc.settingsBackupButton), // Localized
                              ),
                            ),
                            const SizedBox(width: 12),
                            // --- RESTORE BUTTON ---
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final user = authProvider.user;
                                  if (user == null) return;

                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                                      title: Text(loc.settingsRestoreTitle), // Localized
                                      content: Text(loc.settingsRestoreContent), // Localized
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text(loc.dialogCancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text(
                                            loc.settingsRestoreButton, // Localized
                                            style: TextStyle(color: Theme.of(context).indicatorColor)
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  final backupService = BackupService();
                                  
                                  if(context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.settingsRestoreInProgress)), // Localized
                                    );
                                  }

                                  try {
                                    await backupService.restoreDatabase(user.uid);
                                    
                                    if (context.mounted) {
                                      await context.read<WordProvider>().loadWords();
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.settingsRestoreSuccess), // Localized
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.settingsRestoreFailure(e.toString())), // Localized
                                          backgroundColor: Theme.of(context).indicatorColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: Text(loc.settingsRestoreButton), // Localized
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().signOut();
                        },
                        child: Text(
                          loc.settingsSignOut, // Localized
                          style: TextStyle(color: Theme.of(context).indicatorColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ),

          // --- Content Translation Language Tile ---
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.translate,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(loc.settingsContentTranslationLanguage,
                  style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color)),
              trailing: DropdownButton<TranslationTarget>(
                value: translationProvider.currentTarget,
                dropdownColor: Theme.of(context).cardColor,
                underline: Container(),
                icon: Icon(Icons.arrow_drop_down,
                    color: Theme.of(context).hintColor),
                onChanged: (TranslationTarget? newValue) {
                  if (newValue != null) {
                    context
                        .read<TranslationProvider>()
                        .setLanguage(newValue);
                  }
                },
                items: [
                  _buildLangItem(
                      context, 'Русский', TranslationTarget.russian),
                  _buildLangItem(
                      context, 'English', TranslationTarget.english),
                  _buildLangItem(
                      context, 'Français', TranslationTarget.french),
                  _buildLangItem(
                      context, 'Deutsch', TranslationTarget.german),
                  _buildLangItem(
                      context, 'Türkçe', TranslationTarget.turkish),
                  _buildLangItem(
                      context, 'العربية', TranslationTarget.arabic),
                ],
              ),
            ),
          ),

          // --- App UI Language Tile ---
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.language,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(loc.settingsUiLanguage,
                  style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color)),
              trailing: DropdownButton<Locale>(
                value: localeProvider.locale,
                dropdownColor: Theme.of(context).cardColor,
                underline: Container(),
                icon: Icon(Icons.arrow_drop_down,
                    color: Theme.of(context).hintColor),
                onChanged: (Locale? newValue) {
                  if (newValue != null) {
                    context.read<LocaleProvider>().setLocale(newValue);
                  }
                },
                items: [
                  _buildLocaleItem(context, 'Русский', const Locale('ru')),
                  _buildLocaleItem(context, 'English', const Locale('en')),
                ],
              ),
            ),
          ),

          Consumer<WordProvider>(
            builder: (context, provider, _) => Column(
              children: [
                // --- Learn Words per Day Tile ---
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            loc.settingsLearnWordsPerDay,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme.bodyLarge
                                  ?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: provider.dailyNewWordsLimit.toDouble(),
                              min: 5,
                              max: 50,
                              divisions: 9,
                              activeColor: Theme.of(context).primaryColor,
                              label: '${provider.dailyNewWordsLimit}',
                              onChanged: (value) {
                                provider.setDailyLimits(
                                  value.toInt(),
                                  provider.dailyReviewLimit,
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${provider.dailyNewWordsLimit}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        loc.settingsTodayLearned(
                          provider.todayNewWordsLearned,
                          provider.dailyNewWordsLimit,
                        ),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // --- Review Words per Day Tile ---
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.refresh,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            loc.settingsReviewWordsPerDay,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: provider.dailyReviewLimit.toDouble(),
                              min: 10,
                              max: 100,
                              divisions: 18,
                              activeColor: Theme.of(context).primaryColor,
                              label: '${provider.dailyReviewLimit}',
                              onChanged: (value) {
                                provider.setDailyLimits(
                                  provider.dailyNewWordsLimit,
                                  value.toInt(),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${provider.dailyReviewLimit}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        loc.settingsTodayReviewed(
                          provider.todayWordsReviewed,
                          provider.dailyReviewLimit,
                        ),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSettingItem(
            context,
            loc.settingsAlphabetTitle,
            alphabetProvider.isCyrillic
                ? loc.settingsAlphabetSubtitleCyrillic
                : loc.settingsAlphabetSubtitleLatin,
            Icons.sort_by_alpha,
            () {
              _showAlphabetDialog(context, alphabetProvider, loc);
            },
          ),
          
          // --- Reset Progress Tile ---
          _buildSettingItem(
            context,
            loc.settingsResetProgressTitle,
            loc.settingsResetProgressSubtitle,
            Icons.refresh,
            () async {
              final bool? didConfirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      Theme.of(context).dialogBackgroundColor,
                  title: Text(loc.settingsResetDialogTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                  content: Text(
                    loc.settingsResetDialogContent,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(loc.settingsResetDialogCancel,
                          style:
                              TextStyle(color: Theme.of(context).hintColor)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(loc.settingsResetDialogConfirm,
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor)),
                    ),
                  ],
                ),
              );

              if (didConfirm == true && context.mounted) {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.settingsResetSnackbarInProgress)),
                  );
                  await context.read<WordProvider>().resetAllProgress();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.settingsResetSnackbarSuccess)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc.settingsResetSnackbarError(e.toString()),
                        ),
                        backgroundColor:
                            Theme.of(context).indicatorColor,
                      ),
                    );
                  }
                }
              }
            },
          ),

          // --- Copy Character Tile ---
          _buildSettingItem(
            context,
            loc.settingsCopyLetterTitle, // Localized
            loc.settingsCopyLetterSubtitle, // Localized
            Icons.content_copy,
            () {
              Clipboard.setData(const ClipboardData(text: 'Ӏ'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    loc.settingsCopyLetterSuccess, // Localized
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onInverseSurface),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          
          // --- ABOUT APP TILE ---
          _buildSettingItem(
            context,
            loc.settingsAboutTitle, 
            loc.settingsAboutSubtitle, 
            Icons.info_outline,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).dialogBackgroundColor,
                  shape: Theme.of(context).dialogTheme.shape,
                  title: Text(loc.settingsAboutTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                          loc.settingsAboutAuthor, // Localized
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.settingsAboutImages, // Localized
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.settingsAboutTts, // Localized
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(loc.dialogClose,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<Locale> _buildLocaleItem(
      BuildContext context, String text, Locale locale) {
    return DropdownMenuItem(
      value: locale,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  DropdownMenuItem<TranslationTarget> _buildLangItem(
      BuildContext context, String text, TranslationTarget target) {
    return DropdownMenuItem(
      value: target,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: Theme.of(context).hintColor, size: 16),
      ),
    );
  }

  void _showAlphabetDialog(
    BuildContext context,
    AlphabetProvider alphabetProvider,
    AppLocalizations loc,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text(loc.settingsAlphabetTitle,
                  style: Theme.of(context).textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: Text(loc.settingsAlphabetSubtitleCyrillic,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    value: true,
                    groupValue: alphabetProvider.isCyrillic,
                    onChanged: (value) {
                      setDialogState(() {
                        alphabetProvider.setAlphabet(true);
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  RadioListTile<bool>(
                    title: Text(loc.settingsAlphabetSubtitleLatin,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    value: false,
                    groupValue: alphabetProvider.isCyrillic,
                    onChanged: (value) {
                      setDialogState(() {
                        alphabetProvider.setAlphabet(false);
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(loc.dialogClose,
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}