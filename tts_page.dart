// lib/screens/tts_page.dart
// (Or tts_page.dart, whichever file you are using for "Озвучка")

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import '../services/tts_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart'; // <-- 1. IMPORT

class TtsPage extends StatefulWidget {
  const TtsPage({Key? key}) : super(key: key);

  @override
  State<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  // ADD: Key for persistent storage
  static const String _textKey = 'tts_text_content';

  final TextEditingController _sourceController = TextEditingController();
  final TtsService _ttsService = TtsService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;

  bool _isListening = false;
  bool _isSaving = false;

  final FocusNode _sourceFocusNode = FocusNode();
  bool _isKeyboardVisible = false;

  SharedPreferences? _prefs;
  bool _showInstructions = true;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _sourceFocusNode.addListener(_onFocusChange);
    // RENAME: Call the new general state loader
    _loadState();
  }

  // MODIFIED: Function now loads both text and instructions
  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();

    // 1. Load saved text and set the controller value
    final savedText = _prefs?.getString(_textKey) ?? '';
    _sourceController.text = savedText;

    // 2. Load instructions
    setState(() {
      _showInstructions = _prefs?.getBool('showTtsInstructions') ?? true;
      _prefsLoaded = true;
    });
  }

  // ADD: Helper function to save text
  void _saveText(String text) {
    // Use fire and forget for better performance
    _prefs?.setString(_textKey, text);
  }

  Future<void> _toggleInstructions() async {
    setState(() {
      _showInstructions = !_showInstructions;
    });
    await _prefs?.setBool('showTtsInstructions', _showInstructions);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _sourceFocusNode.removeListener(_onFocusChange);
    _sourceFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _sourceFocusNode.hasFocus;
    });
  }

  // 2. PASS LOC TO METHODS THAT NEED IT
  Future<void> _listenToAudio(AppLocalizations loc) async {
    if (_sourceController.text.trim().isEmpty || _isListening || _isSaving) {
      return;
    }
    _sourceFocusNode.unfocus();

    setState(() {
      _isListening = true;
    });

    try {
      final filePath =
          await _ttsService.getTtsAudio(_sourceController.text.trim());

      if (filePath != null && mounted) {
        await _playerCompleteSubscription?.cancel();
        await _audioPlayer.play(DeviceFileSource(filePath));

        _playerCompleteSubscription = _audioPlayer.onPlayerStateChanged.listen(
          (state) {
            if (state == PlayerState.completed) {
              print('Playback complete. Deleting file: $filePath');
              try {
                final file = File(filePath);
                if (file.existsSync()) {
                  file.delete();
                  print('Temporary file deleted.');
                }
              } catch (e) {
                print('Error deleting file: $e');
              }
              if (mounted) {
                setState(() {
                  _isListening = false;
                });
              }
              _playerCompleteSubscription?.cancel();
            }
          },
          onError: (e) {
            print('Player error: $e');
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          },
        );
      } else if (mounted) {
        _showErrorSnackBar(loc.ttsErrorGenerate); // <-- 3. USE IT
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      print('Ошибка воспроизведения аудио: $e');
      if (mounted) {
        _showErrorSnackBar(loc.ttsErrorPlay); // <-- 4. USE IT
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  /// It now accepts a BuildContext to find the button's position.
  Future<void> _extractAudio(BuildContext context) async {
    // 5. GET LOC FROM CONTEXT
    final loc = AppLocalizations.of(context)!;

    if (_sourceController.text.trim().isEmpty || _isListening || _isSaving) {
      return;
    }
    _sourceFocusNode.unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final audioBytes =
          await _ttsService.getTtsAudioBytes(_sourceController.text.trim());

      if (audioBytes == null) {
        if (mounted) {
          _showErrorSnackBar(loc.ttsErrorFile); // <-- 6. USE IT
        }
        return;
      }

      // Get the RenderBox from the context to find the button's position
      final box = context.findRenderObject() as RenderBox?;
      final Rect shareRect;
      if (box != null) {
        final size = box.size;
        final position = box.localToGlobal(Offset.zero);
        shareRect =
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      } else {
        // Fallback if the button's context can't be found
        shareRect = Rect.fromLTWH(0, 0, 10, 10);
      }

      if (Platform.isIOS || Platform.isAndroid) {
        // --- MOBILE LOGIC (iOS / Android) ---
        final tempDir = await getTemporaryDirectory();

        // --- 1. MODIFIED: Changed .wav to .mp3 ---
        final filePath = '${tempDir.path}/chechen_tts.mp3';
        final file = File(filePath);
        await file.writeAsBytes(audioBytes);

        // --- 2. MODIFIED: Changed mimeType to 'audio/mpeg' ---
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'audio/mpeg')],
          text: loc.ttsShareText, // <-- 7. USE IT
          sharePositionOrigin: shareRect,
        );
      } else {
        // --- DESKTOP LOGIC (Mac / Windows / Linux) ---

        // --- 3. MODIFIED: Changed .wav to .mp3 ---
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: loc.ttsSaveDialogTitle, // <-- 8. USE IT
          fileName: 'chechen_tts.mp3',
          type: FileType.custom,
          allowedExtensions: ['mp3'],
        );

        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsBytes(audioBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(loc.ttsSnackbarSaveSuccess(outputPath)), // <-- 9. USE IT
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Ошибка сохранения аудио: $e');
      if (mounted) {
        _showErrorSnackBar(loc.ttsErrorSave(e.toString())); // <-- 10. USE IT
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).indicatorColor,
      ),
    );
  }

  void _clearAll() {
    _sourceFocusNode.unfocus();
    setState(() {
      _sourceController.clear();
    });
    // ADD: Clear the saved text from storage
    _saveText('');
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _isListening || _isSaving;
    final loc = AppLocalizations.of(context)!; // <-- 11. GET LOC

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.ttsTitle), // <-- 12. USE IT
        centerTitle: true,
        actions: [
          if (_isKeyboardVisible)
            IconButton(
              icon: const Icon(Icons.keyboard_hide_outlined),
              onPressed: () {
                _sourceFocusNode.unfocus();
              },
              tooltip: loc.ttsTooltipHideKeyboard, // <-- 13. USE IT
            ),
          if (_sourceController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAll,
              tooltip: loc.ttsTooltipClear, // <-- 14. USE IT
            ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_isKeyboardVisible) {
              _sourceFocusNode.unfocus();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!_prefsLoaded)
                  const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _buildInstructionCard(context, loc), // <-- 15. PASS LOC
                const SizedBox(height: 16),
                _buildInputSection(context, loc), // <-- 16. PASS LOC
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _listenToAudio(loc), // <-- 17. PASS LOC
                    style: Theme.of(context).elevatedButtonTheme.style,
                    icon: _isListening
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style
                                  ?.foregroundColor
                                  ?.resolve({}),
                            ),
                          )
                        : const Icon(Icons.volume_up),
                    label: Text(
                      loc.ttsButtonListen, // <-- 18. USE IT
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
                  child: Builder(builder: (BuildContext buttonContext) {
                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _extractAudio(buttonContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _isSaving
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : Icon(Icons.download,
                              color: Theme.of(context).primaryColor),
                      label: Text(
                        loc.ttsButtonDownload, // <-- 19. USE IT
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 20. ACCEPT LOC
  Widget _buildInstructionCard(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
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
          GestureDetector(
            onTap: _toggleInstructions,
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.ttsInstructionsTitle, // <-- 21. USE IT
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Icon(
                    _showInstructions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _showInstructions,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  loc.ttsInstructionsContent, // <-- 22. USE IT
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 23. ACCEPT LOC
  Widget _buildInputSection(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.ttsChechenTextLabel, // <-- 24. USE IT
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_sourceController.text.length}/2000',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: TextField(
              controller: _sourceController,
              focusNode: _sourceFocusNode,
              maxLength: 2000,
              maxLines: null,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: loc.ttsHint, // <-- 25. USE IT
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                // MODIFIED: Save the text on every change
                _saveText(value);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}