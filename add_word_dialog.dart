// lib/widgets/add_word_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';
import '../providers/translation_provider.dart'; 
import '../screens/image_search_dialog.dart';
import '../services/tts_service.dart';

/// A reusable function to show the add dialog.
Future<void> showAddWordDialog(
  BuildContext context, {
  String? initialCategory,
  String? initialChechen,
  String? initialChechenLatin,
  String? initialRussian,
  String? initialEnglish,
  String? initialFrench,
  String? initialGerman,
  String? initialTurkish,
  String? initialArabic,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddWordDialog(
      initialCategory: initialCategory,
      initialChechen: initialChechen,
      initialChechenLatin: initialChechenLatin,
      initialRussian: initialRussian,
      initialEnglish: initialEnglish,
      initialFrench: initialFrench,
      initialGerman: initialGerman,
      initialTurkish: initialTurkish,
      initialArabic: initialArabic,
    ),
  );
}

class AddWordDialog extends StatefulWidget {
  final String? initialCategory;
  final String? initialChechen;
  final String? initialChechenLatin;
  final String? initialRussian;
  final String? initialEnglish;
  final String? initialFrench;
  final String? initialGerman;
  final String? initialTurkish;
  final String? initialArabic;

  const AddWordDialog({
    Key? key,
    this.initialCategory,
    this.initialChechen,
    this.initialChechenLatin,
    this.initialRussian,
    this.initialEnglish,
    this.initialFrench,
    this.initialGerman,
    this.initialTurkish,
    this.initialArabic,
  }) : super(key: key);

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _chechenController;
  late TextEditingController _chechenLatinController;
  late TextEditingController _russianController;
  late TextEditingController _englishController;
  late TextEditingController _frenchController;
  late TextEditingController _germanController;
  late TextEditingController _turkishController;
  late TextEditingController _arabicController;
  late TextEditingController _categoryController;
  late TextEditingController _exampleController;
  late TextEditingController _exampleTranslationController;

  final TtsService _ttsService = TtsService();
  String? _generatedWordAudioPath;
  String? _generatedExampleAudioPath;
  bool _isGeneratingWordAudio = false;
  bool _isGeneratingExampleAudio = false;

  String? _generatedImagePath;
  bool _isImportingImage = false;

  // --- STATE FOR TOGGLING LANGUAGES ---
  bool _showOtherLanguages = false;

