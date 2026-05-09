import 'dart:math';

import 'package:flutter/foundation.dart';

enum ReadPronounceModule { letters, words, sentences }

enum ReadPronounceAttemptOutcome { empty, correct, incorrect }

class ReadPronouncePrompt {
  const ReadPronouncePrompt({
    required this.text,
    required this.acceptedAnswers,
    this.imagePath,
  });

  final String text;
  final List<String> acceptedAnswers;
  final String? imagePath;

  bool matches(String value) {
    final normalizedValue = ReadPronounceController.normalizeText(value);
    return acceptedAnswers.any(
      (answer) =>
          ReadPronounceController.normalizeText(answer) == normalizedValue,
    );
  }
}

class ReadPronounceModuleState {
  final String prompt;
  final int progressCurrent;
  final int progressTotal;
  final String lastAttempt;
  final String feedback;
  final int incorrectAttemptsForCurrentRound;
  final bool isCorrect;

  const ReadPronounceModuleState({
    required this.prompt,
    required this.progressCurrent,
    required this.progressTotal,
    this.lastAttempt = '',
    this.feedback = 'Tap the microphone and say it clearly.',
    this.incorrectAttemptsForCurrentRound = 0,
    this.isCorrect = false,
  });

  ReadPronounceModuleState copyWith({
    String? prompt,
    int? progressCurrent,
    int? progressTotal,
    String? lastAttempt,
    String? feedback,
    int? incorrectAttemptsForCurrentRound,
    bool? isCorrect,
  }) {
    return ReadPronounceModuleState(
      prompt: prompt ?? this.prompt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      feedback: feedback ?? this.feedback,
      incorrectAttemptsForCurrentRound:
          incorrectAttemptsForCurrentRound ??
          this.incorrectAttemptsForCurrentRound,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class ReadPronounceSessionResult {
  final ReadPronounceModule module;
  final int totalAttempts;
  final int correctAttempts;
  final int skippedRounds;
  final int sessionDurationMs;
  final DateTime completedAt;

  const ReadPronounceSessionResult({
    required this.module,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.sessionDurationMs,
    required this.completedAt,
    this.skippedRounds = 0,
  });

  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAttempts / totalAttempts;
  }

  int get stars {
    if (accuracy >= 0.8) return 3;
    if (accuracy >= 0.5) return 2;
    return 1;
  }

  int get accuracyPercent => (accuracy * 100).round();
}

class ReadPronounceController extends ChangeNotifier {
  ReadPronounceController() {
    _seedState();
  }

  static const int roundsPerSession = 4;
  static const int maxIncorrectAttemptsBeforeSkip = 3;

  final Map<ReadPronounceModule, List<ReadPronouncePrompt>> _promptPools = {};
  final Map<ReadPronounceModule, ReadPronounceModuleState> _moduleStates = {};

  ReadPronounceModule? _activeModule;
  List<ReadPronouncePrompt> _sessionPrompts = [];
  int _currentPromptIndex = 0;
  int _totalVoiceAttempts = 0;
  int _correctAnswers = 0;
  int _completedRounds = 0;
  int _skippedRounds = 0;
  int _incorrectAttemptsForCurrentRound = 0;
  bool _isAwaitingNextRound = false;
  DateTime? _sessionStartTime;
  ReadPronounceSessionResult? _lastSessionResult;
  bool _isSessionComplete = false;

  ReadPronounceModule? get activeModule => _activeModule;
  int get currentPromptIndex => _currentPromptIndex;
  int get totalVoiceAttempts => _totalVoiceAttempts;
  int get correctAnswers => _correctAnswers;
  int get completedRounds => _completedRounds;
  int get skippedRounds => _skippedRounds;
  int get incorrectAttemptsForCurrentRound => _incorrectAttemptsForCurrentRound;
  bool get isAwaitingNextRound => _isAwaitingNextRound;
  bool get shouldShowSkip =>
      !_isAwaitingNextRound &&
      _incorrectAttemptsForCurrentRound >= maxIncorrectAttemptsBeforeSkip;
  ReadPronounceSessionResult? get lastSessionResult => _lastSessionResult;
  bool get isSessionComplete => _isSessionComplete;

  ReadPronounceModuleState? get currentState {
    if (_activeModule == null) return null;
    return _moduleStates[_activeModule];
  }

  ReadPronouncePrompt? get currentPrompt {
    if (_sessionPrompts.isEmpty ||
        _currentPromptIndex >= _sessionPrompts.length) {
      return null;
    }
    return _sessionPrompts[_currentPromptIndex];
  }

  List<String> get currentPrompts =>
      _sessionPrompts.map((prompt) => prompt.text).toList(growable: false);

  int get totalPrompts => _sessionPrompts.length;

  void startSession(ReadPronounceModule module) {
    final pool = List<ReadPronouncePrompt>.of(_promptPools[module]!);
    pool.shuffle(Random());

    _activeModule = module;
    _sessionPrompts = pool.take(roundsPerSession).toList(growable: false);
    _currentPromptIndex = 0;
    _totalVoiceAttempts = 0;
    _correctAnswers = 0;
    _completedRounds = 0;
    _skippedRounds = 0;
    _incorrectAttemptsForCurrentRound = 0;
    _isAwaitingNextRound = false;
    _sessionStartTime = DateTime.now();
    _isSessionComplete = false;
    _lastSessionResult = null;

    _moduleStates[module] = _buildCurrentState(
      feedback: 'Tap the microphone and say it clearly.',
    );

    notifyListeners();
  }

  ReadPronounceAttemptOutcome submitAttempt(String capturedText) {
    final module = _activeModule;
    final prompt = currentPrompt;
    if (module == null || prompt == null || _isAwaitingNextRound) {
      return ReadPronounceAttemptOutcome.empty;
    }

    final error = validatePracticeInput(capturedText);
    if (error != null) {
      _moduleStates[module] = _buildCurrentState(
        feedback: error,
        lastAttempt: capturedText,
      );
      notifyListeners();
      return ReadPronounceAttemptOutcome.empty;
    }

    _totalVoiceAttempts++;
    final isCorrect = prompt.matches(capturedText);

    if (isCorrect) {
      _correctAnswers++;
      _isAwaitingNextRound = true;
      _moduleStates[module] = _buildCurrentState(
        feedback: 'Correct',
        lastAttempt: capturedText,
        isCorrect: true,
      );
      notifyListeners();
      return ReadPronounceAttemptOutcome.correct;
    }

    _incorrectAttemptsForCurrentRound++;
    _moduleStates[module] = _buildCurrentState(
      feedback: shouldShowSkip
          ? 'Good try. You can skip this one.'
          : 'Close. Try saying it again.',
      lastAttempt: capturedText,
    );
    notifyListeners();
    return ReadPronounceAttemptOutcome.incorrect;
  }

  void advanceAfterCorrect() {
    if (!_isAwaitingNextRound || _isSessionComplete) return;
    _advanceRound();
  }

  void skipCurrentPrompt() {
    if (_isSessionComplete || _isAwaitingNextRound) return;
    _skippedRounds++;
    _advanceRound();
  }

  void _advanceRound() {
    final module = _activeModule;
    if (module == null) return;

    _completedRounds++;

    if (_completedRounds >= totalPrompts) {
      _completeSession();
      notifyListeners();
      return;
    }

    _currentPromptIndex++;
    _incorrectAttemptsForCurrentRound = 0;
    _isAwaitingNextRound = false;
    _moduleStates[module] = _buildCurrentState(
      feedback: 'Tap the microphone and say it clearly.',
    );
    notifyListeners();
  }

  void _completeSession() {
    if (_activeModule == null) return;

    final duration = DateTime.now()
        .difference(_sessionStartTime ?? DateTime.now())
        .inMilliseconds;

    _lastSessionResult = ReadPronounceSessionResult(
      module: _activeModule!,
      totalAttempts: _totalVoiceAttempts,
      correctAttempts: _correctAnswers,
      skippedRounds: _skippedRounds,
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
    if (trimmed.isEmpty) return 'I did not hear it. Try again.';
    if (trimmed.length > 120) {
      return 'Try a shorter answer.';
    }
    return null;
  }

  ReadPronounceModuleState _buildCurrentState({
    String? feedback,
    String lastAttempt = '',
    bool isCorrect = false,
  }) {
    final prompt = currentPrompt;
    return ReadPronounceModuleState(
      prompt: prompt?.text ?? '',
      progressCurrent: min(_currentPromptIndex + 1, roundsPerSession),
      progressTotal: totalPrompts,
      lastAttempt: lastAttempt,
      feedback: feedback ?? 'Tap the microphone and say it clearly.',
      incorrectAttemptsForCurrentRound: _incorrectAttemptsForCurrentRound,
      isCorrect: isCorrect,
    );
  }

  static String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _seedState() {
    _promptPools[ReadPronounceModule.letters] = const [
      ReadPronouncePrompt(
        text: 'A',
        acceptedAnswers: ['a', 'ay'],
        imagePath: 'assets/images/letter1.png',
      ),
      ReadPronouncePrompt(
        text: 'B',
        acceptedAnswers: ['b', 'bee', 'be'],
        imagePath: 'assets/images/letter2.png',
      ),
      ReadPronouncePrompt(
        text: 'C',
        acceptedAnswers: ['c', 'see', 'sea'],
        imagePath: 'assets/images/letter3.png',
      ),
      ReadPronouncePrompt(
        text: 'D',
        acceptedAnswers: ['d', 'dee'],
        imagePath: 'assets/images/letter4.png',
      ),
      ReadPronouncePrompt(
        text: 'E',
        acceptedAnswers: ['e', 'ee'],
        imagePath: 'assets/images/letter5.png',
      ),
      ReadPronouncePrompt(
        text: 'F',
        acceptedAnswers: ['f', 'eff'],
        imagePath: 'assets/images/letter6.png',
      ),
      ReadPronouncePrompt(
        text: 'G',
        acceptedAnswers: ['g', 'gee'],
        imagePath: 'assets/images/letter7.png',
      ),
      ReadPronouncePrompt(
        text: 'H',
        acceptedAnswers: ['h', 'aitch', 'edge'],
        imagePath: 'assets/images/letter8.png',
      ),
    ];

    _promptPools[ReadPronounceModule.words] = const [
      ReadPronouncePrompt(
        text: 'Dog',
        acceptedAnswers: ['dog'],
        imagePath: 'assets/images/words1.png',
      ),
      ReadPronouncePrompt(
        text: 'Apple',
        acceptedAnswers: ['apple'],
        imagePath: 'assets/images/words2.png',
      ),
      ReadPronouncePrompt(
        text: 'Book',
        acceptedAnswers: ['book'],
        imagePath: 'assets/images/words3.png',
      ),
      ReadPronouncePrompt(
        text: 'Ball',
        acceptedAnswers: ['ball'],
        imagePath: 'assets/images/words4.png',
      ),
      ReadPronouncePrompt(
        text: 'Cat',
        acceptedAnswers: ['cat'],
        imagePath: 'assets/images/words5.png',
      ),
      ReadPronouncePrompt(
        text: 'Fish',
        acceptedAnswers: ['fish'],
        imagePath: 'assets/images/words6.png',
      ),
      ReadPronouncePrompt(
        text: 'Sun',
        acceptedAnswers: ['sun'],
        imagePath: 'assets/images/words7.png',
      ),
      ReadPronouncePrompt(
        text: 'Cup',
        acceptedAnswers: ['cup'],
        imagePath: 'assets/images/words8.png',
      ),
    ];

    _promptPools[ReadPronounceModule.sentences] = const [
      ReadPronouncePrompt(
        text: 'I love you',
        acceptedAnswers: ['i love you'],
        imagePath: 'assets/images/sentence1.png',
      ),
      ReadPronouncePrompt(
        text: 'I am happy',
        acceptedAnswers: ['i am happy', 'im happy', 'i m happy'],
        imagePath: 'assets/images/sentence2.png',
      ),
      ReadPronouncePrompt(
        text: 'Let us read',
        acceptedAnswers: ['let us read', 'lets read', 'let s read'],
        imagePath: 'assets/images/sentence3.png',
      ),
      ReadPronouncePrompt(
        text: 'I see a dog',
        acceptedAnswers: ['i see a dog'],
        imagePath: 'assets/images/sentence4.png',
      ),
      ReadPronouncePrompt(
        text: 'This is a pencil',
        acceptedAnswers: ['this is a pencil'],
        imagePath: 'assets/images/sentence5.png',
      ),
      ReadPronouncePrompt(
        text: 'I want some water',
        acceptedAnswers: ['i want some water'],
        imagePath: 'assets/images/sentence6.png',
      ),
      ReadPronouncePrompt(
        text: 'The sun is up',
        acceptedAnswers: ['the sun is up'],
        imagePath: 'assets/images/sentence7.png',
      ),
      ReadPronouncePrompt(
        text: 'Thank you',
        acceptedAnswers: ['thank you'],
        imagePath: 'assets/images/sentence8.png',
      ),
    ];

    _moduleStates[ReadPronounceModule.letters] = const ReadPronounceModuleState(
      prompt: 'A',
      progressCurrent: 1,
      progressTotal: roundsPerSession,
    );
    _moduleStates[ReadPronounceModule.words] = const ReadPronounceModuleState(
      prompt: 'Dog',
      progressCurrent: 1,
      progressTotal: roundsPerSession,
    );
    _moduleStates[ReadPronounceModule.sentences] =
        const ReadPronounceModuleState(
          prompt: 'I love you',
          progressCurrent: 1,
          progressTotal: roundsPerSession,
        );
  }

  String? getCurrentImagePath() => currentPrompt?.imagePath;
}
