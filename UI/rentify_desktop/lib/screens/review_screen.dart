import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/helper/univerzal_pagging_helper.dart';

import 'package:rentify_desktop/models/review.dart';
import 'package:rentify_desktop/providers/review_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';


class RentifyColors {
  static const primary = Color(0xFF5F9F3B);
  static const primaryLight = Color(0xFFEAF6E5);
  static const border = Color(0xFFDFE6DA);
  static const text = Color(0xFF1F2A1F);
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int? _selectedStars;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  InputDecoration _rentifyFieldDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: Colors.black.withOpacity(0.45),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: RentifyColors.primary)
          : null,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: RentifyColors.primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: RentifyColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: RentifyColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: RentifyColors.primary, width: 1.8),
      ),
    );
  }

  String _reviewerName(Review r) {
    final fn = r.user?.firstName?.trim() ?? "";
    final ln = r.user?.lastName?.trim() ?? "";
    final full = "$fn $ln".trim();
    return full.isEmpty ? "Nepoznato" : full;
  }

  Widget _starRow(int count) {
    final c = count.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < c ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: const Color(0xFFFFC107),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Review r) async {
    return await ConfirmDialogs.badGoodConfirmation(
      context,
      title: "Brisanje recenzije",
      question:
          "Da li ste sigurni da želite obrisati recenziju:\n\n"
          "Autor: ${_reviewerName(r)}\n"
          "Ocjena: ${r.starRate} zvjezdica\n\n"
          "Poruka:\n„${r.comment ?? ""}“",
      badText: "Odustani",
      goodText: "Obriši",
      barrierDismissible: true,
    );
  }

  Future<void> _deleteReview({
    required BuildContext context,
    required UniversalPagingProvider<Review> paging,
    required Review r,
  }) async {
    final id = r.id;

    final ok = await _confirmDelete(context, r);
    if (!ok) return;

    try {
      await context.read<ReviewProvider>().delete(id);

      await paging.search(_searchCtrl.text.trim());

      if (mounted) SnackbarHelper.showUpdate(context, "Recenzija obrisana.");
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, e.toString());
    }
  }

  Widget _reviewRow({
    required BuildContext context,
    required UniversalPagingProvider<Review> paging,
    required Review r,
  }) {
    final name = _reviewerName(r);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: RentifyColors.border),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded,
              size: 22, color: RentifyColors.primary),
          const SizedBox(width: 10),

          SizedBox(
            width: 190,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: RentifyColors.text,
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            width: 1,
            height: 26,
            color: Colors.black.withOpacity(0.12),
          ),

          const Icon(Icons.chat_bubble_outline_rounded,
              size: 18, color: RentifyColors.text),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              (r.comment ?? "").trim().isEmpty ? "-" : r.comment!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),

          const SizedBox(width: 14),

          _starRow(r.starRate),

          const SizedBox(width: 12),

          IconButton(
            onPressed: paging.isLoading
                ? null
                : () => _deleteReview(context: context, paging: paging, r: r),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.withOpacity(0.85),
            ),
            iconSize: 20,
            splashRadius: 18,
            tooltip: "Obriši",
          ),
        ],
      ),
    );
  }

  Widget _pagingControls(UniversalPagingProvider<Review> paging) {
    final totalPages =
        (paging.totalCount + paging.pageSize - 1) ~/ paging.pageSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Ukupno: ${paging.totalCount}",
            style: const TextStyle(fontWeight: FontWeight.w800)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: paging.hasPreviousPage ? () => paging.previousPage() : null,
              icon: const Icon(Icons.arrow_back),
              color: RentifyColors.primary,
            ),
            Text(
              totalPages == 0 ? "0 / 0" : "${paging.page + 1} / $totalPages",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              onPressed: paging.hasNextPage ? () => paging.nextPage() : null,
              icon: const Icon(Icons.arrow_forward),
              color: RentifyColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Recenzije",
      child: ChangeNotifierProvider<UniversalPagingProvider<Review>>(
        create: (context) {
          final paging = UniversalPagingProvider<Review>(
            pageSize: 8,
            fetcher: ({
              required int page,
              required int pageSize,
              String? filter,
              bool includeTotalCount = true,
            }) {
              return context.read<ReviewProvider>().get(
                filter: {
                  "page": page,
                  "pageSize": pageSize,
                  "includeTotalCount": includeTotalCount,
                  if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
                  if (_selectedStars != null) "StarNumber": _selectedStars,
                  "includeUser": true,
                  "includeProperty": true

                },
              );
            },
          );
      
          Future.microtask(() => paging.loadPage());
          return paging;
        },
        child: Consumer<UniversalPagingProvider<Review>>(
          builder: (context, paging, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP FILTER ROW
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: _rentifyFieldDecoration(
                            hint: "Pretraga recenzija po članovima",
                            prefixIcon: Icons.search_rounded,
                            suffixIcon: (_searchCtrl.text.trim().isEmpty)
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                      paging.search("");
                                    },
                                    tooltip: "Očisti",
                                  ),
                          ),
                          onChanged: (v) {
                            setState(() {});
                            paging.search(v);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
  
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RentifyColors.primary,
                            side: const BorderSide(color: RentifyColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            setState(() => _selectedStars = null);
                            await paging.search(_searchCtrl.text.trim());
                          },
                          child: const Text("Reset"),
                        ),
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 16),
      
                  // LIST HEADER (light green)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: RentifyColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RentifyColors.border),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 32), // icon space
                        SizedBox(
                          width: 190,
                          child: Text("Korisnik", style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        SizedBox(width: 29), // divider approx
                        Expanded(
                          child: Text("Komentar", style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        SizedBox(width: 14),
                        Text("Ocjena", style: TextStyle(fontWeight: FontWeight.w900)),
                        SizedBox(width: 36),
                        Text("Obriši", style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 6),
      
                  Expanded(
                    child: (paging.isLoading && paging.items.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : paging.items.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nema podataka.",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              )
                            : ListView.builder(
                                itemCount: paging.items.length,
                                itemBuilder: (context, i) => _reviewRow(
                                  context: context,
                                  paging: paging,
                                  r: paging.items[i],
                                ),
                              ),
                  ),
      
                  const SizedBox(height: 10),
                  _pagingControls(paging),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}