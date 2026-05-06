// lib/widgets/edit_word_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; 
import '../models/word_model.dart';
import '../providers/word_provider.dart';
import '../providers/translation_provider.dart'; 
import '../screens/image_search_dialog.dart';
import '../services/tts_service.dart';

/// A reusable function to show the edit dialog.
Future<void> showEditWordDialog(BuildContext context, Word word) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditWordDialog(word: word),
  );
}

class EditWordDialog extends StatefulWidget {
  final Word word;
  const EditWordDialog({Key? key, required this.word}) : super(key: key);

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late final TextEditingController _chechenController;
  late final TextEditingController _chechenLatinController;
  late final TextEditingController _russianController;
  late final TextEditingController _englishController;
  late final TextEditingController _frenchController;
  late final TextEditingController _germanController;
  late final TextEditingController _turkishController;
  late final TextEditingController _arabicController;
  late final TextEditingController _exampleController;
  late final TextEditingController _exampleTranslationController;
  String? _currentImageUrl;

  final TtsService _ttsService = TtsService();
  String? _generatedWordAudioPath;
  String? _generatedExampleAudioPath;
  bool _isGeneratingWordAudio = false;
  bool _isGeneratingExampleAudio = false;

  // --- STATE FOR TOGGLING LANGUAGES ---
  bool _showOtherLanguages = false;

  @override
  void initState() {
    super.initState();
    _chechenController = TextEditingController(text: widget.word.chechen);
    _chechenLatinController =
        TextEditingController(text: widget.word.term_latin ?? '');
    _russianController = TextEditingController(text: widget.word.russian);
    _englishController =
        TextEditingController(text: widget.word.english ?? '');
    _frenchController =
        TextEditingController(text: widget.word.french ?? '');
    _germanController =
        TextEditingController(text: widget.word.german ?? '');
    _turkishController =
        TextEditingController(text: widget.word.turkish ?? '');
    _arabicController =
        TextEditingController(text: widget.word.arabic ?? '');
    _exampleController =
        TextEditingController(text: widget.word.exampleSentence ?? '');
    _exampleTranslationController =
        TextEditingController(text: widget.word.exampleTranslation ?? '');

    _currentImageUrl = widget.word.imageUrl;
    _generatedWordAudioPath = widget.word.audioUrl;
    _generatedExampleAudioPath = widget.word.exampleAudioUrl;
  }

