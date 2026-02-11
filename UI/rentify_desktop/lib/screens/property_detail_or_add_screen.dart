import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/base_dialogs.dart';
import 'package:rentify_desktop/dialogs/base_property_dialog.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';

// primjer modela (ti već imaš Property)
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  PropertyDetailsScreen({
    super.key,
    this.property,
    this.isCreate = false,
  });

  Property? property;
  final bool isCreate;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late PropertyProvider _propertyProvider;
  late final ScrollController _scrollController;

  Property? _property;
  List<String> _imageUrls = [];
  bool _isCreate = false;
  bool _isEditing = false;


  Future<void> _handleExit() async {
    if (!_isEditing) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final confirm = await ConfirmDialogs.yesNoConfirmation(
      context,
      question:
          'Ako izađete, sve promjene koje ste napravili biće poništene. '
          'Da li i dalje želite izaći?',
    );

    if (!confirm) return;
    if (!mounted) return;
    Navigator.of(context).pop();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _scrollController = ScrollController();
    _property ??= widget.property;
    _isCreate = widget.isCreate;
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
  title: _isCreate ? "Dodaj nekretninu" : "Pregled nekretnine",
  onBack: () async {
    if (!_isEditing) return true;
    final confirm = await ConfirmDialogs.yesNoConfirmation(
      context,
      question:
          'Ako izađete, sve promjene koje ste napravili biće poništene. '
          'Da li i dalje želite izaći?',
    );
    return confirm;
  },
  child: Scrollbar(
    controller: _scrollController,
    thumbVisibility: true,
    child: ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        RetifyBasePropertyDialog(
          isCreate: _isCreate,
          property: _property,
          imageUrls: _imageUrls,
          onEditingChanged: (v) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _isEditing = v);
            });
          },
        ),
      ],
    ),
  ),
);

    
  }
}
