import 'package:flutter/material.dart';
import 'package:rentify_desktop/dialogs/base_dialogs.dart';
import 'package:rentify_desktop/helper/exception_read_helper.dart';
import 'package:rentify_desktop/helper/snackbar_helper.dart';
import 'package:rentify_desktop/helper/univerzal_pagging_helper.dart';
import 'package:rentify_desktop/models/answer.dart';
import 'package:rentify_desktop/models/question.dart';
import 'package:rentify_desktop/providers/answer_provider.dart';
import 'package:rentify_desktop/providers/question_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final QuestionProvider _questionProvider;
  late final AnswerProvider _answerProvider;
  late final UniversalPagingProvider<Question> _paging;

  bool _isSaving = false;
  bool? _selectedAnsweredFilter; 

  static const Color primary = Color(0xFF5F9F3B);
  static const Color border = Color(0xFFE0E0E0);
  static const Color text = Color(0xFF2F2F2F);
  static const Color subText = Color(0xFF777777);
  static const Color bg = Color(0xFFF8F8FA);

  @override
  void initState() {
    super.initState();

    _questionProvider = QuestionProvider();
    _answerProvider = AnswerProvider();

    _paging = UniversalPagingProvider<Question>(
      pageSize: 6,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        bool includeTotalCount = true,
      }) async {
        final map = <String, dynamic>{
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          "includeAnswer": true,
          "ownerId": Session.userId,
          "includeProperty": true,
          "includeUser": true,
        };

        if (filter != null && filter.isNotEmpty) {
          map["FTS"] = filter;
        }

        if (_selectedAnsweredFilter != null) {
          map["isAnswered"] = _selectedAnsweredFilter;
        }

        return await _questionProvider.get(filter: map);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _paging.loadPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _paging.dispose();
    super.dispose();
  }

  Future<Answer?> _getAnswer(int questionId) async {
    final result = await _answerProvider.get(
      filter: {"questionId": questionId, "page": 0, "pageSize": 1},
    );

    return result.items.isEmpty ? null : result.items.first;
  }

  Future<void> _setAnsweredFilter(bool? value) async {
    setState(() {
      _selectedAnsweredFilter = value;
    });

    await _paging.loadPage(
      pageNumber: 0,
      filter: _searchController.text.trim(),
    );
  }

  Future<void> _openDialog(Question q) async {
    final existing = await _getAnswer(q.id);
    final controller = TextEditingController(text: existing?.content ?? "");

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return RentifyBaseDialog(
            title: existing == null ? "Odgovori" : "Uredi odgovor",
            width: 600,
            height: 330,
            onClose: () {
              Navigator.of(context).pop();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    q.content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: text,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: TextField(
                    controller: controller,
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Unesi odgovor...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: border),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Otkaži"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                final msg = controller.text.trim();
                                if (msg.isEmpty) return;

                                setState(() => _isSaving = true);
                                setStateDialog(() {});

                                try {
                                  if (existing == null) {
                                    await _answerProvider.insert({
                                      "questionId": q.id,
                                      "userId": Session.userId,
                                      "content": msg,
                                    });
                                  } else {
                                    await _answerProvider.update(existing.id, {
                                      "questionId": q.id,
                                      "userId": Session.userId,
                                      "content": msg,
                                    });
                                  }

                                  await _paging.refresh();

                                  if (!mounted) return;
                                  Navigator.pop(context);

                                  SnackbarHelper.showSuccess(
                                    context,
                                    "Odgovor je uspješno sačuvan.",
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  SnackbarHelper.showError(
                                    context,
                                    extractErrorMessage(e),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Sačuvaj"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    controller.dispose();
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          label: "Sve",
          selected: _selectedAnsweredFilter == null,
          onTap: () => _setAnsweredFilter(null),
          color: const Color(0xFF5F9F3B),
        ),
        _StatusChip(
          label: "Odgovoreno",
          selected: _selectedAnsweredFilter == true,
          onTap: () => _setAnsweredFilter(true),
          color: Colors.green,
        ),
        _StatusChip(
          label: "Na čekanju",
          selected: _selectedAnsweredFilter == false,
          onTap: () => _setAnsweredFilter(false),
          color: const Color(0xFF5F9F3B),
        ),
      ],
    );
  }

  Widget _footer() {
    final totalPages = _paging.totalCount == 0
        ? 1
        : ((_paging.totalCount + _paging.pageSize - 1) ~/ _paging.pageSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusFilters(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ukupno: ${_paging.totalCount}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: (!_paging.hasPreviousPage || _paging.isLoading)
                      ? null
                      : () async => await _paging.previousPage(),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "${_paging.page + 1} / $totalPages",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: (!_paging.hasNextPage || _paging.isLoading)
                      ? null
                      : () async => await _paging.nextPage(),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_paging.isLoading && _paging.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_paging.items.isEmpty) {
      return const Center(
        child: Text(
          "Nema pitanja",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: subText,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _paging.items.length,
      itemBuilder: (context, i) {
        final q = _paging.items[i];
        final fullName =
            "${q.user?.firstName ?? ''} ${q.user?.lastName ?? ''}".trim();
        final hasAnswer = q.isAnswered == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q.property?.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: text,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      q.content,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: text,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: hasAnswer
                          ? const Color(0xFFEAF6E3)
                          : const Color(0xFFFFF4DA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hasAnswer ? "Odgovoreno" : "Na čekanju",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: hasAnswer ? primary : const Color(0xFFB28704),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Korisnik: ${fullName.isEmpty ? 'Nepoznato' : fullName}",
                style: const TextStyle(color: subText, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                "Datum: ${q.createdAt.day.toString().padLeft(2, '0')}.${q.createdAt.month.toString().padLeft(2, '0')}.${q.createdAt.year}",
                style: const TextStyle(color: subText, fontSize: 13),
              ),
              if (hasAnswer && q.answer != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    q.answer!.content,
                    style: const TextStyle(
                      color: text,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _openDialog(q),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(hasAnswer ? "Uredi odgovor" : "Odgovori"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Pitanja",
      child: AnimatedBuilder(
        animation: _paging,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) async {
                            await _paging.search(value.trim());
                          },
                          decoration: InputDecoration(
                            hintText: "Pretraži pitanja...",
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primary,
                                width: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody()),
                  const SizedBox(height: 16),
                  _footer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}