  @override
  void dispose() {
    _chechenController.dispose();
    _chechenLatinController.dispose();
    _russianController.dispose();
    _englishController.dispose();
    _frenchController.dispose();
    _germanController.dispose();
    _turkishController.dispose();
    _arabicController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  Widget _buildWordImage(String? imageUrl, {double size = 80.0}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_not_supported,
            color: Theme.of(context).hintColor.withOpacity(0.5),
            size: size / 2),
      );
    }

    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else if (imageUrl.startsWith('/')) {
      imageWidget = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(Icons.error,
            color: Theme.of(context).indicatorColor, size: size / 2),
      );
    } else {
      imageWidget =
          Icon(Icons.help, color: Theme.of(context).hintColor, size: size / 2);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );
  }

  Future<void> _importImage() async {
    final loc = AppLocalizations.of(context)!;
    final String? path = await showDialog<String>(
      context: context,
      builder: (_) =>
          ImageSearchDialog(initialSearchTerm: _chechenController.text),
    );
    if (path != null) {
      setState(() {
        _currentImageUrl = path;
      });
    }
  }

  Future<void> _generateWordAudio() async {
    final loc = AppLocalizations.of(context)!;
    if (_chechenController.text.trim().isEmpty) return;
    setState(() {
      _isGeneratingWordAudio = true;
      _generatedWordAudioPath = null;
    });
    try {
      final textToGenerate =
          "Доьшуш долу дош: ${_chechenController.text.trim()}";
      final path =
          await _ttsService.generateAndSaveTtsAudio(textToGenerate, 'word');
      if (mounted) {
        setState(() {
          _generatedWordAudioPath = path;
        });
      }
    } catch (e) {
      print('Error generating word audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.addWordSnackbarAudioError),
              backgroundColor: Theme.of(context).indicatorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingWordAudio = false;
        });
      }
    }
  }

  Future<void> _generateExampleAudio() async {
    final loc = AppLocalizations.of(context)!;
    if (_exampleController.text.trim().isEmpty) return;
    setState(() {
      _isGeneratingExampleAudio = true;
      _generatedExampleAudioPath = null;
    });
    try {
      final textToGenerate = _exampleController.text.trim();
      final path = await _ttsService.generateAndSaveTtsAudio(
          textToGenerate, 'example');
      if (mounted) {
        setState(() {
          _generatedExampleAudioPath = path;
        });
      }
    } catch (e) {
      print('Error generating example audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.addWordSnackbarAudioError),
              backgroundColor: Theme.of(context).indicatorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingExampleAudio = false;
        });
      }
    }
  }

  void _saveWord() {
    final loc = AppLocalizations.of(context)!;
    context.read<WordProvider>().editWord(
          widget.word.id,
          _chechenController.text,
          _russianController.text,
          term_latin: _chechenLatinController.text.isEmpty
              ? null
              : _chechenLatinController.text,
          english: _englishController.text.isEmpty
              ? null
              : _englishController.text,
          french: _frenchController.text.isEmpty
              ? null
              : _frenchController.text,
          german: _germanController.text.isEmpty
              ? null
              : _germanController.text,
          turkish: _turkishController.text.isEmpty
              ? null
              : _turkishController.text,
          arabic: _arabicController.text.isEmpty
              ? null
              : _arabicController.text,
          example: _exampleController.text.isEmpty
              ? null
              : _exampleController.text,
          exampleTranslation: _exampleTranslationController.text.isEmpty
              ? null
              : _exampleTranslationController.text,
          audioUrl: _generatedWordAudioPath,
          exampleAudioUrl: _generatedExampleAudioPath,
          imageUrl: _currentImageUrl,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.editWordSnackbarSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // --- 1. GET CURRENT TARGET ---
    final translationProvider = context.watch<TranslationProvider>();
    final activeTarget = translationProvider.currentTarget;

    // --- 2. DEFINE EXTRA LANGUAGE FIELDS ---
    Widget englishField = TextField(
      controller: _englishController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.addWordEnglishLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    Widget frenchField = TextField(
      controller: _frenchController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.addWordFrenchLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    Widget germanField = TextField(
      controller: _germanController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.addWordGermanLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    Widget turkishField = TextField(
      controller: _turkishController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.editWordTurkishLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    Widget arabicField = TextField(
      controller: _arabicController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.editWordArabicLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    // --- 3. SORT INTO VISIBLE AND HIDDEN ---
    Widget? primaryExtraField;
    List<Widget> hiddenLanguageFields = [];

    Map<TranslationTarget, Widget> fieldMap = {
      TranslationTarget.english: englishField,
      TranslationTarget.french: frenchField,
      TranslationTarget.german: germanField,
      TranslationTarget.turkish: turkishField,
      TranslationTarget.arabic: arabicField,
    };

    if (activeTarget != TranslationTarget.russian &&
        fieldMap.containsKey(activeTarget)) {
      primaryExtraField = fieldMap[activeTarget];
    }

    fieldMap.forEach((target, widget) {
      if (target != activeTarget) {
        hiddenLanguageFields.add(widget);
        hiddenLanguageFields.add(const SizedBox(height: 16));
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  loc.dialogEdit,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: _buildWordImage(_currentImageUrl, size: 100),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: Icon(Icons.image_search,
                            color: Theme.of(context).primaryColor),
                        label: Text(
                          _currentImageUrl == null
                              ? loc.addWordImageImport
                              : loc.addWordImageChange,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        onPressed: _importImage,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chechenController,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                              decoration: InputDecoration(
                                labelText: loc.editWordChechenLabel,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).hintColor),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              onChanged: (value) {
                                if (_generatedWordAudioPath != null) {
                                  setState(() {
                                    _generatedWordAudioPath = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildAudioButton(
                            isLoading: _isGeneratingWordAudio,
                            hasAudio: _generatedWordAudioPath != null,
                            audioPath: _generatedWordAudioPath,
                            onPressed: _generateWordAudio,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _chechenLatinController,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: loc.editWordChechenLatinLabel,
                          labelStyle:
                              TextStyle(color: Theme.of(context).hintColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- RUSSIAN FIELD WITH ARROW ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _russianController,
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: loc.editWordTranslationLabel,
                                labelStyle:
                                    TextStyle(color: Theme.of(context).hintColor),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _showOtherLanguages
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _showOtherLanguages = !_showOtherLanguages;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- DISPLAY PRIMARY EXTRA (TARGET) IF ANY ---
                      if (primaryExtraField != null) ...[
                        primaryExtraField,
                        const SizedBox(height: 16),
                      ],

                      // --- HIDDEN FIELDS ---
                      if (_showOtherLanguages) ...hiddenLanguageFields,

                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _exampleController,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                              decoration: InputDecoration(
                                labelText: loc.editWordExampleLabel,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).hintColor),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                if (_generatedExampleAudioPath != null) {
                                  setState(() {
                                    _generatedExampleAudioPath = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildAudioButton(
                            isLoading: _isGeneratingExampleAudio,
                            hasAudio: _generatedExampleAudioPath != null,
                            audioPath: _generatedExampleAudioPath,
                            onPressed: _generateExampleAudio,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _exampleTranslationController,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: loc.editWordExampleTranslationLabel,
                          labelStyle:
                              TextStyle(color: Theme.of(context).hintColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Theme.of(context).hintColor.withOpacity(0.2)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.dialogCancel,
                          style:
                              TextStyle(color: Theme.of(context).hintColor)),
                    ),
                    TextButton(
                      onPressed: _saveWord, // Call our local save function
                      child: Text(loc.dialogSave,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioButton({
    required bool isLoading,
    required bool hasAudio,
    required String? audioPath, // Pass the actual path string
    required VoidCallback onPressed,
  }) {
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    // Show checkmark ONLY if it's a newly generated file (local path)
    final bool isNewlyGenerated =
        hasAudio && (audioPath?.startsWith('/') ?? false);

    if (isNewlyGenerated) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.check_circle, color: Colors.green),
      );
    }

    // Otherwise, always show the button to generate or re-generate
    return IconButton(
      icon: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
      tooltip: loc.addWordCreateAudioTooltip, // Use loc string
      onPressed: onPressed,
    );
  }
}