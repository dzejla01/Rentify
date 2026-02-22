import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/univerzal_pagging_helper.dart';

typedef TableRowBuilder<T> = List<Widget> Function(T item);

class PaginatedTable<T> extends StatelessWidget {
  final UniversalPagingProvider<T> provider;
  final TableRowBuilder<T> rowBuilder;
  final List<Widget> header;

  const PaginatedTable({
    Key? key,
    required this.provider,
    required this.rowBuilder,
    required this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UniversalPagingProvider<T>>.value(
      value: provider,
      child: Consumer<UniversalPagingProvider<T>>(
        builder: (context, paging, _) {
          if (paging.isLoading && paging.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paging.items.isEmpty) {
            return const Center(child: Text("Nema dostupnih podataka"));
          }

          return Column(
            children: [
              Row(children: header),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: paging.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = paging.items[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: rowBuilder(item)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _pagingControls(paging),
            ],
          );
        },
      ),
    );
  }

  Widget _pagingControls(UniversalPagingProvider<T> paging) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: paging.hasPreviousPage ? () => paging.previousPage() : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text(
          "${paging.page + 1} / ${((paging.totalCount + paging.pageSize - 1) ~/ paging.pageSize)}",
        ),
        IconButton(
          onPressed: paging.hasNextPage ? () => paging.nextPage() : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
