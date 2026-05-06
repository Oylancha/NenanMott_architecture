// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get externalDictTitle => 'Внешний словарь';

  @override
  String get externalDictSearchHint => 'Поиск по внешнему словарю...';

  @override
  String get externalDictAddButton => 'Добавить в библиотеку';

  @override
  String get learnMenuExternalDictionary => 'Внешний словарь';

  @override
  String get bottomNavLearn => 'Учить';

  @override
  String get bottomNavDictionary => 'Словарь';

  @override
  String get bottomNavTts => 'Озвучка';

  @override
  String get bottomNavSettings => 'Настройки';

  @override
  String get dialogConfirmTitle => 'Подтвердить';

  @override
  String get dialogConfirmContent => 'Выбрать это изображение?';

  @override
  String get dialogCancel => 'Отменить';

  @override
  String get dialogSelect => 'Выбрать';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get dialogSave => 'Сохранить';

  @override
  String get dialogEdit => 'Редактировать';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get categorySelectionTitle => 'Выбрать категории';

  @override
  String get categoryStatusAllSelected => 'Выбраны все категории';

  @override
  String get categoryStatusNoneSelected => 'Категории не выбраны';

  @override
  String categoryStatusCount(Object count, Object total) {
    return '$count из $total выбрано';
  }

  @override
  String get categoryClearAll => 'Убрать весь выбор';

  @override
  String get categorySelectAll => 'Выбрать все';

  @override
  String categoryWordCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слова',
      many: '$count слов',
      few: '$count слова',
      one: '$count слово',
    );
    return '$_temp0';
  }

  @override
  String get imageSearchHint => 'Искать изображение...';

  @override
  String get imageSearchPrompt => 'Напишите слово для поиска изображения';

  @override
  String get imageSearchNoneFound => 'Изображения не найдены.';

  @override
  String get vocabularyTitle => 'Словарь';

  @override
  String get vocabularyAddWordTooltip => 'Добавить новое слово';

  @override
  String get vocabularyStatTotal => 'Всего слов';

  @override
  String get vocabularyStatLearned => 'Запомнено';

  @override
  String get vocabularySearchHint => 'Сделайте поиск слов или категорий...';

  @override
  String get vocabularySearchNoneFound => 'Ничего не найдено';

  @override
  String vocabularyCategoryStats(Object learnedCount, Object wordCount) {
    return '$wordCount слов • $learnedCount запомнено';
  }

  @override
  String get vocabularySearchWordsHint => 'Искать слова...';

  @override
  String get vocabularyWordsNoneFound => 'Слова не найдены';

  @override
  String get vocabularyCustomTag => 'Кастомное';

  @override
  String get vocabularyListenTooltip => 'Прослушать';

  @override
  String get vocabularyDetailTranslation => 'Перевод:';

  @override
  String get vocabularyDetailExample => 'Предложение-пример:';

  @override
  String get vocabularyDetailCorrect => 'Верно:';

  @override
  String get vocabularyDetailIncorrect => 'Неверно:';

  @override
  String get vocabularyDetailLevel => 'Уровень:';

  @override
  String get addWordTitle => 'Добавить новое слово';

  @override
  String get addWordChechenLabel => 'Слово на чеченском (обязательно)';

  @override
  String get addWordRussianLabel => 'Перевод (обязательно)';

  @override
  String get addWordEnglishLabel => 'Перевод (English)';

  @override
  String get addWordFrenchLabel => 'Перевод (Français)';

  @override
  String get addWordGermanLabel => 'Перевод (Deutsch)';

  @override
  String get addWordCategoryLabel => 'Категория';

  @override
  String get addWordExampleLabel => 'Предложение-пример';

  @override
  String get addWordExampleTranslationLabel => 'Перевод примера';

  @override
  String get addWordEmptyError => 'Это поле не может быть пустым';

  @override
  String get addWordImageLoading => 'Загрузка...';

  @override
  String get addWordImageImport => 'Импортировать изображение';

  @override
  String get addWordImageChange => 'Заменить изображение';

  @override
  String get addWordCreateAudioTooltip => 'Создать озвучку';

  @override
  String get addWordSnackbarSuccess => 'Слово добавлено';

  @override
  String get addWordSnackbarAudioError => 'Ошибка генерации аудио';

  @override
  String get addWordTurkishLabel => 'Перевод (Türkçe)';

  @override
  String get addWordArabicLabel => 'Перевод (العربية)';

  @override
  String get addWordChechenLatinLabel => 'Слово на чеченском (Латиница)';

  @override
  String get editWordTurkishLabel => 'Перевод (Türkçe)';

  @override
  String get editWordArabicLabel => 'Перевод (العربية)';

  @override
  String get editWordChechenLabel => 'Слово на чеченском';

  @override
  String get editWordTranslationLabel => 'Перевод';

  @override
  String get editWordExampleLabel => 'Предложение-пример на чеченском';

  @override
  String get editWordExampleTranslationLabel => 'Предложение-пример в переводе';

  @override
  String get editWordSnackbarSuccess => 'Слово обновлено';

  @override
  String get editWordChechenLatinLabel => 'Слово на чеченском (Латиница)';

  @override
  String get learningSessionComplete => 'Сессия завершена!';

  @override
  String get learningBackToMenu => 'Обратно в меню';

  @override
  String learningProgressWords(Object completed, Object total) {
    return 'Слов $completed из $total';
  }

  @override
  String learningProgressMemorized(Object count) {
    return '$count слов пройдено';
  }

  @override
  String get learningModeBrowse => 'Режим просмотра всех слов';

  @override
  String learningReviewRepeat(Object count) {
    return '$count повтор';
  }

  @override
  String get learningCustomWord => 'Свои слова';

  @override
  String get learningTypeHint => 'Напечатайте перевод...';

  @override
  String get learningCorrect => 'Правильно!';

  @override
  String learningIncorrect(Object answer) {
    return 'Правильный ответ: $answer';
  }

  @override
  String get learningPrevious => 'Предыдущее';

  @override
  String get learningNext => 'Следующее';

  @override
  String get learningAlreadyKnown => 'Уже известно';

  @override
  String get learningStartLearning => 'Начать учить';

  @override
  String get learningContinue => 'Продолжить';

  @override
  String get learningCheck => 'Проверить';

  @override
  String get learningRemembered => 'Вспомнил';

  @override
  String get learningForgot => 'Не вспомнил';

  @override
  String get learningShowLater => 'Показать позже';

  @override
  String get learningResetProgress => 'Сбросить прогрес';

  @override
  String get learningDeleteWord => 'Удалить слово';

  @override
  String get learningSnackbarReset => 'Прогресс для этого слова сброшен';

  @override
  String get learningDeleteDialogTitle => 'Удалить слово?';

  @override
  String learningDeleteDialogContent(Object word) {
    return 'Ты уверен, что хочешь удалить \"$word\"?';
  }

  @override
  String get learningSnackbarDeleted => 'Слово удалено';

  @override
  String learningUseHint(Object count) {
    return 'Подсказка (ост. $count)';
  }

  @override
  String learningAttemptsRemaining(Object count) {
    return 'Осталось попыток: $count';
  }

  @override
  String learningIncorrectAttemptsLeft(Object count) {
    return 'Неверно. Попыток осталось: $count';
  }

  @override
  String get learnMenuTitle => 'Учить';

  @override
  String get learnMenuAllCategories => 'Все категории';

  @override
  String get learnMenuNoCategories => 'Нет категорий';

  @override
  String learnMenuCategoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count категории',
      many: '$count категорий',
      few: '$count категории',
      one: '$count категория',
    );
    return '$_temp0';
  }

  @override
  String get learnMenuLearnNew => 'Заучивание новых слов';

  @override
  String learnMenuWordsAvailable(Object count) {
    return '$count доступно слов';
  }

  @override
  String get learnMenuReview => 'Повтор слов';

  @override
  String get learnMenuBrowse => 'Просмотр всех слов';

  @override
  String get learnMenuStatsTitle => 'Статистика';

  @override
  String get learnMenuCurrentStreak => 'Текущий рекорд';

  @override
  String learnMenuStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get learnMenuBestStreak => 'Лучший рекорд';

  @override
  String get learnMenuLearnedToday => 'Заучено сегодня';

  @override
  String learnMenuTodayProgress(Object learned, Object limit) {
    return '$learned из $limit';
  }

  @override
  String get learnMenuPeriod7Days => '7 дней';

  @override
  String get learnMenuPeriod30Days => '30 дней';

  @override
  String get learnMenuPeriod90Days => '90 дней';

  @override
  String get learnMenuPeriodAllTime => 'За все время';

  @override
  String learnMenuLearningNow(Object count) {
    return 'Заучивается сейчас: $count новых слов';
  }

  @override
  String get learnMenuStatNewWords => 'Заучено новых слов';

  @override
  String get learnMenuStatReviewed => 'Повторено';

  @override
  String get learnMenuStatMastered => 'Запомнено';

  @override
  String get learnMenuStatKnown => 'Уже было известно';

  @override
  String get learnMenuGoalTitle => 'Дневная цель достигнута!';

  @override
  String learnMenuGoalContentNew(Object count) {
    return 'Вы выучили $count новых слов сегодня!';
  }

  @override
  String learnMenuGoalContentReview(Object count) {
    return 'Вы повторили $count слов сегодня!';
  }

  @override
  String get learnMenuGoalContinue => 'Учить еще';

  @override
  String get learnMenuGoalReview => 'Повтор слов';

  @override
  String get learnMenuGoalBackToMenu => 'Обратно в главное меню';

  @override
  String get learnMenuStatsPageTitle => 'Статистика';

  @override
  String get learnMenuStatsComingSoon => 'Детальную статистику добавят позже';

  @override
  String get ttsTitle => 'Озвучка';

  @override
  String get ttsTooltipHideKeyboard => 'Скрыть клавиатуру';

  @override
  String get ttsTooltipClear => 'Очистить';

  @override
  String get ttsErrorGenerate => 'Ошибка генерации озвучки. Попробуйте снова.';

  @override
  String get ttsErrorPlay => 'Возникла ошибка при проигрывании аудио файла.';

  @override
  String get ttsErrorFile => 'Ошибка генерации файла. Попробуйте снова.';

  @override
  String get ttsShareText => 'Аудио файл';

  @override
  String get ttsSaveDialogTitle => 'Сохранить аудио файл';

  @override
  String ttsSnackbarSaveSuccess(Object path) {
    return 'Файл сохранен: $path';
  }

  @override
  String ttsErrorSave(Object error) {
    return 'Возникла ошибка при сохранении файла: $error';
  }

  @override
  String get ttsButtonListen => 'Прослушать';

  @override
  String get ttsButtonDownload => 'Скачать';

  @override
  String get ttsInstructionsTitle => 'Инструкция';

  @override
  String get ttsInstructionsContent =>
      'Это страница для озвучки любого чеченского текста. Текст озвучивает компьютерная модель, поэтому произношение порой может быть некорректным. Лучший способ ввода текста это зайти в Google Переводчик, перевести текст с другого языка, например русского, на чеченский и этот чеченский текст скопировать и вставить сюда. Числа написанные в виде цифр модель не читает, только написанные словами.';

  @override
  String get ttsChechenTextLabel => 'Текст на чеченском';

  @override
  String get ttsHint => 'Напечатайте или вставьте текст сюда...';

  @override
  String get settingsPageTitle => 'Настройки';

  @override
  String get settingsDarkTheme => 'Темная Тема';

  @override
  String get settingsContentTranslationLanguage => 'Язык перевода';

  @override
  String get settingsUiLanguage => 'Язык приложения';

  @override
  String get settingsLearnWordsPerDay => 'Учить слов в день';

  @override
  String settingsTodayLearned(Object learned, Object limit) {
    return 'Сегодня: $learned/$limit';
  }

  @override
  String get settingsReviewWordsPerDay => 'Повторять слов в день';

  @override
  String settingsTodayReviewed(Object limit, Object reviewed) {
    return 'Сегодня: $reviewed/$limit';
  }

  @override
  String get settingsResetProgressTitle => 'Сбросить прогресс';

  @override
  String get settingsResetProgressSubtitle => 'Сбросить весь прогресс изучения';

  @override
  String get settingsResetDialogTitle => 'Сбросить прогресс?';

  @override
  String get settingsResetDialogContent =>
      'Вы уверены? Это удалит ВЕСЬ ваш прогресс. Это нельзя отменить.';

  @override
  String get settingsResetDialogCancel => 'Отменить';

  @override
  String get settingsResetDialogConfirm => 'Сбросить';

  @override
  String get settingsResetSnackbarInProgress => 'Сброс...';

  @override
  String get settingsResetSnackbarSuccess => 'Сброс прошел успешно';

  @override
  String settingsResetSnackbarError(Object error) {
    return 'Ошибка сброса: $error';
  }

  @override
  String get settingsAboutTitle => 'О приложении';

  @override
  String get settingsAboutSubtitle => 'Версия 1.0.0';

  @override
  String get settingsAlphabetTitle => 'Алфавит';

  @override
  String get settingsAlphabetSubtitleCyrillic => 'Кириллица (Нохчийн)';

  @override
  String get settingsAlphabetSubtitleLatin => 'Латиница (Noxçiyn)';

  @override
  String get settingsBackupTitle => 'Облачное резервное копирование';

  @override
  String settingsBackupSignedInAs(Object email) {
    return 'Вы вошли как $email';
  }

  @override
  String get settingsBackupSignInPrompt => 'Войдите, чтобы сохранить прогресс';

  @override
  String get settingsBackupSignInButton => 'Войти через Google';

  @override
  String get settingsBackupInProgress => 'Создание резервной копии...';

  @override
  String get settingsBackupSuccess => 'Резервная копия создана!';

  @override
  String settingsBackupFailure(Object error) {
    return 'Ошибка копирования: $error';
  }

  @override
  String get settingsBackupButton => 'Создать копию';

  @override
  String get settingsRestoreTitle => 'Восстановить?';

  @override
  String get settingsRestoreContent =>
      'Это ПЕРЕЗАПИШЕТ ваш текущий прогресс версией из облака. Вы уверены?';

  @override
  String get settingsRestoreButton => 'Восстановить';

  @override
  String get settingsRestoreInProgress => 'Восстановление...';

  @override
  String get settingsRestoreSuccess => 'Восстановление успешно!';

  @override
  String settingsRestoreFailure(Object error) {
    return 'Ошибка восстановления: $error';
  }

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsCopyLetterTitle => 'Скопировать букву \'Ӏ\'';

  @override
  String get settingsCopyLetterSubtitle =>
      'Нажмите, чтобы скопировать букву \'Ӏ\'';

  @override
  String get settingsCopyLetterSuccess => 'Буква \'Ӏ\' скопирована!';

  @override
  String get settingsAboutAuthor =>
      'Разработчик: Эльмарзер Ислам (Ислам Эльмурзаев)';

  @override
  String get settingsAboutImages => 'Поиск изображений работает через Pixabay';

  @override
  String get settingsAboutTts => 'Модель озвучки: mms-tts-che';
}
