import 'dart:convert';

import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';
import '../models/answer_choice.dart';
import '../models/question_review_status.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_type.dart';
import '../services/admin_quiz_service.dart';
import '../widgets/app_shell.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminQuizService _service = AdminQuizService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();

  bool _checkingSession = true;
  bool _authenticated = false;
  bool _loading = false;
  bool _saving = false;
  String? _error;
  List<Quiz> _quizzes = const [];
  String? _selectedQuizId;

  Quiz? get _selectedQuiz {
    for (final quiz in _quizzes) {
      if (quiz.id == _selectedQuizId) return quiz;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    try {
      final authenticated = await _service.checkSession();
      if (!mounted) return;
      setState(() {
        _authenticated = authenticated;
        _checkingSession = false;
      });
      if (authenticated) {
        await _loadQuizzes();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checkingSession = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await _service.login(_passwordController.text);
      _passwordController.clear();
      if (!mounted) return;
      setState(() => _authenticated = true);
      await _loadQuizzes();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;
    setState(() {
      _authenticated = false;
      _quizzes = const [];
      _selectedQuizId = null;
      _jsonController.clear();
    });
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quizzes = await _service.fetchQuizzes();
      if (!mounted) return;
      setState(() {
        _quizzes = quizzes;
        _selectedQuizId = quizzes.any((q) => q.id == _selectedQuizId)
            ? _selectedQuizId
            : (quizzes.isNotEmpty ? quizzes.first.id : null);
        final selected = _selectedQuiz;
        _jsonController.text = selected == null ? '' : _prettyQuiz(selected);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectQuiz(Quiz quiz) {
    setState(() {
      _selectedQuizId = quiz.id;
      _jsonController.text = _prettyQuiz(quiz);
      _error = null;
    });
  }

  Future<void> _saveCurrentJson() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final decoded = jsonDecode(_jsonController.text);
      if (decoded is! Map) {
        throw const FormatException('Quiz JSON must be an object.');
      }
      final quiz = Quiz.fromJson(Map<String, dynamic>.from(decoded));
      final saved = await _service.saveQuiz(quiz);
      if (!mounted) return;
      setState(() {
        _quizzes = [
          for (final existing in _quizzes)
            if (existing.id == saved.id) saved else existing,
          if (!_quizzes.any((existing) => existing.id == saved.id)) saved,
        ];
        _selectedQuizId = saved.id;
        _jsonController.text = _prettyQuiz(saved);
      });
      _showSnack('Saved ${saved.title}.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _newQuiz() {
    final quiz = Quiz(
      id: 'newQuiz${DateTime.now().millisecondsSinceEpoch}',
      title: 'New quiz',
      subtitle: 'Short subtitle',
      description: 'Describe what this quiz trains.',
      difficulty: 'N5-N4',
      diagnosticTags: const ['draft'],
      questions: [_questionTemplate(1, QuizType.multipleChoice)],
    );
    setState(() {
      _quizzes = [..._quizzes, quiz];
      _selectedQuizId = quiz.id;
      _jsonController.text = _prettyQuiz(quiz);
    });
  }

  void _appendQuestion(QuizType type) {
    final selected = _selectedQuiz;
    if (selected == null) return;
    final updated = Quiz(
      id: selected.id,
      title: selected.title,
      subtitle: selected.subtitle,
      description: selected.description,
      difficulty: selected.difficulty,
      diagnosticTags: selected.diagnosticTags,
      questions: [
        ...selected.questions,
        _questionTemplate(selected.questions.length + 1, type),
      ],
    );
    setState(() {
      _quizzes = [
        for (final quiz in _quizzes)
          if (quiz.id == updated.id) updated else quiz,
      ];
      _jsonController.text = _prettyQuiz(updated);
    });
  }

  QuizQuestion _questionTemplate(int index, QuizType type) {
    final id = 'q_${index.toString().padLeft(3, '0')}';
    return QuizQuestion(
      id: id,
      type: type,
      prompt: type == QuizType.multipleChoice
          ? 'Choose the best answer.'
          : 'Type the correct answer.',
      promptEn: type == QuizType.multipleChoice
          ? 'Choose the best answer.'
          : 'Type the correct answer.',
      japanese: '日本語[にほんご]の文[ぶん]',
      japaneseEn: 'Japanese sentence',
      choices: type == QuizType.multipleChoice
          ? const [
              AnswerChoice(id: 'a', label: '答[こた]え', labelEn: 'answer'),
              AnswerChoice(id: 'b', label: '違[ちが]う', labelEn: 'incorrect'),
            ]
          : const [],
      correctAnswerId: type == QuizType.multipleChoice ? 'a' : '',
      acceptedAnswers: type == QuizType.textInput ? const ['答[こた]え'] : const [],
      explanation: 'なぜこれが正解[せいかい]かを書[か]いてください。',
      explanationEn: 'Explain why this answer is correct.',
      diagnosticTags: const ['draft'],
      jlptLevel: 'N5',
      difficultyScore: 1,
      grammarPoints: const ['grammar point'],
      vocabulary: const ['vocabulary'],
      reviewStatus: QuestionReviewStatus.draft,
    );
  }

  Future<void> _showExportDialog() async {
    try {
      final json = await _service.exportJson();
      final csv = await _service.exportCsvTables();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => _AdminExportDialog(json: json, csv: csv),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _showImportDialog() async {
    final applied = await showDialog<bool>(
      context: context,
      builder: (context) => _AdminImportDialog(service: _service),
    );
    if (applied == true) {
      await _loadQuizzes();
    }
  }

  String _prettyQuiz(Quiz quiz) =>
      const JsonEncoder.withIndent('  ').convert(quiz.toJson());

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      headerMode: AppShellHeaderMode.compact,
      title: 'Admin',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (_) => false,
        ),
      ),
      actions: [
        if (_authenticated)
          TextButton(onPressed: _logout, child: const Text('Logout')),
      ],
      body: _checkingSession
          ? const Center(child: CircularProgressIndicator())
          : _authenticated
              ? _buildAdminBody(context)
              : _buildLoginBody(context),
    );
  }

  Widget _buildLoginBody(BuildContext context) {
    final tokens = context.jpQuizAppTokens;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          color: tokens.surface2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Admin password',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loading ? null : _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Colors.red.shade200)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: Text(_loading ? 'Checking...' : 'Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBody(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = LayoutBreakpoints.isNarrowWidth(width);
    final selected = _selectedQuiz;

    final editor = selected == null
        ? const Center(child: Text('No quiz selected.'))
        : _QuizEditor(
            quiz: selected,
            jsonController: _jsonController,
            saving: _saving,
            onSave: _saveCurrentJson,
            onReset: () => _selectQuiz(selected),
            onAddMultipleChoice: () => _appendQuestion(QuizType.multipleChoice),
            onAddTextInput: () => _appendQuestion(QuizType.textInput),
          );

    final sidebar = _QuizSidebar(
      quizzes: _quizzes,
      selectedQuizId: _selectedQuizId,
      loading: _loading,
      onSelect: _selectQuiz,
      onRefresh: _loadQuizzes,
      onNewQuiz: _newQuiz,
      onExport: _showExportDialog,
      onImport: _showImportDialog,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AdminErrorBanner(message: _error!),
          ),
        Expanded(
          child: narrow
              ? Column(
                  children: [
                    SizedBox(height: 220, child: sidebar),
                    const SizedBox(height: 12),
                    Expanded(child: editor),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 310, child: sidebar),
                    const SizedBox(width: 16),
                    Expanded(child: editor),
                  ],
                ),
        ),
      ],
    );
  }
}

class _QuizSidebar extends StatelessWidget {
  const _QuizSidebar({
    required this.quizzes,
    required this.selectedQuizId,
    required this.loading,
    required this.onSelect,
    required this.onRefresh,
    required this.onNewQuiz,
    required this.onExport,
    required this.onImport,
  });

  final List<Quiz> quizzes;
  final String? selectedQuizId;
  final bool loading;
  final ValueChanged<Quiz> onSelect;
  final VoidCallback onRefresh;
  final VoidCallback onNewQuiz;
  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final tokens = context.jpQuizAppTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface2,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: loading ? null : onRefresh,
                  child: const Text('Refresh'),
                ),
                FilledButton.tonal(
                  onPressed: onNewQuiz,
                  child: const Text('New quiz'),
                ),
                OutlinedButton(
                  onPressed: onExport,
                  child: const Text('Export'),
                ),
                OutlinedButton(
                  onPressed: onImport,
                  child: const Text('Import'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Quizzes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loading && quizzes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Card(
                          color: quiz.id == selectedQuizId
                              ? tokens.accentSoft
                              : tokens.surface3,
                          child: ListTile(
                            title: Text(quiz.title),
                            subtitle: Text(
                              '${quiz.id}\n${quiz.questions.length} questions',
                            ),
                            isThreeLine: true,
                            selected: quiz.id == selectedQuizId,
                            onTap: () => onSelect(quiz),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizEditor extends StatelessWidget {
  const _QuizEditor({
    required this.quiz,
    required this.jsonController,
    required this.saving,
    required this.onSave,
    required this.onReset,
    required this.onAddMultipleChoice,
    required this.onAddTextInput,
  });

  final Quiz quiz;
  final TextEditingController jsonController;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onAddMultipleChoice;
  final VoidCallback onAddTextInput;

  @override
  Widget build(BuildContext context) {
    final tokens = context.jpQuizAppTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface2,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: onAddMultipleChoice,
                      child: const Text('Add multiple choice'),
                    ),
                    FilledButton.tonal(
                      onPressed: onAddTextInput,
                      child: const Text('Add typed answer'),
                    ),
                    OutlinedButton(
                      onPressed: onReset,
                      child: const Text('Reset JSON'),
                    ),
                    FilledButton(
                      onPressed: saving ? null : onSave,
                      child: Text(saving ? 'Saving...' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: _QuestionTable(quiz: quiz),
            ),
            const SizedBox(height: 12),
            Text(
              'Quiz JSON editor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: jsonController,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionTable extends StatelessWidget {
  const _QuestionTable({required this.quiz});

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Prompt')),
              DataColumn(label: Text('Answer')),
            ],
            rows: [
              for (var i = 0; i < quiz.questions.length; i++)
                DataRow(
                  cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(quiz.questions[i].id)),
                    DataCell(Text(quiz.questions[i].type.name)),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Text(
                          quiz.questions[i].promptEn,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(quiz.questions[i].canonicalAnswers.join(' | ')),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminErrorBanner extends StatelessWidget {
  const _AdminErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade900.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, style: TextStyle(color: Colors.red.shade100)),
      ),
    );
  }
}

class _AdminExportDialog extends StatelessWidget {
  const _AdminExportDialog({required this.json, required this.csv});

  final String json;
  final Map<String, String> csv;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export quiz content'),
      content: SizedBox(
        width: 900,
        height: 620,
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'JSON'),
                  Tab(text: 'quizzes.csv'),
                  Tab(text: 'questions.csv'),
                  Tab(text: 'choices.csv'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ExportText(value: json),
                    _ExportText(value: csv['quizzes.csv'] ?? ''),
                    _ExportText(value: csv['questions.csv'] ?? ''),
                    _ExportText(value: csv['choices.csv'] ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ExportText extends StatelessWidget {
  const _ExportText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        expands: true,
        maxLines: null,
        minLines: null,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}

class _AdminImportDialog extends StatefulWidget {
  const _AdminImportDialog({required this.service});

  final AdminQuizService service;

  @override
  State<_AdminImportDialog> createState() => _AdminImportDialogState();
}

class _AdminImportDialogState extends State<_AdminImportDialog> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _quizzesCsvController = TextEditingController();
  final TextEditingController _questionsCsvController = TextEditingController();
  final TextEditingController _choicesCsvController = TextEditingController();

  bool _busy = false;
  AdminImportPreview? _preview;
  String? _error;

  @override
  void dispose() {
    _jsonController.dispose();
    _quizzesCsvController.dispose();
    _questionsCsvController.dispose();
    _choicesCsvController.dispose();
    super.dispose();
  }

  Object _payload() {
    final jsonText = _jsonController.text.trim();
    if (jsonText.isNotEmpty) {
      return jsonDecode(jsonText);
    }
    return {
      'csv': {
        'quizzes': _quizzesCsvController.text,
        'questions': _questionsCsvController.text,
        'choices': _choicesCsvController.text,
      },
    };
  }

  Future<void> _previewImport() async {
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final preview = await widget.service.previewImport(_payload());
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyImport() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final preview = await widget.service.applyImport(_payload());
      if (!mounted) return;
      setState(() => _preview = preview);
      if (preview.ok) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return AlertDialog(
      title: const Text('Import quiz content'),
      content: SizedBox(
        width: 900,
        height: 650,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste either a JSON export or all three CSV tables. Preview before applying.',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'JSON'),
                        Tab(text: 'quizzes.csv'),
                        Tab(text: 'questions.csv'),
                        Tab(text: 'choices.csv'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _ImportText(controller: _jsonController),
                          _ImportText(controller: _quizzesCsvController),
                          _ImportText(controller: _questionsCsvController),
                          _ImportText(controller: _choicesCsvController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: Colors.red.shade200)),
            ],
            if (preview != null) ...[
              const SizedBox(height: 10),
              Text(
                preview.ok
                    ? 'Ready: ${preview.totalQuizzes} quizzes, ${preview.totalQuestions} questions.'
                    : 'Validation failed.',
              ),
              if (preview.errors.isNotEmpty)
                Text(
                  preview.errors.take(8).join('\n'),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _busy ? null : _previewImport,
          child: Text(_busy ? 'Working...' : 'Preview'),
        ),
        FilledButton(
          onPressed: _busy || preview?.ok != true ? null : _applyImport,
          child: const Text('Apply import'),
        ),
      ],
    );
  }
}

class _ImportText extends StatelessWidget {
  const _ImportText({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}
