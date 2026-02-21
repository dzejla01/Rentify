import 'package:flutter/material.dart';

class RentifyColors {
  static const primary = Color(0xFF5F9F3B); // tamnija zelena
  static const primaryLight = Color(0xFFEAF6E5); // svijetlo zelena pozadina
  static const surface = Colors.white;
  static const border = Color(0xFFDFE6DA);
  static const text = Color(0xFF1F2A1F);
}

class BaseColumn<T> {
  final String title;
  final int flex;
  final Widget Function(T item) cell;

  const BaseColumn({required this.title, required this.cell, this.flex = 1});
}

class BaseSearchAndTable<T> extends StatelessWidget {
  final String title;

  /// Top bar
  final String searchHint;
  final void Function(String value)? onSearchChanged;
  final VoidCallback? onClearSearch;

  /// ADD button (optional)
  final String? addButtonText;
  final VoidCallback? onAdd;

  /// Table
  final List<BaseColumn<T>> columns;
  final List<T> items;

  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;

  final EdgeInsets padding;
  final Widget? footer;

  final bool? isStatusMode;
  final String? editLabel;

  const BaseSearchAndTable({
    super.key,
    required this.title,
    required this.columns,
    required this.items,
    this.searchHint = "Pretraga",
    this.onSearchChanged,
    this.onClearSearch,
    this.addButtonText,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.footer,
    this.padding = const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
    this.isStatusMode,
    this.editLabel,
  });

  bool get _hasActions => onEdit != null || onDelete != null;
  bool get _showAdd => (addButtonText != null && addButtonText!.trim().isNotEmpty && onAdd != null);

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SearchBar(
                hint: searchHint,
                onChanged: onSearchChanged,
                onClear: onClearSearch,
              ),
            ),
            if (_showAdd) ...[
              const SizedBox(width: 14),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RentifyColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    addButtonText!.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 18),

        // TABLE HEADER
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: RentifyColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RentifyColors.border),
          ),
          child: Row(
            children: [
              ...columns.map(
                (c) => Expanded(
                  flex: c.flex,
                  child: Text(
                    c.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: RentifyColors.text,
                    ),
                  ),
                ),
              ),
              if (_hasActions) ...[
                Expanded(
                  flex: 1,
                  child: Text(
                    editLabel ?? (isStatusMode == true ? "Status" : "Uredi"),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text("Obriši", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 6),

        // TABLE BODY
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    "Nema podataka.",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return _HoverRow(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            ...columns.map((c) => Expanded(flex: c.flex, child: c.cell(item))),
                            if (_hasActions) ...[
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: onEdit == null ? null : () => onEdit!(item),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(
                                      isStatusMode == true ? Icons.sync_alt : Icons.edit_outlined,
                                      size: 20,
                                      color: RentifyColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: onDelete == null ? null : () => onDelete!(item),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        if (footer != null) ...[const SizedBox(height: 14), footer!],
      ],
    ),
  );
}
}

class _HoverRow extends StatefulWidget {
  final Widget child;
  const _HoverRow({required this.child});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _hover ? RentifyColors.primaryLight.withOpacity(0.55) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: RentifyColors.border)),
        ),
        child: widget.child,
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final String hint;
  final void Function(String value)? onChanged;
  final VoidCallback? onClear;

  const _SearchBar({required this.hint, this.onChanged, this.onClear});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: RentifyColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RentifyColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: RentifyColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.45)),
                border: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _ctrl.clear();
              widget.onChanged?.call("");
              widget.onClear?.call();
              setState(() {});
            },
            child: Icon(Icons.close, size: 18, color: Colors.black.withOpacity(0.55)),
          ),
        ],
      ),
    );
  }
}