  @override
  void initState() {
    super.initState();
    _chechenController = TextEditingController(text: widget.initialChechen ?? '');
    _chechenLatinController =
        TextEditingController(text: widget.initialChechenLatin ?? '');
    _russianController = TextEditingController(text: widget.initialRussian ?? '');
    _englishController = TextEditingController(text: widget.initialEnglish ?? '');
    _frenchController = TextEditingController(text: widget.initialFrench ?? '');
    _germanController = TextEditingController(text: widget.initialGerman ?? '');
    _turkishController = TextEditingController(text: widget.initialTurkish ?? '');
    _arabicController = TextEditingController(text: widget.initialArabic ?? '');
    _categoryController =
        TextEditingController(text: widget.initialCategory ?? 'General');
    _exampleController = TextEditingController();
    _exampleTranslationController = TextEditingController();
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
    _categoryController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  Future<void> _generateWordAudio() async {
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
        final loc = AppLocalizations.of(context)!;
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
    if (_exampleController.text.trim().isEmpty) return;
    setState(() {
      _isGeneratingExampleAudio = true;
      _generatedExampleAudioPath = null;
    });
    try {
      final textToGenerate = _exampleController.text.trim();
      final path =
          await _ttsService.generateAndSaveTtsAudio(textToGenerate, 'example');
      if (mounted) {
        setState(() {
          _generatedExampleAudioPath = path;
        });
      }
    } catch (e) {
      print('Error generating example audio: $e');
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
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

  Future<void> _importImage() async {
    setState(() {
      _isImportingImage = true;
    });

    final String? path = await showDialog<String>(
      context: context,
      builder: (_) =>
          ImageSearchDialog(initialSearchTerm: _chechenController.text),
    );

    setState(() {
      if (path != null) {
        _generatedImagePath = path;
      }
      _isImportingImage = false;
    });
  }

  void _saveWord() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WordProvider>();
      final loc = AppLocalizations.of(context)!;
      provider.addWord(
        _chechenController.text.trim(),
        _russianController.text.trim(),
        term_latin: _chechenLatinController.text.trim().isEmpty
            ? null
            : _chechenLatinController.text.trim(),
        english: _englishController.text.trim().isEmpty
            ? null
            : _englishController.text.trim(),
        french: _frenchController.text.trim().isEmpty
            ? null
            : _frenchController.text.trim(),
        german: _germanController.text.trim().isEmpty
            ? null
            : _germanController.text.trim(),
        turkish: _turkishController.text.trim().isEmpty
            ? null
            : _turkishController.text.trim(),
        arabic: _arabicController.text.trim().isEmpty
            ? null
            : _arabicController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        example: _exampleController.text.trim().isEmpty
            ? null
            : _exampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim().isEmpty
            ? null
            : _exampleTranslationController.text.trim(),
        audioUrl: _generatedWordAudioPath,
        exampleAudioUrl: _generatedExampleAudioPath,
        imageUrl: _generatedImagePath,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.addWordSnackbarSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    // --- 1. GET CURRENT TARGET ---
    final translationProvider = context.watch<TranslationProvider>();
    final activeTarget = translationProvider.currentTarget;

    // --- 2. DEFINE EXTRA LANGUAGE FIELDS ---
    Widget englishField = TextFormField(
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

    Widget frenchField = TextFormField(
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

    Widget germanField = TextFormField(
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

    Widget turkishField = TextFormField(
      controller: _turkishController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.addWordTurkishLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    Widget arabicField = TextFormField(
      controller: _arabicController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: loc.addWordArabicLabel,
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );

    // --- 3. SORT INTO VISIBLE AND HIDDEN ---
    Widget? primaryExtraField;
    List<Widget> hiddenLanguageFields = [];

    // Map targets to widgets for easy lookup
    Map<TranslationTarget, Widget> fieldMap = {
      TranslationTarget.english: englishField,
      TranslationTarget.french: frenchField,
      TranslationTarget.german: germanField,
      TranslationTarget.turkish: turkishField,
      TranslationTarget.arabic: arabicField,
    };

    // If target is one of the extras (not Russian, not Chechen), show it
    if (activeTarget != TranslationTarget.russian &&
        fieldMap.containsKey(activeTarget)) {
      primaryExtraField = fieldMap[activeTarget];
    }

    // Add others to hidden list
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
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  loc.addWordTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              ),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _chechenController,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                decoration: InputDecoration(
                                  labelText: loc.addWordChechenLabel,
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).hintColor),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return loc.addWordEmptyError;
                                  }
                                  return null;
                                },
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
                              onPressed: _generateWordAudio,
                              tooltip: loc.addWordCreateAudioTooltip,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _chechenLatinController,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: loc.addWordChechenLatinLabel,
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
                              child: TextFormField(
                                controller: _russianController,
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  labelText: loc.addWordRussianLabel,
                                  labelStyle:
                                      TextStyle(color: Theme.of(context).hintColor),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return loc.addWordEmptyError;
                                  }
                                  return null;
                                },
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

                        TextFormField(
                          controller: _categoryController,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: loc.addWordCategoryLabel,
                            labelStyle:
                                TextStyle(color: Theme.of(context).hintColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _exampleController,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                decoration: InputDecoration(
                                  labelText: loc.addWordExampleLabel,
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).hintColor),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                maxLines: null,
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
                              onPressed: _generateExampleAudio,
                              tooltip: loc.addWordCreateAudioTooltip,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _exampleTranslationController,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: loc.addWordExampleTranslationLabel,
                            labelStyle:
                                TextStyle(color: Theme.of(context).hintColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _generatedImagePath == null
                                ? Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.image_not_supported,
                                        color: Theme.of(context)
                                            .hintColor
                                            .withOpacity(0.5)),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_generatedImagePath!),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isImportingImage ? null : _importImage,
                                icon: _isImportingImage
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_photo_alternate),
                                label: Text(
                                  _isImportingImage
                                      ? loc.addWordImageLoading
                                      : _generatedImagePath == null
                                          ? loc.addWordImageImport
                                          : loc.addWordImageChange,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Theme.of(context)
                                              .brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ),
                    TextButton(
                      onPressed: _saveWord,
                      child: Text(loc.dialogSave,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
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
    required VoidCallback onPressed,
    required String tooltip,
  }) {
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
    if (hasAudio) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.check_circle, color: Colors.green),
      );
    }
    return IconButton(
      icon: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}