import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word_model.dart';
import 'dart:io';
import '../widgets/edit_word_dialog.dart';
import '../providers/translation_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/alphabet_provider.dart';

// Learning Screen
class LearningScreen extends StatelessWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationProvider = context.watch<TranslationProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<WordProvider>().reset();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WordProvider>().reset();
            },
          ),
        ],
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: provider.currentWord == null
                ? Center(
                    key: const ValueKey('__session_complete__'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 80,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(height: 20),
                        Text(
                          loc.learningSessionComplete,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => provider.reset(),
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: Text(
                            loc.learningBackToMenu,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: ValueKey<String>(
                        "${provider.currentWord!.id}_${provider.currentWord!.imageUrl ?? ''}"),
                    children: [
                      _buildProgressBar(context, provider),
                      Expanded(
                        child: _buildWordCard(
                            context, provider, translationProvider),
                      ),
                      _buildActionButtons(
                          context, provider, translationProvider),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, WordProvider provider) {
    final loc = AppLocalizations.of(context)!;

    if (provider.studyMode == StudyMode.browsing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.learningProgressWords(
                  provider.completedInSession + 1, provider.totalInSession),
              style: TextStyle(
                  color: Theme.of(context).hintColor, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: provider.totalInSession > 0
                  ? (provider.completedInSession + 1) / provider.totalInSession
                  : 0,
              backgroundColor: Theme.of(context).disabledColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.learningProgressMemorized(provider.wordsMemorizedInSession),
            style: TextStyle(
                color: Theme.of(context).hintColor, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              provider.totalInSession.clamp(0, 20),
              (index) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: index < provider.wordsMemorizedInSession
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(BuildContext context, WordProvider provider,
      TranslationProvider translationProvider) {
    final word = provider.currentWord!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final loc = AppLocalizations.of(context)!;
    
    final alphabetProvider = context.watch<AlphabetProvider>();

    final correctTranslation = provider.getCorrectTranslation(
        word, translationProvider.currentTarget);

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 20,
        ),
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.studyMode == StudyMode.browsing
                            ? loc.learningModeBrowse
                            : loc.learningReviewRepeat(word.reviewLevel + 1),
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.7)),
                      ),
                      Text(
                        word.category,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.54)),
                  onPressed: () {
                    _showWordOptionsMenu(context, word, provider);
                  },
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              loc.learningCustomWord,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Stack(
              alignment: Alignment.center,
              children: [
                _buildWordImage(context, word.imageUrl),
                if (word.audioUrl != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        provider.playAudio(word.audioUrl);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.volume_up,
                          color: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.foregroundColor
                              ?.resolve({}),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                word.getTerm(alphabetProvider.isCyrillic),
                style: TextStyle(
                  fontSize: screenWidth * 0.11,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (provider.answerMode == AnswerMode.flashcard)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: provider.showTranslation ? null : 0,
                child: provider.showTranslation
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Text(
                              correctTranslation,
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (word.exampleSentence != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor,
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            word.exampleSentence!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (word.exampleAudioUrl != null)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.play_circle_filled,
                                                size: 20),
                                            color: Theme.of(context).primaryColor,
                                            padding: const EdgeInsets.only(
                                                left: 8),
                                            constraints:
                                                const BoxConstraints(),
                                            onPressed: () => provider
                                                .playAudio(
                                                    word.exampleAudioUrl),
                                          ),
                                      ],
                                    ),
                                    if (word.exampleTranslation != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        word.exampleTranslation!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )
            else if (provider.answerMode == AnswerMode.typing)
              _buildTypingMode(
                  context, provider, screenWidth, translationProvider)
            else if (provider.answerMode == AnswerMode.multipleChoice)
              _buildMultipleChoiceMode(
                  context, provider, screenWidth, translationProvider),

            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (word.state != WordState.newWord) ...[
                  _buildIconButton(
                    context,
                    Icons.keyboard,
                    provider.answerMode == AnswerMode.typing,
                    () => provider.setAnswerMode(
                        AnswerMode.typing,
                        translationProvider.currentTarget),
                  ),
                  const SizedBox(width: 20),
                ],
                _buildIconButton(
                  context,
                  provider.showTranslation
                      ? Icons.visibility_off
                      : Icons.visibility,
                  provider.answerMode == AnswerMode.flashcard,
                  () {
                    if (provider.answerMode != AnswerMode.flashcard) {
                      provider.setAnswerMode(AnswerMode.flashcard,
                          translationProvider.currentTarget);
                    } else {
                      provider.toggleTranslation();
                    }
                  },
                ),
                if (word.state != WordState.newWord) ...[
                  const SizedBox(width: 20),
                  _buildIconButton(
                    context,
                    Icons.grid_view,
                    provider.answerMode == AnswerMode.multipleChoice,
                    () => provider.setAnswerMode(AnswerMode.multipleChoice,
                        translationProvider.currentTarget),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingMode(
      BuildContext context,
      WordProvider provider,
      double screenWidth,
      TranslationProvider translationProvider) {
    final loc = AppLocalizations.of(context)!;

    final correctTranslation = provider.getCorrectTranslation(
        provider.currentWord!, translationProvider.currentTarget);
    final isCorrect = provider.checkAnswer(
        provider.userAnswer, translationProvider.currentTarget);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            onChanged: (value) => provider.setUserAnswer(value),
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: provider.userAnswer,
                selection:
                    TextSelection.collapsed(offset: provider.userAnswer.length),
              ),
            ),
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: loc.learningTypeHint,
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              border: InputBorder.none,
              // --- HINT BUTTON (Localized) ---
              suffixIcon: provider.showTranslation
                  ? null 
                  : IconButton(
                      icon: Icon(Icons.lightbulb_outline,
                          color: provider.hintsUsed >= 3
                              ? Theme.of(context).disabledColor
                              : Colors.amber),
                      onPressed: provider.hintsUsed >= 3
                          ? null
                          : () {
                              provider.useHint(translationProvider.currentTarget);
                            },
                      tooltip: loc.learningUseHint(3 - provider.hintsUsed), // Localized
                    ),
            ),
          ),
        ),
        // --- ATTEMPTS INDICATOR (Localized) ---
        if (!provider.showTranslation && provider.attemptsMade > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              loc.learningAttemptsRemaining(3 - provider.attemptsMade), // Localized
              style: TextStyle(
                  color: Theme.of(context).indicatorColor, fontSize: 12),
            ),
          ),
        // ---------------------------------
        if (provider.showTranslation) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Theme.of(context)
                      .indicatorColor
                      .withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isCorrect
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).indicatorColor,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).indicatorColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? loc.learningCorrect
                        : loc.learningIncorrect(correctTranslation),
                    style: TextStyle(
                      color: isCorrect
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).indicatorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultipleChoiceMode(
      BuildContext context,
      WordProvider provider,
      double screenWidth,
      TranslationProvider translationProvider) {
    final correctTranslation = provider.getCorrectTranslation(
        provider.currentWord!, translationProvider.currentTarget);

    return Column(
      children: [
        ...provider.multipleChoiceOptions.map((option) {
          final isSelected = provider.userAnswer == option;
          final isCorrect = option == correctTranslation;
          final showResult = provider.showTranslation;

          Color backgroundColor = Theme.of(context).disabledColor;
          Color? borderColor;

          if (showResult) {
            if (isCorrect) {
              backgroundColor =
                  Theme.of(context).primaryColor.withOpacity(0.2);
              borderColor = Theme.of(context).primaryColor;
            } else if (isSelected && !isCorrect) {
              backgroundColor =
                  Theme.of(context).canvasColor.withOpacity(0.2);
              borderColor = Theme.of(context).canvasColor;
            }
          } else if (isSelected) {
            borderColor = Theme.of(context).canvasColor;
          }

          return GestureDetector(
            onTap: showResult
                ? null
                : () {
                    provider.setUserAnswer(option);
                    provider.toggleTranslation();
                  },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (showResult && isCorrect)
                    Icon(Icons.check_circle,
                        color: Theme.of(context).primaryColor),
                  if (showResult && isSelected && !isCorrect)
                    Icon(Icons.cancel,
                        color: Theme.of(context).canvasColor),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive
              ? Theme.of(context)
                  .elevatedButtonTheme
                  .style
                  ?.foregroundColor
                  ?.resolve({})
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WordProvider provider,
      TranslationProvider translationProvider) {
    final word = provider.currentWord!;
    final loc = AppLocalizations.of(context)!;

    if (provider.studyMode == StudyMode.browsing) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider
                      .previousWord(translationProvider.currentTarget),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: Text(loc.learningPrevious),
                  style: Theme.of(context)
                      .elevatedButtonTheme
                      .style
                      ?.copyWith(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).cardColor),
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider
                      .moveToNextWord(translationProvider.currentTarget),
                  label: Text(loc.learningNext),
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconAlignment: IconAlignment.end,
                  style: Theme.of(context).elevatedButtonTheme.style,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (word.state == WordState.newWord) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => provider.markAsAlreadyKnown(),
                  style: Theme.of(context)
                      .elevatedButtonTheme
                      .style
                      ?.copyWith(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).disabledColor),
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                  child: Text(
                    loc.learningAlreadyKnown,
                    style: TextStyle(
                        fontSize: 17,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.startLearning(),
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text(
                    loc.learningStartLearning,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Logic for "Continue" button (when result is already shown)
    if ((provider.answerMode == AnswerMode.typing ||
            provider.answerMode == AnswerMode.multipleChoice) &&
        provider.showTranslation) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ElevatedButton(
            onPressed: () async {
              if (provider.studyMode == StudyMode.learning) {
                if (provider.checkAnswer(
                    provider.userAnswer, translationProvider.currentTarget)) {
                  await provider.markAsMemorized();
                } else {
                  await provider.needsMorePractice(
                      translationProvider.currentTarget);
                }
              } else {
                if (provider.checkAnswer(
                    provider.userAnswer, translationProvider.currentTarget)) {
                  await provider.markWordCorrect();
                } else {
                  await provider.markWordIncorrect(
                      translationProvider.currentTarget);
                }
              }
            },
            style: Theme.of(context).elevatedButtonTheme.style,
            child: Text(
              loc.learningContinue,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // Logic for "Check" button (only for typing mode when result is NOT shown)
    if (provider.answerMode == AnswerMode.typing &&
        !provider.showTranslation) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ElevatedButton(
            // Disable if input is empty
            onPressed: provider.userAnswer.trim().isEmpty
                ? null
                : () {
                    bool isCorrect = provider.checkAnswer(
                        provider.userAnswer, translationProvider.currentTarget);
                    
                    if (isCorrect) {
                       provider.toggleTranslation(); // Show correct result
                    } else {
                       // Wrong answer
                       if (provider.remainingAttempts > 1) {
                         // Still has attempts left (current attempt failed, so rem - 1)
                         provider.incrementAttempts();
                         
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(
                               loc.learningIncorrectAttemptsLeft(provider.remainingAttempts) // Localized
                             ),
                             backgroundColor: Theme.of(context).indicatorColor,
                             duration: const Duration(milliseconds: 1500),
                           ),
                         );
                       } else {
                         // Last attempt failed
                         provider.incrementAttempts(); // To reach max
                         provider.toggleTranslation(); // Show incorrect result
                       }
                    }
                  },
            style: Theme.of(context)
                .elevatedButtonTheme
                .style
                ?.copyWith(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context).disabledColor;
                    }
                    return Theme.of(context).primaryColor;
                  }),
                  foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context).hintColor;
                    }
                    return Theme.of(context)
                        .elevatedButtonTheme
                        .style
                        ?.foregroundColor
                        ?.resolve(states);
                  }),
                ),
            child: Text(
              loc.learningCheck,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (provider.studyMode == StudyMode.learning) {
                    provider.markAsMemorized();
                  } else {
                    provider.markWordCorrect();
                  }
                },
                style: Theme.of(context)
                    .elevatedButtonTheme
                    .style
                    ?.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).cardColor),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).textTheme.bodyLarge?.color),
                      elevation: MaterialStateProperty.all(4),
                      shadowColor: MaterialStateProperty.all(
                          Theme.of(context).shadowColor),
                    ),
                child: Text(
                  loc.learningRemembered,
                  style: TextStyle(
                      fontSize: 17,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (provider.studyMode == StudyMode.learning) {
                    provider.needsMorePractice(
                        translationProvider.currentTarget);
                  } else {
                    provider.markWordIncorrect(
                        translationProvider.currentTarget);
                  }
                },
                style: Theme.of(context)
                    .elevatedButtonTheme
                    .style
                    ?.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).cardColor),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).textTheme.bodyLarge?.color),
                      elevation: MaterialStateProperty.all(4),
                      shadowColor: MaterialStateProperty.all(
                          Theme.of(context).shadowColor),
                    ),
                child: Text(
                  loc.learningForgot,
                  style: TextStyle(
                      fontSize: 17,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordOptionsMenu(
      BuildContext context, Word word, WordProvider provider) {
    final translationProvider = context.read<TranslationProvider>();
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.blueAccent),
              title: Text(loc.learningShowLater,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color)),
              onTap: () {
                Navigator.pop(context);
                provider.requeueCurrentWordLater(
                    translationProvider.currentTarget);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit,
                  color: Theme.of(context).primaryColor),
              title: Text(loc.dialogEdit,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color)),
              onTap: () {
                Navigator.pop(context);
                showEditWordDialog(context, word);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: Text(loc.learningResetProgress,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color)),
              onTap: () {
                Navigator.pop(context);
                _resetWordProgress(word, provider, context);
              },
            ),
            if (word.isCustom)
              ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).indicatorColor),
                title: Text(loc.learningDeleteWord,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteWordFromLearning(word, provider, context);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _resetWordProgress(
      Word word, WordProvider provider, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    provider.reset();
    word.reviewLevel = 0;
    word.correctCount = 0;
    word.incorrectCount = 0;
    word.isLearned = false;
    word.nextReview = null;
    word.state = WordState.newWord;
    word.markedAsKnown = false;
    provider.saveProgress();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.learningSnackbarReset)),
    );
  }

  void _deleteWordFromLearning(
      Word word, WordProvider provider, BuildContext context) {
    
    final alphabetProvider = context.read<AlphabetProvider>();
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: Theme.of(context).dialogTheme.shape,
        title: Text(loc.learningDeleteDialogTitle,
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          loc.learningDeleteDialogContent(
              word.getTerm(alphabetProvider.isCyrillic)),
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.dialogCancel,
                style:
                    TextStyle(color: Theme.of(context).hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteWord(word.id);
              provider.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.learningSnackbarDeleted)),
              );
            },
            child: Text(loc.dialogDelete,
                style:
                    TextStyle(color: Theme.of(context).indicatorColor)),
          ),
        ],
      ),
    );
  }
}

Widget _buildWordImage(BuildContext context, String? imageUrl) {
  Widget fallbackWidget = Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Icon(
      Icons.book_outlined,
      size: 100,
      color: Theme.of(context).hintColor?.withOpacity(0.5),
    ),
  );

  if (imageUrl == null || imageUrl.isEmpty) {
    return fallbackWidget;
  }

  Widget imageWidget;
  if (imageUrl.startsWith('http')) {
    imageWidget = Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => fallbackWidget,
    );
  } else if (imageUrl.startsWith('assets/')) {
    imageWidget = Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => fallbackWidget,
    );
  } else if (imageUrl.startsWith('/')) {
    imageWidget = Image.file(
      File(imageUrl),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => fallbackWidget,
    );
  } else {
    imageWidget = fallbackWidget;
  }

  return Container(
    width: 200,
    height: 200,
    constraints: const BoxConstraints(
      maxWidth: 200,
      maxHeight: 200,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(30),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: imageWidget,
    ),
  );
}