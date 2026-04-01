import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/base_dialogs.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/models/answer.dart';
import 'package:rentify_mobile/models/question.dart';
import 'package:rentify_mobile/providers/answer_provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/question_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/widgets/swipe_widget.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late QuestionProvider _questionProvider;
  late AnswerProvider _answerProvider;
  late UniversalPagingProvider<Question> _paging;

  final PageController _swiperController = PageController(
    viewportFraction: 0.92,
  );
  int _swiperIndex = 0;

  @override
  void initState() {
    super.initState();

    _questionProvider = context.read<QuestionProvider>();
    _answerProvider = context.read<AnswerProvider>();

    _paging = UniversalPagingProvider<Question>(
      pageSize: 5,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        Map<String, dynamic>? extra,
        bool includeTotalCount = true,
      }) async {
        final map = <String, dynamic>{
          "userId": Session.userId,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
        };

        if (filter != null && filter.trim().isNotEmpty) {
          map["fts"] = filter.trim();
        }

        if (extra != null && extra["isAnswered"] != null) {
          map["isAnswered"] = extra["isAnswered"];
        }

        return await _questionProvider.get(filter: map);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _paging.applyExtra({});
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _paging.dispose();
    super.dispose();
  }

  int get _answeredCount =>
      _paging.items.where((e) => e.isAnswered == true).length;

  int get _waitingCount =>
      _paging.items.where((e) => e.isAnswered == false).length;

  Future<void> _refresh() async {
    await _paging.refresh();
  }

  Future<void> _showAnswerDialog(Question item) async {
    if (!item.isAnswered) return;

    try {
      final result = await _answerProvider.get(
        filter: {
          "questionId": item.id,
          "page": 0,
          "pageSize": 1,
          "includeTotalCount": false,
        },
      );

      if (!mounted) return;

      if (result.items.isEmpty) {
        await ConfirmDialogs.okConfirmation(
          context,
          title: "Odgovor nije pronađen",
          message:
              "Pitanje je označeno kao odgovoreno, ali odgovor trenutno nije dostupan.",
        );
        return;
      }

      final Answer answer = result.items.first;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => RentifyBaseDialog(
          title: "Odgovor na pitanje",
          width: 520,
          onClose: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ((item.property?.name ?? "").trim().isNotEmpty)
                    ? item.property!.name
                    : "Nekretnina",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Vaše pitanje",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5F9F3B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Odgovor",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5F9F3B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x225F9F3B)),
                ),
                child: Text(
                  answer.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F2F2F),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Odgovoreno: ${answer.createdAt.day}.${answer.createdAt.month}.${answer.createdAt.year}.",
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F9F3B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Zatvori",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      await ConfirmDialogs.okConfirmation(
        context,
        title: "Greška",
        message: "Došlo je do greške pri učitavanju odgovora.",
      );
    }
  }

  Widget _buildSwiperHeader() {
    final cards = [
      _HeaderCardData(
        title: "Ukupno pitanja",
        value: _paging.totalCount.toString(),
        subtitle: "Sva pitanja koja ste poslali",
        icon: Icons.question_answer_rounded,
      ),
      _HeaderCardData(
        title: "Odgovoreno",
        value: _answeredCount.toString(),
        subtitle: "Pitanja sa dostupnim odgovorom",
        icon: Icons.mark_chat_read_rounded,
      ),
      _HeaderCardData(
        title: "Na čekanju",
        value: _waitingCount.toString(),
        subtitle: "Pitanja koja još čekaju odgovor",
        icon: Icons.schedule_rounded,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _swiperController,
            itemCount: cards.length,
            onPageChanged: (index) {
              setState(() => _swiperIndex = index);
            },
            itemBuilder: (context, index) {
              final card = cards[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index == cards.length - 1 ? 0 : 12,
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFBFE06A),
                        Color(0xFFA9C64A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.subtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        card.icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (index) {
            final active = index == _swiperIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF5F9F3B)
                    : const Color(0xFFD3D3D3),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question item) {
    final propertyName = ((item.property?.name ?? "").trim().isEmpty)
        ? "Nekretnina"
        : item.property!.name;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  propertyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.isAnswered
                      ? const Color(0xFFE9F6DD)
                      : const Color(0xFFFFF5D9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.isAnswered ? "Odgovoreno" : "Na čekanju",
                  style: TextStyle(
                    color: item.isAnswered
                        ? const Color(0xFF5F9F3B)
                        : const Color(0xFFB28704),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F2F2F),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Postavljeno: ${item.createdAt.day}.${item.createdAt.month}.${item.createdAt.year}.",
            style: const TextStyle(
              color: Color(0xFF777777),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: item.isAnswered
                  ? () => _showAnswerDialog(item)
                  : null,
              icon: Icon(
                item.isAnswered
                    ? Icons.visibility_rounded
                    : Icons.hourglass_empty_rounded,
              ),
              label: Text(
                item.isAnswered ? "Vidi odgovor" : "Čeka odgovor",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: item.isAnswered
                    ? const Color(0xFF5F9F3B)
                    : const Color(0xFFBDBDBD),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBDBDBD),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Pitanja",
      NameAndSurname: Session.fullName!,
      userUsername: Session.username!,
      userImageAsset: Session.userImage,
      onLogout: () async {
  await Session.odjava(
    deviceTokenProvider: context.read<DeviceTokenProvider>(),
    authProvider: context.read<AuthProvider>(),
  );

  if (!context.mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
    (route) => false,
  );
},
      child: AnimatedBuilder(
        animation: _paging,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _paging.isLoading && _paging.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _paging.error != null
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 120),
                          Text(
                            _paging.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: ElevatedButton(
                              onPressed: _refresh,
                              child: const Text("Pokušaj ponovo"),
                            ),
                          ),
                        ],
                      )
                    : _paging.items.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 80),
                              const Icon(
                                Icons.question_answer_outlined,
                                size: 74,
                                color: Color(0xFFA9C64A),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                "Nemate još pitanja",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Pitanja koja pošaljete za nekretnine prikazivat će se ovdje, zajedno sa statusom odgovora.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E6E6E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              _buildSwiperHeader(),
                              const SizedBox(height: 16),
                              SwipePagedList<Question>(
                                provider: _paging,
                                separatorHeight: 14,
                                itemBuilder: (context, item) =>
                                    _buildQuestionCard(item),
                              ),
                            ],
                          ),
          );
        },
      ),
    );
  }
}

class _HeaderCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  _HeaderCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}