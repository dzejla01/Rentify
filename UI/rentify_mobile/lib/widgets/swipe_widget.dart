import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';

typedef ItemCardBuilder<T> = Widget Function(BuildContext context, T item);

class SwipePagedList<T> extends StatefulWidget {
  const SwipePagedList({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.separatorHeight = 10,
  });

  final UniversalPagingProvider<T> provider;
  final ItemCardBuilder<T> itemBuilder;
  final double separatorHeight;

  @override
  State<SwipePagedList<T>> createState() => _SwipePagedListState<T>();
}

class _SwipePagedListState<T> extends State<SwipePagedList<T>> {
  double _dragDx = 0;
  bool _snapping = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UniversalPagingProvider<T>>.value(
      value: widget.provider,
      child: Consumer<UniversalPagingProvider<T>>(
        builder: (context, paging, _) {
          final width = MediaQuery.of(context).size.width;
          final threshold =
              width * 0.28; // koliko moraš povući da promijeni stranicu

          Future<void> snapTo(double value) async {
            if (!mounted) return;
            setState(() => _dragDx = value);
          }

          return GestureDetector(
            behavior: HitTestBehavior.translucent,

            onHorizontalDragUpdate: (d) {
              if (paging.isLoading || _snapping) return;

              setState(() {
                _dragDx = (_dragDx + d.delta.dx).clamp(
                  -width * 0.9,
                  width * 0.9,
                );
              });
            },

            onHorizontalDragEnd: (d) async {
              if (paging.isLoading || _snapping) return;

              final shouldPrev = _dragDx > threshold;
              final shouldNext = _dragDx < -threshold;

              setState(() => _snapping = true);

              if (shouldPrev && paging.hasPreviousPage) {
                // odleti desno pa ucitaj prethodnu
                await snapTo(width);
                await Future.delayed(const Duration(milliseconds: 180));
                await paging.previousPage();
                await snapTo(0);
              } else if (shouldNext && paging.hasNextPage) {
                // odleti lijevo pa ucitaj sljedecu
                await snapTo(-width);
                await Future.delayed(const Duration(milliseconds: 180));
                await paging.nextPage();
                await snapTo(0);
              } else {
                // nije dovoljno povučeno -> vrati nazad
                await snapTo(0);
              }

              if (!mounted) return;
              setState(() => _snapping = false);
            },

            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(_dragDx, 0),
                  child: _buildContent(context, paging), // samo kartice
                ),

                const SizedBox(height: 10),

                // 👇 Ovo ostaje fiksno
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Prevuci lijevo/desno za promjenu stranice",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                    ),
                    Text(
                      "${paging.page + 1} / ${paging.totalPages}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),

                if (paging.isLoading && paging.items.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UniversalPagingProvider<T> paging,
  ) {
    // loading (prvi load)
    if (paging.isLoading && paging.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // error
    if (paging.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Text(
              paging.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: paging.refresh,
              child: const Text("Pokušaj ponovo"),
            ),
          ],
        ),
      );
    }

    // empty
    if (paging.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Center(child: Text("Nema dostupnih podataka")),
      );
    }

    // content
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paging.items.length,
          separatorBuilder: (_, __) => SizedBox(height: widget.separatorHeight),
          itemBuilder: (context, index) =>
              widget.itemBuilder(context, paging.items[index]),
        ),
        const SizedBox(height: 10),
        if (paging.isLoading && paging.items.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
