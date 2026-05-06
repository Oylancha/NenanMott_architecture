// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get externalDictTitle => 'External Dictionary';

  @override
  String get externalDictSearchHint => 'Search external dictionary...';

  @override
  String get externalDictAddButton => 'Add to Library';

  @override
  String get learnMenuExternalDictionary => 'External Dictionary';

  @override
  String get bottomNavLearn => 'Learn';

  @override
  String get bottomNavDictionary => 'Dictionary';

  @override
  String get bottomNavTts => 'TTS';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String get dialogConfirmTitle => 'Confirm';

  @override
  String get dialogConfirmContent => 'Select this image?';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSelect => 'Select';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogEdit => 'Edit';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get categorySelectionTitle => 'Select Categories';

  @override
  String get categoryStatusAllSelected => 'All categories selected';

  @override
  String get categoryStatusNoneSelected => 'No categories selected';

  @override
  String categoryStatusCount(Object count, Object total) {
    return '$count of $total selected';
  }

  @override
  String get categoryClearAll => 'Clear All';

  @override
  String get categorySelectAll => 'Select All';

  @override
  String categoryWordCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '$count word',
    );
    return '$_temp0';
  }

  @override
  String get imageSearchHint => 'Search for an image...';

  @override
  String get imageSearchPrompt => 'Enter a term to search for images';

  @override
  String get imageSearchNoneFound => 'No images found.';

  @override
  String get vocabularyTitle => 'Dictionary';

  @override
  String get vocabularyAddWordTooltip => 'Add a new word';

  @override
  String get vocabularyStatTotal => 'Total Words';

  @override
  String get vocabularyStatLearned => 'Learned';

  @override
  String get vocabularySearchHint => 'Search words or categories...';

  @override
  String get vocabularySearchNoneFound => 'Nothing found';

  @override
  String vocabularyCategoryStats(Object learnedCount, Object wordCount) {
    return '$wordCount words • $learnedCount learned';
  }

  @override
  String get vocabularySearchWordsHint => 'Search words...';

  @override
  String get vocabularyWordsNoneFound => 'Words not found';

  @override
  String get vocabularyCustomTag => 'Custom';

  @override
  String get vocabularyListenTooltip => 'Listen';

  @override
  String get vocabularyDetailTranslation => 'Translation:';

  @override
  String get vocabularyDetailExample => 'Example sentence:';

  @override
  String get vocabularyDetailCorrect => 'Correct:';

  @override
  String get vocabularyDetailIncorrect => 'Incorrect:';

  @override
  String get vocabularyDetailLevel => 'Level:';

  @override
  String get addWordTitle => 'Add New Word';

  @override
  String get addWordChechenLabel => 'Word in Chechen (required)';

  @override
  String get addWordRussianLabel => 'Translation (required)';

  @override
  String get addWordEnglishLabel => 'Translation (English)';

  @override
  String get addWordFrenchLabel => 'Translation (Français)';

  @override
  String get addWordGermanLabel => 'Translation (Deutsch)';

  @override
  String get addWordCategoryLabel => 'Category';

  @override
  String get addWordExampleLabel => 'Example sentence';

  @override
  String get addWordExampleTranslationLabel => 'Example translation';

  @override
  String get addWordEmptyError => 'This field cannot be empty';

  @override
  String get addWordImageLoading => 'Loading...';

  @override
  String get addWordImageImport => 'Import Image';

  @override
  String get addWordImageChange => 'Change Image';

  @override
  String get addWordCreateAudioTooltip => 'Generate audio';

  @override
  String get addWordSnackbarSuccess => 'Word added';

  @override
  String get addWordSnackbarAudioError => 'Error generating audio';

  @override
  String get addWordTurkishLabel => 'Translation (Türkçe)';

  @override
  String get addWordArabicLabel => 'Translation (العربية)';

  @override
  String get addWordChechenLatinLabel => 'Word in Chechen (Latin)';

  @override
  String get editWordTurkishLabel => 'Translation (Türkçe)';

  @override
  String get editWordArabicLabel => 'Translation (العربية)';

  @override
  String get editWordChechenLabel => 'Word in Chechen';

  @override
  String get editWordTranslationLabel => 'Translation';

  @override
  String get editWordExampleLabel => 'Example sentence in Chechen';

  @override
  String get editWordExampleTranslationLabel => 'Example sentence translation';

  @override
  String get editWordSnackbarSuccess => 'Word updated';

  @override
  String get editWordChechenLatinLabel => 'Word in Chechen (Latin)';

  @override
  String get learningSessionComplete => 'Session Complete!';

  @override
  String get learningBackToMenu => 'Back to Menu';

  @override
  String learningProgressWords(Object completed, Object total) {
    return 'Word $completed of $total';
  }

  @override
  String learningProgressMemorized(Object count) {
    return '$count words completed';
  }

  @override
  String get learningModeBrowse => 'Browsing all words';

  @override
  String learningReviewRepeat(Object count) {
    return 'Repetition $count';
  }

  @override
  String get learningCustomWord => 'My word';

  @override
  String get learningTypeHint => 'Type the translation...';

  @override
  String get learningCorrect => 'Correct!';

  @override
  String learningIncorrect(Object answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get learningPrevious => 'Previous';

  @override
  String get learningNext => 'Next';

  @override
  String get learningAlreadyKnown => 'Already Known';

  @override
  String get learningStartLearning => 'Start Learning';

  @override
  String get learningContinue => 'Continue';

  @override
  String get learningCheck => 'Check';

  @override
  String get learningRemembered => 'Remembered';

  @override
  String get learningForgot => 'Forgot';

  @override
  String get learningShowLater => 'Show Later';

  @override
  String get learningResetProgress => 'Reset Progress';

  @override
  String get learningDeleteWord => 'Delete Word';

  @override
  String get learningSnackbarReset => 'Progress for this word has been reset';

  @override
  String get learningDeleteDialogTitle => 'Delete word?';

  @override
  String learningDeleteDialogContent(Object word) {
    return 'Are you sure you want to delete \"$word\"?';
  }

  @override
  String get learningSnackbarDeleted => 'Word deleted';

  @override
  String learningUseHint(Object count) {
    return 'Use Hint ($count left)';
  }

  @override
  String learningAttemptsRemaining(Object count) {
    return 'Attempts remaining: $count';
  }

  @override
  String learningIncorrectAttemptsLeft(Object count) {
    return 'Incorrect. Attempts left: $count';
  }

  @override
  String get learnMenuTitle => 'Learn';

  @override
  String get learnMenuAllCategories => 'All Categories';

  @override
  String get learnMenuNoCategories => 'No Categories';

  @override
  String learnMenuCategoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '$count category',
    );
    return '$_temp0';
  }

  @override
  String get learnMenuLearnNew => 'Learn new words';

  @override
  String learnMenuWordsAvailable(Object count) {
    return '$count words available';
  }

  @override
  String get learnMenuReview => 'Review words';

  @override
  String get learnMenuBrowse => 'Browse All Words';

  @override
  String get learnMenuStatsTitle => 'Stats';

  @override
  String get learnMenuCurrentStreak => 'Current streak';

  @override
  String learnMenuStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get learnMenuBestStreak => 'Best streak';

  @override
  String get learnMenuLearnedToday => 'Learned today';

  @override
  String learnMenuTodayProgress(Object learned, Object limit) {
    return '$learned of $limit';
  }

  @override
  String get learnMenuPeriod7Days => '7 days';

  @override
  String get learnMenuPeriod30Days => '30 days';

  @override
  String get learnMenuPeriod90Days => '90 days';

  @override
  String get learnMenuPeriodAllTime => 'All time';

  @override
  String learnMenuLearningNow(Object count) {
    return 'Learning now: $count new words';
  }

  @override
  String get learnMenuStatNewWords => 'New words learned';

  @override
  String get learnMenuStatReviewed => 'Reviewed (unique)';

  @override
  String get learnMenuStatMastered => 'Mastered';

  @override
  String get learnMenuStatKnown => 'Already known';

  @override
  String get learnMenuGoalTitle => 'Daily Goal Reached!';

  @override
  String learnMenuGoalContentNew(Object count) {
    return 'You\'ve learned $count new words today!';
  }

  @override
  String learnMenuGoalContentReview(Object count) {
    return 'You\'ve reviewed $count words today!';
  }

  @override
  String get learnMenuGoalContinue => 'Learn More';

  @override
  String get learnMenuGoalReview => 'Review Words';

  @override
  String get learnMenuGoalBackToMenu => 'Back to Menu';

  @override
  String get learnMenuStatsPageTitle => 'Statistics';

  @override
  String get learnMenuStatsComingSoon => 'Detailed statistics coming soon';

  @override
  String get ttsTitle => 'TTS';

  @override
  String get ttsTooltipHideKeyboard => 'Hide keyboard';

  @override
  String get ttsTooltipClear => 'Clear all';

  @override
  String get ttsErrorGenerate => 'Error generating audio. Please try again.';

  @override
  String get ttsErrorPlay => 'Error playing audio file.';

  @override
  String get ttsErrorFile => 'Error generating file. Please try again.';

  @override
  String get ttsShareText => 'Audio file';

  @override
  String get ttsSaveDialogTitle => 'Save audio file';

  @override
  String ttsSnackbarSaveSuccess(Object path) {
    return 'File saved to: $path';
  }

  @override
  String ttsErrorSave(Object error) {
    return 'Error saving file: $error';
  }

  @override
  String get ttsButtonListen => 'Listen';

  @override
  String get ttsButtonDownload => 'Download';

  @override
  String get ttsInstructionsTitle => 'Instructions';

  @override
  String get ttsInstructionsContent =>
      'This page is for text-to-speech for any Chechen text. The text is voiced by a computer model, so pronunciation may sometimes be incorrect. The best way to input text is to go to Google Translate, translate text from another language (e.g., English) to Chechen, and copy/paste that Chechen text here. Numbers written as digits are not read by the model, only numbers written as words.';

  @override
  String get ttsChechenTextLabel => 'Text in Chechen';

  @override
  String get ttsHint => 'Type or paste text here...';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsDarkTheme => 'Dark Theme';

  @override
  String get settingsContentTranslationLanguage => 'Translation Language';

  @override
  String get settingsUiLanguage => 'App Language';

  @override
  String get settingsLearnWordsPerDay => 'Learn words per day';

  @override
  String settingsTodayLearned(Object learned, Object limit) {
    return 'Today: $learned/$limit';
  }

  @override
  String get settingsReviewWordsPerDay => 'Review words per day';

  @override
  String settingsTodayReviewed(Object limit, Object reviewed) {
    return 'Today: $reviewed/$limit';
  }

  @override
  String get settingsResetProgressTitle => 'Reset progress';

  @override
  String get settingsResetProgressSubtitle => 'Reset all learning progress';

  @override
  String get settingsResetDialogTitle => 'Reset progress?';

  @override
  String get settingsResetDialogContent =>
      'Are you sure? This will delete ALL your progress. This cannot be undone.';

  @override
  String get settingsResetDialogCancel => 'Cancel';

  @override
  String get settingsResetDialogConfirm => 'Reset';

  @override
  String get settingsResetSnackbarInProgress => 'Resetting...';

  @override
  String get settingsResetSnackbarSuccess => 'Reset successful';

  @override
  String settingsResetSnackbarError(Object error) {
    return 'Reset error: $error';
  }

  @override
  String get settingsAboutTitle => 'About App';

  @override
  String get settingsAboutSubtitle => 'Version 1.0.0';

  @override
  String get settingsAlphabetTitle => 'Alphabet';

  @override
  String get settingsAlphabetSubtitleCyrillic => 'Cyrillic (Нохчийн)';

  @override
  String get settingsAlphabetSubtitleLatin => 'Latin (Noxçiyn)';

  @override
  String get settingsBackupTitle => 'Cloud Backup';

  @override
  String settingsBackupSignedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsBackupSignInPrompt => 'Sign in to save your progress';

  @override
  String get settingsBackupSignInButton => 'Sign in with Google';

  @override
  String get settingsBackupInProgress => 'Backing up...';

  @override
  String get settingsBackupSuccess => 'Backup Successful!';

  @override
  String settingsBackupFailure(Object error) {
    return 'Backup Failed: $error';
  }

  @override
  String get settingsBackupButton => 'Backup';

  @override
  String get settingsRestoreTitle => 'Restore Backup?';

  @override
  String get settingsRestoreContent =>
      'This will OVERWRITE your current progress with the version from the cloud. Are you sure?';

  @override
  String get settingsRestoreButton => 'Restore';

  @override
  String get settingsRestoreInProgress => 'Restoring...';

  @override
  String get settingsRestoreSuccess => 'Restore Successful!';

  @override
  String settingsRestoreFailure(Object error) {
    return 'Restore Failed: $error';
  }

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsCopyLetterTitle => 'Copy \'Ӏ\' Character';

  @override
  String get settingsCopyLetterSubtitle =>
      'Press here to copy the \'Ӏ\' letter to use in the app';

  @override
  String get settingsCopyLetterSuccess => '\'Ӏ\' copied to clipboard!';

  @override
  String get settingsAboutAuthor => 'Made by Elmarzer Islam (Islam Elmurzaev)';

  @override
  String get settingsAboutImages => 'Image search engine is powered by Pixabay';

  @override
  String get settingsAboutTts =>
      'The app\'s text-to-speech model is mms-tts-che';
}
