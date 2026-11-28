import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    super.key,
    required this.topicId,
    this.initialQuizType = 'pre_test',
  });

  final String topicId;
  final String initialQuizType;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  late String _currentType;
  late Future<(List<Question>, List<QuizAttempt>)> _loadFuture;

  // Active quiz session state
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> optionIndex
  bool _isSubmitted = false;
  bool _isSaving = false;
  QuizAttempt? _savedAttempt;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialQuizType;
    _fetchQuizData();
  }

  void _fetchQuizData() {
    final repo = ref.read(sessionRepositoryProvider);
    setState(() {
      _loadFuture = Future.wait([
        repo.getQuestions(widget.topicId, quizType: _currentType),
        repo.getQuizAttempts(widget.topicId),
      ]).then((results) => (
            results[0] as List<Question>,
            results[1] as List<QuizAttempt>,
          ));
      _currentIndex = 0;
      _selectedAnswers.clear();
      _isSubmitted = false;
      _savedAttempt = null;
    });
  }

  void _selectOption(int qIndex, int optIndex) {
    if (_isSubmitted) return;
    setState(() {
      _selectedAnswers[qIndex] = optIndex;
    });
  }

  Future<void> _submitQuiz(List<Question> questions) async {
    final l10n = context.l10n;
    if (_selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.answerAllPrompt),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    int correctCount = 0;
    final Map<String, dynamic> answerLog = {};
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final userAns = _selectedAnswers[i] ?? -1;
      final isCorrect = userAns == q.correctIndex;
      if (isCorrect) correctCount++;
      answerLog[q.id] = {
        'selected_index': userAns,
        'correct_index': q.correctIndex,
        'is_correct': isCorrect,
      };
    }

    final int calculatedScore = ((correctCount / questions.length) * 100).round();

    try {
      final repo = ref.read(sessionRepositoryProvider);
      final attempt = await repo.submitQuizAttempt(
        topicId: widget.topicId,
        quizType: _currentType,
        score: calculatedScore,
        totalQuestions: questions.length,
        correctAnswers: correctCount,
        answers: answerLog,
      );

      setState(() {
        _isSubmitted = true;
        _savedAttempt = attempt;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.quizSaveError(e.toString())),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typeLabel = _currentType == 'pre_test' ? l10n.preTestTitle : l10n.postTestTitle;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(
          typeLabel,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<(List<Question>, List<QuizAttempt>)>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.quizLoadError(snapshot.error.toString()),
                style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
              ),
            );
          }

          final (questions, pastAttempts) = snapshot.data!;
          final hasCompletedPreTest =
              pastAttempts.any((a) => a.quizType == 'pre_test') ||
              (_isSubmitted && _currentType == 'pre_test');
          final isPostTestLocked =
              _currentType == 'post_test' && !hasCompletedPreTest;

          return Column(
            children: [
              // Pre/Post Filter Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_currentType != 'pre_test') {
                            setState(() => _currentType = 'pre_test');
                            _fetchQuizData();
                          }
                        },
                        child: ClayCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: _currentType == 'pre_test'
                              ? AppTheme.primaryIndigo
                              : Colors.white,
                          borderColor: _currentType == 'pre_test'
                              ? AppTheme.primaryIndigo
                              : AppTheme.clayBorder,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasCompletedPreTest) ...[
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 15,
                                    color: _currentType == 'pre_test'
                                        ? Colors.white
                                        : AppTheme.successGreen,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  l10n.preTestTab,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _currentType == 'pre_test'
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!hasCompletedPreTest) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selesaikan Pre-Test terlebih dahulu untuk membuka Post-Test.',
                                ),
                                backgroundColor: AppTheme.accentOrange,
                              ),
                            );
                            return;
                          }
                          if (_currentType != 'post_test') {
                            setState(() => _currentType = 'post_test');
                            _fetchQuizData();
                          }
                        },
                        child: ClayCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: _currentType == 'post_test'
                              ? AppTheme.primaryIndigo
                              : hasCompletedPreTest
                                  ? Colors.white
                                  : const Color(0xFFF1F5F9),
                          borderColor: _currentType == 'post_test'
                              ? AppTheme.primaryIndigo
                              : AppTheme.clayBorder,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!hasCompletedPreTest) ...[
                                  const Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  l10n.postTestTab,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _currentType == 'post_test'
                                        ? Colors.white
                                        : hasCompletedPreTest
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Locked state, Empty State, Result Screen, or Questions List
              if (isPostTestLocked)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 52,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Post-Test Terkunci',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Selesaikan Pre-Test terlebih dahulu sebelum mengerjakan Post-Test.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClayButton(
                            text: 'Kerjakan Pre-Test',
                            onPressed: () {
                              setState(() => _currentType = 'pre_test');
                              _fetchQuizData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (questions.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.quiz_outlined, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noQuestionsYet,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isSubmitted && _savedAttempt != null)
                // Result Screen
                Expanded(child: _buildResultView(questions, _savedAttempt!))
              else
                // Quiz Question Flow
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Progress Tracker Card
                      ClayCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.questionCounter(_currentIndex + 1, questions.length),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                ClayPill(
                                  label: l10n.answeredCounter(_selectedAnswers.length, questions.length),
                                  color: AppTheme.primaryIndigoLight,
                                  textColor: AppTheme.primaryIndigo,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClayProgressBar(
                              progress: (_selectedAnswers.length) / questions.length,
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Current Question Card
                      _buildQuestionCard(questions[_currentIndex], _currentIndex),
                    ],
                  ),
                ),

              // Bottom Navigation bar during quiz
              if (questions.isNotEmpty && !_isSubmitted && !isPostTestLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppTheme.clayBorder, width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: ClayButton(
                            text: l10n.previousBtn,
                            isPrimary: false,
                            onPressed: () => setState(() => _currentIndex--),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _currentIndex == questions.length - 1
                            ? ClayButton(
                                text: l10n.submitQuizBtn,
                                isAccent: true,
                                isLoading: _isSaving,
                                onPressed: () => _submitQuiz(questions),
                              )
                            : ClayButton(
                                text: l10n.nextBtn,
                                onPressed: () => setState(() => _currentIndex++),
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(Question q, int qIndex) {
    final selectedOpt = _selectedAnswers[qIndex];

    return ClayCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.questionText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          if (q.codeSnippet != null && q.codeSnippet!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                q.codeSnippet!,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Options List
          ...List.generate(q.options.length, (optIdx) {
            final isChosen = selectedOpt == optIdx;
            final optionLetters = ['A', 'B', 'C', 'D', 'E'];
            final letter = optIdx < optionLetters.length ? optionLetters[optIdx] : '$optIdx';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => _selectOption(qIndex, optIdx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isChosen ? AppTheme.primaryIndigoLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChosen ? AppTheme.primaryIndigo : AppTheme.clayBorder,
                      width: isChosen ? 2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isChosen ? AppTheme.primaryIndigo : AppTheme.clayCanvas,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: isChosen ? Colors.white : AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          q.options[optIdx],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultView(List<Question> questions, QuizAttempt attempt) {
    final l10n = context.l10n;
    final isPassed = attempt.score >= 75;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClayCard(
          padding: const EdgeInsets.all(24),
          color: isPassed ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
          borderColor: isPassed ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA),
          child: Column(
            children: [
              Icon(
                isPassed ? Icons.verified_rounded : Icons.info_outline_rounded,
                size: 56,
                color: isPassed ? AppTheme.successGreen : AppTheme.accentOrange,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.yourScoreLabel(attempt.score),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isPassed ? const Color(0xFF065F46) : const Color(0xFF9A3412),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPassed ? l10n.scorePassedMsg : l10n.scoreNeedsWorkMsg,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.answerReviewTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(questions.length, (idx) {
          final q = questions[idx];
          final userAns = _selectedAnswers[idx] ?? -1;
          final isCorrect = userAns == q.correctIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: ClayCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? AppTheme.successGreen : AppTheme.dangerRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.questionNumber(idx + 1),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.questionText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.yourAnswerLabel(userAns >= 0 && userAns < q.options.length ? q.options[userAns] : '-'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: isCorrect ? AppTheme.successGreen : AppTheme.dangerRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.correctAnswerLabel(q.options[q.correctIndex]),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (q.explanation != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.clayCanvas,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.explanationLabel(q.explanation!),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        ClayButton(
          text: l10n.backToDashboard,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
