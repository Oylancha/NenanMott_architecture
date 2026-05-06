import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @externalDictTitle.
  ///
  /// In ru, this message translates to:
  /// **'Внешний словарь'**
  String get externalDictTitle;

  /// No description provided for @externalDictSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по внешнему словарю...'**
  String get externalDictSearchHint;

  /// No description provided for @externalDictAddButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в библиотеку'**
  String get externalDictAddButton;

  /// No description provided for @learnMenuExternalDictionary.
  ///
  /// In ru, this message translates to:
  /// **'Внешний словарь'**
  String get learnMenuExternalDictionary;

  /// No description provided for @bottomNavLearn.
  ///
  /// In ru, this message translates to:
  /// **'Учить'**
  String get bottomNavLearn;

  /// No description provided for @bottomNavDictionary.
  ///
  /// In ru, this message translates to:
  /// **'Словарь'**
  String get bottomNavDictionary;

  /// No description provided for @bottomNavTts.
  ///
  /// In ru, this message translates to:
  /// **'Озвучка'**
  String get bottomNavTts;

  /// No description provided for @bottomNavSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get bottomNavSettings;

  /// No description provided for @dialogConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get dialogConfirmTitle;

  /// No description provided for @dialogConfirmContent.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать это изображение?'**
  String get dialogConfirmContent;

  /// No description provided for @dialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get dialogCancel;

  /// No description provided for @dialogSelect.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get dialogSelect;

  /// No description provided for @dialogClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get dialogClose;

  /// No description provided for @dialogSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get dialogSave;

  /// No description provided for @dialogEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get dialogEdit;

  /// No description provided for @dialogDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get dialogDelete;

  /// No description provided for @categorySelectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать категории'**
  String get categorySelectionTitle;

  /// No description provided for @categoryStatusAllSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбраны все категории'**
  String get categoryStatusAllSelected;

  /// No description provided for @categoryStatusNoneSelected.
  ///
  /// In ru, this message translates to:
  /// **'Категории не выбраны'**
  String get categoryStatusNoneSelected;

  /// No description provided for @categoryStatusCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} из {total} выбрано'**
  String categoryStatusCount(Object count, Object total);

  /// No description provided for @categoryClearAll.
  ///
  /// In ru, this message translates to:
  /// **'Убрать весь выбор'**
  String get categoryClearAll;

  /// No description provided for @categorySelectAll.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать все'**
  String get categorySelectAll;

  /// No description provided for @categoryWordCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =1{{count} слово} few{{count} слова} many{{count} слов} other{{count} слова}}'**
  String categoryWordCount(num count);

  /// No description provided for @imageSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Искать изображение...'**
  String get imageSearchHint;

  /// No description provided for @imageSearchPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Напишите слово для поиска изображения'**
  String get imageSearchPrompt;

  /// No description provided for @imageSearchNoneFound.
  ///
  /// In ru, this message translates to:
  /// **'Изображения не найдены.'**
  String get imageSearchNoneFound;

  /// No description provided for @vocabularyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Словарь'**
  String get vocabularyTitle;

  /// No description provided for @vocabularyAddWordTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Добавить новое слово'**
  String get vocabularyAddWordTooltip;

  /// No description provided for @vocabularyStatTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего слов'**
  String get vocabularyStatTotal;

  /// No description provided for @vocabularyStatLearned.
  ///
  /// In ru, this message translates to:
  /// **'Запомнено'**
  String get vocabularyStatLearned;

  /// No description provided for @vocabularySearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Сделайте поиск слов или категорий...'**
  String get vocabularySearchHint;

  /// No description provided for @vocabularySearchNoneFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get vocabularySearchNoneFound;

  /// No description provided for @vocabularyCategoryStats.
  ///
  /// In ru, this message translates to:
  /// **'{wordCount} слов • {learnedCount} запомнено'**
  String vocabularyCategoryStats(Object learnedCount, Object wordCount);

  /// No description provided for @vocabularySearchWordsHint.
  ///
  /// In ru, this message translates to:
  /// **'Искать слова...'**
  String get vocabularySearchWordsHint;

  /// No description provided for @vocabularyWordsNoneFound.
  ///
  /// In ru, this message translates to:
  /// **'Слова не найдены'**
  String get vocabularyWordsNoneFound;

  /// No description provided for @vocabularyCustomTag.
  ///
  /// In ru, this message translates to:
  /// **'Кастомное'**
  String get vocabularyCustomTag;

  /// No description provided for @vocabularyListenTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать'**
  String get vocabularyListenTooltip;

  /// No description provided for @vocabularyDetailTranslation.
  ///
  /// In ru, this message translates to:
  /// **'Перевод:'**
  String get vocabularyDetailTranslation;

  /// No description provided for @vocabularyDetailExample.
  ///
  /// In ru, this message translates to:
  /// **'Предложение-пример:'**
  String get vocabularyDetailExample;

  /// No description provided for @vocabularyDetailCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Верно:'**
  String get vocabularyDetailCorrect;

  /// No description provided for @vocabularyDetailIncorrect.
  ///
  /// In ru, this message translates to:
  /// **'Неверно:'**
  String get vocabularyDetailIncorrect;

  /// No description provided for @vocabularyDetailLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень:'**
  String get vocabularyDetailLevel;

  /// No description provided for @addWordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить новое слово'**
  String get addWordTitle;

  /// No description provided for @addWordChechenLabel.
  ///
  /// In ru, this message translates to:
  /// **'Слово на чеченском (обязательно)'**
  String get addWordChechenLabel;

  /// No description provided for @addWordRussianLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (обязательно)'**
  String get addWordRussianLabel;

  /// No description provided for @addWordEnglishLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (English)'**
  String get addWordEnglishLabel;

  /// No description provided for @addWordFrenchLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (Français)'**
  String get addWordFrenchLabel;

  /// No description provided for @addWordGermanLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (Deutsch)'**
  String get addWordGermanLabel;

  /// No description provided for @addWordCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get addWordCategoryLabel;

  /// No description provided for @addWordExampleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предложение-пример'**
  String get addWordExampleLabel;

  /// No description provided for @addWordExampleTranslationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод примера'**
  String get addWordExampleTranslationLabel;

  /// No description provided for @addWordEmptyError.
  ///
  /// In ru, this message translates to:
  /// **'Это поле не может быть пустым'**
  String get addWordEmptyError;

  /// No description provided for @addWordImageLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get addWordImageLoading;

  /// No description provided for @addWordImageImport.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать изображение'**
  String get addWordImageImport;

  /// No description provided for @addWordImageChange.
  ///
  /// In ru, this message translates to:
  /// **'Заменить изображение'**
  String get addWordImageChange;

  /// No description provided for @addWordCreateAudioTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Создать озвучку'**
  String get addWordCreateAudioTooltip;

  /// No description provided for @addWordSnackbarSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Слово добавлено'**
  String get addWordSnackbarSuccess;

  /// No description provided for @addWordSnackbarAudioError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка генерации аудио'**
  String get addWordSnackbarAudioError;

  /// No description provided for @addWordTurkishLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (Türkçe)'**
  String get addWordTurkishLabel;

  /// No description provided for @addWordArabicLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (العربية)'**
  String get addWordArabicLabel;

  /// No description provided for @addWordChechenLatinLabel.
  ///
  /// In ru, this message translates to:
  /// **'Слово на чеченском (Латиница)'**
  String get addWordChechenLatinLabel;

  /// No description provided for @editWordTurkishLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (Türkçe)'**
  String get editWordTurkishLabel;

  /// No description provided for @editWordArabicLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (العربية)'**
  String get editWordArabicLabel;

  /// No description provided for @editWordChechenLabel.
  ///
  /// In ru, this message translates to:
  /// **'Слово на чеченском'**
  String get editWordChechenLabel;

  /// No description provided for @editWordTranslationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get editWordTranslationLabel;

  /// No description provided for @editWordExampleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предложение-пример на чеченском'**
  String get editWordExampleLabel;

  /// No description provided for @editWordExampleTranslationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предложение-пример в переводе'**
  String get editWordExampleTranslationLabel;

  /// No description provided for @editWordSnackbarSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Слово обновлено'**
  String get editWordSnackbarSuccess;

  /// No description provided for @editWordChechenLatinLabel.
  ///
  /// In ru, this message translates to:
  /// **'Слово на чеченском (Латиница)'**
  String get editWordChechenLatinLabel;

  /// No description provided for @learningSessionComplete.
  ///
  /// In ru, this message translates to:
  /// **'Сессия завершена!'**
  String get learningSessionComplete;

  /// No description provided for @learningBackToMenu.
  ///
  /// In ru, this message translates to:
  /// **'Обратно в меню'**
  String get learningBackToMenu;

  /// No description provided for @learningProgressWords.
  ///
  /// In ru, this message translates to:
  /// **'Слов {completed} из {total}'**
  String learningProgressWords(Object completed, Object total);

  /// No description provided for @learningProgressMemorized.
  ///
  /// In ru, this message translates to:
  /// **'{count} слов пройдено'**
  String learningProgressMemorized(Object count);

  /// No description provided for @learningModeBrowse.
  ///
  /// In ru, this message translates to:
  /// **'Режим просмотра всех слов'**
  String get learningModeBrowse;

  /// No description provided for @learningReviewRepeat.
  ///
  /// In ru, this message translates to:
  /// **'{count} повтор'**
  String learningReviewRepeat(Object count);

  /// No description provided for @learningCustomWord.
  ///
  /// In ru, this message translates to:
  /// **'Свои слова'**
  String get learningCustomWord;

  /// No description provided for @learningTypeHint.
  ///
  /// In ru, this message translates to:
  /// **'Напечатайте перевод...'**
  String get learningTypeHint;

  /// No description provided for @learningCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Правильно!'**
  String get learningCorrect;

  /// No description provided for @learningIncorrect.
  ///
  /// In ru, this message translates to:
  /// **'Правильный ответ: {answer}'**
  String learningIncorrect(Object answer);

  /// No description provided for @learningPrevious.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущее'**
  String get learningPrevious;

  /// No description provided for @learningNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующее'**
  String get learningNext;

  /// No description provided for @learningAlreadyKnown.
  ///
  /// In ru, this message translates to:
  /// **'Уже известно'**
  String get learningAlreadyKnown;

  /// No description provided for @learningStartLearning.
  ///
  /// In ru, this message translates to:
  /// **'Начать учить'**
  String get learningStartLearning;

  /// No description provided for @learningContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get learningContinue;

  /// No description provided for @learningCheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get learningCheck;

  /// No description provided for @learningRemembered.
  ///
  /// In ru, this message translates to:
  /// **'Вспомнил'**
  String get learningRemembered;

  /// No description provided for @learningForgot.
  ///
  /// In ru, this message translates to:
  /// **'Не вспомнил'**
  String get learningForgot;

  /// No description provided for @learningShowLater.
  ///
  /// In ru, this message translates to:
  /// **'Показать позже'**
  String get learningShowLater;

  /// No description provided for @learningResetProgress.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить прогрес'**
  String get learningResetProgress;

  /// No description provided for @learningDeleteWord.
  ///
  /// In ru, this message translates to:
  /// **'Удалить слово'**
  String get learningDeleteWord;

  /// No description provided for @learningSnackbarReset.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс для этого слова сброшен'**
  String get learningSnackbarReset;

  /// No description provided for @learningDeleteDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить слово?'**
  String get learningDeleteDialogTitle;

  /// No description provided for @learningDeleteDialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Ты уверен, что хочешь удалить \"{word}\"?'**
  String learningDeleteDialogContent(Object word);

  /// No description provided for @learningSnackbarDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Слово удалено'**
  String get learningSnackbarDeleted;

  /// No description provided for @learningUseHint.
  ///
  /// In ru, this message translates to:
  /// **'Подсказка (ост. {count})'**
  String learningUseHint(Object count);

  /// No description provided for @learningAttemptsRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось попыток: {count}'**
  String learningAttemptsRemaining(Object count);

  /// No description provided for @learningIncorrectAttemptsLeft.
  ///
  /// In ru, this message translates to:
  /// **'Неверно. Попыток осталось: {count}'**
  String learningIncorrectAttemptsLeft(Object count);

  /// No description provided for @learnMenuTitle.
  ///
  /// In ru, this message translates to:
  /// **'Учить'**
  String get learnMenuTitle;

  /// No description provided for @learnMenuAllCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get learnMenuAllCategories;

  /// No description provided for @learnMenuNoCategories.
  ///
  /// In ru, this message translates to:
  /// **'Нет категорий'**
  String get learnMenuNoCategories;

  /// No description provided for @learnMenuCategoryCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =1{{count} категория} few{{count} категории} many{{count} категорий} other{{count} категории}}'**
  String learnMenuCategoryCount(num count);

  /// No description provided for @learnMenuLearnNew.
  ///
  /// In ru, this message translates to:
  /// **'Заучивание новых слов'**
  String get learnMenuLearnNew;

  /// No description provided for @learnMenuWordsAvailable.
  ///
  /// In ru, this message translates to:
  /// **'{count} доступно слов'**
  String learnMenuWordsAvailable(Object count);

  /// No description provided for @learnMenuReview.
  ///
  /// In ru, this message translates to:
  /// **'Повтор слов'**
  String get learnMenuReview;

  /// No description provided for @learnMenuBrowse.
  ///
  /// In ru, this message translates to:
  /// **'Просмотр всех слов'**
  String get learnMenuBrowse;

  /// No description provided for @learnMenuStatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get learnMenuStatsTitle;

  /// No description provided for @learnMenuCurrentStreak.
  ///
  /// In ru, this message translates to:
  /// **'Текущий рекорд'**
  String get learnMenuCurrentStreak;

  /// No description provided for @learnMenuStreakDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =1{{count} день} few{{count} дня} many{{count} дней} other{{count} дня}}'**
  String learnMenuStreakDays(num count);

  /// No description provided for @learnMenuBestStreak.
  ///
  /// In ru, this message translates to:
  /// **'Лучший рекорд'**
  String get learnMenuBestStreak;

  /// No description provided for @learnMenuLearnedToday.
  ///
  /// In ru, this message translates to:
  /// **'Заучено сегодня'**
  String get learnMenuLearnedToday;

  /// No description provided for @learnMenuTodayProgress.
  ///
  /// In ru, this message translates to:
  /// **'{learned} из {limit}'**
  String learnMenuTodayProgress(Object learned, Object limit);

  /// No description provided for @learnMenuPeriod7Days.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get learnMenuPeriod7Days;

  /// No description provided for @learnMenuPeriod30Days.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get learnMenuPeriod30Days;

  /// No description provided for @learnMenuPeriod90Days.
  ///
  /// In ru, this message translates to:
  /// **'90 дней'**
  String get learnMenuPeriod90Days;

  /// No description provided for @learnMenuPeriodAllTime.
  ///
  /// In ru, this message translates to:
  /// **'За все время'**
  String get learnMenuPeriodAllTime;

  /// No description provided for @learnMenuLearningNow.
  ///
  /// In ru, this message translates to:
  /// **'Заучивается сейчас: {count} новых слов'**
  String learnMenuLearningNow(Object count);

  /// No description provided for @learnMenuStatNewWords.
  ///
  /// In ru, this message translates to:
  /// **'Заучено новых слов'**
  String get learnMenuStatNewWords;

  /// No description provided for @learnMenuStatReviewed.
  ///
  /// In ru, this message translates to:
  /// **'Повторено'**
  String get learnMenuStatReviewed;

  /// No description provided for @learnMenuStatMastered.
  ///
  /// In ru, this message translates to:
  /// **'Запомнено'**
  String get learnMenuStatMastered;

  /// No description provided for @learnMenuStatKnown.
  ///
  /// In ru, this message translates to:
  /// **'Уже было известно'**
  String get learnMenuStatKnown;

  /// No description provided for @learnMenuGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневная цель достигнута!'**
  String get learnMenuGoalTitle;

  /// No description provided for @learnMenuGoalContentNew.
  ///
  /// In ru, this message translates to:
  /// **'Вы выучили {count} новых слов сегодня!'**
  String learnMenuGoalContentNew(Object count);

  /// No description provided for @learnMenuGoalContentReview.
  ///
  /// In ru, this message translates to:
  /// **'Вы повторили {count} слов сегодня!'**
  String learnMenuGoalContentReview(Object count);

  /// No description provided for @learnMenuGoalContinue.
  ///
  /// In ru, this message translates to:
  /// **'Учить еще'**
  String get learnMenuGoalContinue;

  /// No description provided for @learnMenuGoalReview.
  ///
  /// In ru, this message translates to:
  /// **'Повтор слов'**
  String get learnMenuGoalReview;

  /// No description provided for @learnMenuGoalBackToMenu.
  ///
  /// In ru, this message translates to:
  /// **'Обратно в главное меню'**
  String get learnMenuGoalBackToMenu;

  /// No description provided for @learnMenuStatsPageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get learnMenuStatsPageTitle;

  /// No description provided for @learnMenuStatsComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Детальную статистику добавят позже'**
  String get learnMenuStatsComingSoon;

  /// No description provided for @ttsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Озвучка'**
  String get ttsTitle;

  /// No description provided for @ttsTooltipHideKeyboard.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть клавиатуру'**
  String get ttsTooltipHideKeyboard;

  /// No description provided for @ttsTooltipClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get ttsTooltipClear;

  /// No description provided for @ttsErrorGenerate.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка генерации озвучки. Попробуйте снова.'**
  String get ttsErrorGenerate;

  /// No description provided for @ttsErrorPlay.
  ///
  /// In ru, this message translates to:
  /// **'Возникла ошибка при проигрывании аудио файла.'**
  String get ttsErrorPlay;

  /// No description provided for @ttsErrorFile.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка генерации файла. Попробуйте снова.'**
  String get ttsErrorFile;

  /// No description provided for @ttsShareText.
  ///
  /// In ru, this message translates to:
  /// **'Аудио файл'**
  String get ttsShareText;

  /// No description provided for @ttsSaveDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить аудио файл'**
  String get ttsSaveDialogTitle;

  /// No description provided for @ttsSnackbarSaveSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Файл сохранен: {path}'**
  String ttsSnackbarSaveSuccess(Object path);

  /// No description provided for @ttsErrorSave.
  ///
  /// In ru, this message translates to:
  /// **'Возникла ошибка при сохранении файла: {error}'**
  String ttsErrorSave(Object error);

  /// No description provided for @ttsButtonListen.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать'**
  String get ttsButtonListen;

  /// No description provided for @ttsButtonDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачать'**
  String get ttsButtonDownload;

  /// No description provided for @ttsInstructionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Инструкция'**
  String get ttsInstructionsTitle;

  /// No description provided for @ttsInstructionsContent.
  ///
  /// In ru, this message translates to:
  /// **'Это страница для озвучки любого чеченского текста. Текст озвучивает компьютерная модель, поэтому произношение порой может быть некорректным. Лучший способ ввода текста это зайти в Google Переводчик, перевести текст с другого языка, например русского, на чеченский и этот чеченский текст скопировать и вставить сюда. Числа написанные в виде цифр модель не читает, только написанные словами.'**
  String get ttsInstructionsContent;

  /// No description provided for @ttsChechenTextLabel.
  ///
  /// In ru, this message translates to:
  /// **'Текст на чеченском'**
  String get ttsChechenTextLabel;

  /// No description provided for @ttsHint.
  ///
  /// In ru, this message translates to:
  /// **'Напечатайте или вставьте текст сюда...'**
  String get ttsHint;

  /// No description provided for @settingsPageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsPageTitle;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In ru, this message translates to:
  /// **'Темная Тема'**
  String get settingsDarkTheme;

  /// No description provided for @settingsContentTranslationLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык перевода'**
  String get settingsContentTranslationLanguage;

  /// No description provided for @settingsUiLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get settingsUiLanguage;

  /// No description provided for @settingsLearnWordsPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Учить слов в день'**
  String get settingsLearnWordsPerDay;

  /// No description provided for @settingsTodayLearned.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня: {learned}/{limit}'**
  String settingsTodayLearned(Object learned, Object limit);

  /// No description provided for @settingsReviewWordsPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Повторять слов в день'**
  String get settingsReviewWordsPerDay;

  /// No description provided for @settingsTodayReviewed.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня: {reviewed}/{limit}'**
  String settingsTodayReviewed(Object limit, Object reviewed);

  /// No description provided for @settingsResetProgressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить прогресс'**
  String get settingsResetProgressTitle;

  /// No description provided for @settingsResetProgressSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить весь прогресс изучения'**
  String get settingsResetProgressSubtitle;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить прогресс?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены? Это удалит ВЕСЬ ваш прогресс. Это нельзя отменить.'**
  String get settingsResetDialogContent;

  /// No description provided for @settingsResetDialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get settingsResetDialogCancel;

  /// No description provided for @settingsResetDialogConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get settingsResetDialogConfirm;

  /// No description provided for @settingsResetSnackbarInProgress.
  ///
  /// In ru, this message translates to:
  /// **'Сброс...'**
  String get settingsResetSnackbarInProgress;

  /// No description provided for @settingsResetSnackbarSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Сброс прошел успешно'**
  String get settingsResetSnackbarSuccess;

  /// No description provided for @settingsResetSnackbarError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сброса: {error}'**
  String settingsResetSnackbarError(Object error);

  /// No description provided for @settingsAboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Версия 1.0.0'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAlphabetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Алфавит'**
  String get settingsAlphabetTitle;

  /// No description provided for @settingsAlphabetSubtitleCyrillic.
  ///
  /// In ru, this message translates to:
  /// **'Кириллица (Нохчийн)'**
  String get settingsAlphabetSubtitleCyrillic;

  /// No description provided for @settingsAlphabetSubtitleLatin.
  ///
  /// In ru, this message translates to:
  /// **'Латиница (Noxçiyn)'**
  String get settingsAlphabetSubtitleLatin;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In ru, this message translates to:
  /// **'Облачное резервное копирование'**
  String get settingsBackupTitle;

  /// No description provided for @settingsBackupSignedInAs.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как {email}'**
  String settingsBackupSignedInAs(Object email);

  /// No description provided for @settingsBackupSignInPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы сохранить прогресс'**
  String get settingsBackupSignInPrompt;

  /// No description provided for @settingsBackupSignInButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get settingsBackupSignInButton;

  /// No description provided for @settingsBackupInProgress.
  ///
  /// In ru, this message translates to:
  /// **'Создание резервной копии...'**
  String get settingsBackupInProgress;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия создана!'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsBackupFailure.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка копирования: {error}'**
  String settingsBackupFailure(Object error);

  /// No description provided for @settingsBackupButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать копию'**
  String get settingsBackupButton;

  /// No description provided for @settingsRestoreTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить?'**
  String get settingsRestoreTitle;

  /// No description provided for @settingsRestoreContent.
  ///
  /// In ru, this message translates to:
  /// **'Это ПЕРЕЗАПИШЕТ ваш текущий прогресс версией из облака. Вы уверены?'**
  String get settingsRestoreContent;

  /// No description provided for @settingsRestoreButton.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get settingsRestoreButton;

  /// No description provided for @settingsRestoreInProgress.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление...'**
  String get settingsRestoreInProgress;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление успешно!'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreFailure.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка восстановления: {error}'**
  String settingsRestoreFailure(Object error);

  /// No description provided for @settingsSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get settingsSignOut;

  /// No description provided for @settingsCopyLetterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать букву \'Ӏ\''**
  String get settingsCopyLetterTitle;

  /// No description provided for @settingsCopyLetterSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы скопировать букву \'Ӏ\''**
  String get settingsCopyLetterSubtitle;

  /// No description provided for @settingsCopyLetterSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Буква \'Ӏ\' скопирована!'**
  String get settingsCopyLetterSuccess;

  /// No description provided for @settingsAboutAuthor.
  ///
  /// In ru, this message translates to:
  /// **'Разработчик: Эльмарзер Ислам (Ислам Эльмурзаев)'**
  String get settingsAboutAuthor;

  /// No description provided for @settingsAboutImages.
  ///
  /// In ru, this message translates to:
  /// **'Поиск изображений работает через Pixabay'**
  String get settingsAboutImages;

  /// No description provided for @settingsAboutTts.
  ///
  /// In ru, this message translates to:
  /// **'Модель озвучки: mms-tts-che'**
  String get settingsAboutTts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
