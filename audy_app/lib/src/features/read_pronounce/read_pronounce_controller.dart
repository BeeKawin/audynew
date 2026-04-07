import 'package:flutter/material.dart';

enum ReadPronounceModule { letters, words, sentences }

class ReadPronounceModuleState {
  final String prompt;
  final int progressCurrent;
  final int progressTotal;
  final String lastAttempt;
  final String feedback;

  const ReadPronounceModuleState({
    required this.prompt,
    required this.progressCurrent,
    required this.progressTotal,
    this.lastAttempt = '',
    this.feedback = 'Tap Listen, then say it clearly.',
  });

  ReadPronounceModuleState copyWith({
    String? prompt,
    int? progressCurrent,
    int? progressTotal,
    String? lastAttempt,
    String? feedback,
  }) {
    return ReadPronounceModuleState(
      prompt: prompt ?? this.prompt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      feedback: feedback ?? this.feedback,
    );
  }
}

class ReadPronounceSessionResult {
  final ReadPronounceModule module;
  final int totalAttempts;
  final int correctAttempts;
  final int sessionDurationMs;
  final DateTime completedAt;

  const ReadPronounceSessionResult({
    required this.module,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.sessionDurationMs,
    required this.completedAt,
  });

  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAttempts / totalAttempts;
  }

  int get stars {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.6) return 2;
    return 1;
  }

  int get accuracyPercent => (accuracy * 100).round();
}

class ReadPronounceController extends ChangeNotifier {
  ReadPronounceController() {
    _seedState();
  }

  final Map<ReadPronounceModule, List<String>> _prompts = {};
  final Map<ReadPronounceModule, ReadPronounceModuleState> _moduleStates = {};

  ReadPronounceModule? _activeModule;
  int _currentPromptIndex = 0;
  final List<bool> _sessionResults = [];
  DateTime? _sessionStartTime;
  ReadPronounceSessionResult? _lastSessionResult;
  bool _isSessionComplete = false;

  ReadPronounceModule? get activeModule => _activeModule;
  int get currentPromptIndex => _currentPromptIndex;
  List<bool> get sessionResults => List.unmodifiable(_sessionResults);
  ReadPronounceSessionResult? get lastSessionResult => _lastSessionResult;
  bool get isSessionComplete => _isSessionComplete;

  ReadPronounceModuleState? get currentState {
    if (_activeModule == null) return null;
    return _moduleStates[_activeModule];
  }

  List<String> get currentPrompts {
    if (_activeModule == null) return [];
    return _prompts[_activeModule] ?? [];
  }

  int get totalPrompts => currentPrompts.length;

  void startSession(ReadPronounceModule module) {
    _activeModule = module;
    _currentPromptIndex = 0;
    _sessionResults.clear();
    _sessionStartTime = DateTime.now();
    _isSessionComplete = false;
    _lastSessionResult = null;

    final prompts = _prompts[module]!;
    _moduleStates[module] = ReadPronounceModuleState(
      prompt: prompts[0],
      progressCurrent: 0,
      progressTotal: prompts.length,
    );

    notifyListeners();
  }

  void submitAttempt(String capturedText) {
    final module = _activeModule;
    if (module == null) return;

    final state = _moduleStates[module]!;
    final error = validatePracticeInput(capturedText);
    if (error != null) {
      _moduleStates[module] = state.copyWith(feedback: error);
      notifyListeners();
      return;
    }

    final normalizedAttempt = _normalizeText(capturedText);
    final normalizedPrompt = _normalizeText(state.prompt);
    final isCorrect = normalizedAttempt == normalizedPrompt;

    _sessionResults.add(isCorrect);

    var nextPrompt = state.prompt;
    if (isCorrect) {
      final currentIndex = _currentPromptIndex;
      if (currentIndex + 1 < totalPrompts) {
        _currentPromptIndex = currentIndex + 1;
        nextPrompt = currentPrompts[_currentPromptIndex];
      }
    }

    _moduleStates[module] = state.copyWith(
      prompt: nextPrompt,
      progressCurrent: _currentPromptIndex + 1,
      lastAttempt: capturedText,
      feedback: isCorrect
          ? 'Nice speaking practice. Keep going.'
          : 'Close. Try matching the prompt more exactly.',
    );

    if (_currentPromptIndex >= totalPrompts - 1 && isCorrect) {
      _completeSession();
    } else if (_currentPromptIndex >= totalPrompts) {
      _completeSession();
    }

    notifyListeners();
  }

  void _completeSession() {
    if (_activeModule == null) return;

    final duration = DateTime.now()
        .difference(_sessionStartTime!)
        .inMilliseconds;
    final correctCount = _sessionResults.where((r) => r).length;

    _lastSessionResult = ReadPronounceSessionResult(
      module: _activeModule!,
      totalAttempts: _sessionResults.length,
      correctAttempts: correctCount,
      sessionDurationMs: duration,
      completedAt: DateTime.now(),
    );

    _isSessionComplete = true;
  }

  void resetSession() {
    if (_activeModule != null) {
      startSession(_activeModule!);
    }
  }

  String? validatePracticeInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Type what the learner said before submitting.';
    if (trimmed.length > 80) {
      return 'Keep the practice attempt under 80 characters.';
    }
    return null;
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _seedState() {
    _prompts[ReadPronounceModule.letters] = ['A', 'B', 'C'];
    _prompts[ReadPronounceModule.words] = ['Dog', 'Apple', 'Book'];
    _prompts[ReadPronounceModule.sentences] = [
      'I love you',
      'I am happy',
      'Let us read',
    ];

    _moduleStates[ReadPronounceModule.letters] = const ReadPronounceModuleState(
      prompt: 'A',
      progressCurrent: 0,
      progressTotal: 3,
    );
    _moduleStates[ReadPronounceModule.words] = const ReadPronounceModuleState(
      prompt: 'Dog',
      progressCurrent: 0,
      progressTotal: 3,
    );
    _moduleStates[ReadPronounceModule.sentences] =
        const ReadPronounceModuleState(
          prompt: 'I love you',
          progressCurrent: 0,
          progressTotal: 3,
        );
  }
}
