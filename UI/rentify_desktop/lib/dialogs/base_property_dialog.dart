import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/helper/exception_read_helper.dart';
import 'package:rentify_desktop/helper/image_helper.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/helper/tags.dart';
import 'package:rentify_desktop/helper/property_image_display_helper.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/models/building_type.dart';
import 'package:rentify_desktop/models/city.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/models/property_images.dart';
import 'package:rentify_desktop/providers/building_type_provider.dart';
import 'package:rentify_desktop/providers/city_provider.dart';
import 'package:rentify_desktop/providers/image_provider.dart';
import 'package:rentify_desktop/providers/property_image_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/screens/home_screen.dart';
import 'package:rentify_desktop/utils/session.dart';
import 'package:rentify_desktop/validation/validation_model/validation_rules.dart';
import 'package:rentify_desktop/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_desktop/validation/validation_use/universal_validator.dart';

class RetifyBasePropertyDialog extends StatefulWidget {
  const RetifyBasePropertyDialog({
    super.key,
    required this.isCreate,
    this.property,
    this.imageUrls = const [],
    this.onEditingChanged,
  });

  final bool isCreate;
  final Property? property;
  final List<String> imageUrls;
  final ValueChanged<bool>? onEditingChanged;

  @override
  State<RetifyBasePropertyDialog> createState() =>
      _RetifyBasePropertyDialogState();
}

class _RetifyBasePropertyDialogState extends State<RetifyBasePropertyDialog> {
  late Fields fields;
  late PropertyProvider _propertyProvider;
  late PropertyImageProvider _propertyImageProvider;
  late CityProvider _cityProvider;
  late BuildingTypeProvider _buildingTypeProvider;

  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocus = FocusNode();
  List<String> _selectedTags = [];
  List<City> _cities = [];
  List<BuildingType> _buildingTypes = [];
  int? _selectedCityId;
  int? _selectedBuildingTypeId;
  bool _isLoadingReferences = false;

  String? _selectedTag;

  int _currentImageIndex = 0;
  List<PropertyImageDisplay> _imagesDisplay = [];
  Map<String, String?> _fieldErrors = {};

  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color lightFill = Color(0xFFF7F7F7);

  late bool _isEditing = false;
  bool _isEditedForCreateButton = false;

  LatLng? _pickedPoint;
  bool _isReverseLoading = false;

  late bool _isActiveOnApp;
  late bool _isRentingPerDay;

  List<PropertyImageDisplay> get _activeImages =>
      _imagesDisplay.where((img) => !img.isDeleted).toList();

  PropertyImageDisplay? get _currentActiveImage {
    final activeImages = _activeImages;
    if (activeImages.isEmpty) return null;

    _currentImageIndex = _currentImageIndex.clamp(0, activeImages.length - 1);
    return activeImages[_currentImageIndex];
  }

  void _addError(String field, String message) {
    _fieldErrors[field] = message;
    setState(() {});
  }

  void _clearErrors() {
    _fieldErrors.clear();
  }

  void _removeImageErrorsIfValid() {
    ErrorAutoRemoval.removeErrorOnListField<PropertyImageDisplay>(
      field: 'images',
      fieldErrors: _fieldErrors,
      list: _activeImages,
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnListField<PropertyImageDisplay>(
      field: 'mainImage',
      fieldErrors: _fieldErrors,
      list: _activeImages.where((img) => img.propertyImage.isMain).toList(),
      setState: () => setState(() {}),
    );
  }

  void _setMainImage(PropertyImageDisplay selectedImage) {
    setState(() {
      for (final img in _activeImages) {
        final shouldBeMain = identical(img, selectedImage);

        if (img.propertyImage.isMain != shouldBeMain) {
          img.propertyImage.isMain = shouldBeMain;

          if (!img.isNew) {
            img.isUpdate = true;
          }
        }
      }

      _removeImageErrorsIfValid();
      _isEditedForCreateButton = true;
    });
  }

  void _deleteImage(PropertyImageDisplay imageDisplay) {
    setState(() {
      final wasMain = imageDisplay.propertyImage.isMain;
      imageDisplay.isDeleted = true;

      if (wasMain) {
        final firstNonDeleted = _activeImages.firstWhereOrNull((img) => true);
        if (firstNonDeleted != null) {
          for (final img in _activeImages) {
            final shouldBeMain = identical(img, firstNonDeleted);

            if (img.propertyImage.isMain != shouldBeMain) {
              img.propertyImage.isMain = shouldBeMain;

              if (!img.isNew) {
                img.isUpdate = true;
              }
            }
          }
        }
      }

      final activeImages = _activeImages;
      if (activeImages.isEmpty) {
        _currentImageIndex = 0;
      } else if (_currentImageIndex >= activeImages.length) {
        _currentImageIndex = activeImages.length - 1;
      }

      _removeImageErrorsIfValid();
      _isEditedForCreateButton = true;
    });
  }

  Future<void> _addNewImage() async {
    final file = await ImageHelper.openImagePicker();
    if (file == null) return;

    final newPropertyImage = PropertyImage(
      id: 0,
      propertyId: widget.property?.id ?? 0,
      propertyImg: '',
      isMain: _activeImages.isEmpty,
    );

    final newDisplay = PropertyImageDisplay(
      propertyImage: newPropertyImage,
      localFile: file,
      isNew: true,
    );

    setState(() {
      _imagesDisplay.add(newDisplay);
      _isEditedForCreateButton = true;

      if (_activeImages.length == 1) {
        _setMainImage(newDisplay);
      } else {
        _removeImageErrorsIfValid();
      }

      _currentImageIndex = _activeImages.length - 1;
    });
  }

  Future<void> _saveImages(int propertyId) async {
    for (var imgDisplay in _imagesDisplay) {
      final img = imgDisplay.propertyImage;

      if (imgDisplay.isDeleted) {
        final imagePath = img.propertyImg ?? '';
        final isHttpImage =
            imagePath.isNotEmpty && ImageHelper.isHttp(imagePath);

        if (!imgDisplay.isNew && !isHttpImage && imagePath.isNotEmpty) {
          await ImageAppProvider.delete(
            folder: "properties",
            fileName: imagePath,
            propertyId: propertyId,
          );
        }

        if (!imgDisplay.isNew && img.id != null && img.id! > 0) {
          await _propertyImageProvider.delete(img.id!);
        }

        continue;
      }

      if (imgDisplay.isNew) {
        if (imgDisplay.localFile != null) {
          final uploadedFileName = await ImageAppProvider.upload(
            file: imgDisplay.localFile!,
            folder: 'properties',
            propertyId: propertyId,
          );
          img.propertyImg = uploadedFileName;
        }

        final inserted = await _propertyImageProvider.insert({
          'propertyId': propertyId,
          'propertyImg': img.propertyImg,
          'isMain': img.isMain,
        });

        if (inserted != null) {
          imgDisplay.propertyImage = inserted;
        }

        imgDisplay.isNew = false;
        imgDisplay.isUpdate = false;
      } else if (imgDisplay.isUpdate && img.id != null && img.id! > 0) {
        await _propertyImageProvider.update(img.id!, {
          'propertyId': propertyId,
          'propertyImg': img.propertyImg,
          'isMain': img.isMain,
        });

        imgDisplay.isUpdate = false;
      }
    }

    setState(() {
      _imagesDisplay.removeWhere((img) => img.isDeleted);

      for (var img in _imagesDisplay) {
        img.isNew = false;
        img.isUpdate = false;
        img.isDeleted = false;
      }

      final activeImages = _activeImages;
      if (activeImages.isEmpty) {
        _currentImageIndex = 0;
      } else if (_currentImageIndex >= activeImages.length) {
        _currentImageIndex = activeImages.length - 1;
      }
    });
  }

  bool valid() {
    _clearErrors();

    final activeImages = _activeImages;

    if (_isRentingPerDay) {
      ErrorAutoRemoval.removeErrorOnTextField(
        field: 'pricePerDay',
        fieldErrors: _fieldErrors,
        controller: fields.controller('pricePerDay'),
        setState: () => setState(() {}),
      );
    }

    final isValid = ValidationEngine.validate([
      Rules.requiredText(
        'name',
        fields.text('name'),
        "Naziv nekretnine je obavezan",
      ),
      Rules.minLength(
        'name',
        fields.text('name'),
        3,
        "Naziv mora imati bar 3 karaktera",
      ),
      Rules.requiredText(
        'square',
        fields.text('square'),
        "Broj kvadrata je obavezan",
      ),
      Rules.requiredText(
        'details',
        fields.text('details'),
        "Detalji su obavezni",
      ),
      Rules.positiveNumber(
        'pricePerMonth',
        fields.text('pricePerMonth'),
        "Cijena mora biti validan broj veći od 0",
      ),
      Rules.requiredText(
        'pricePerMonth',
        fields.text('pricePerMonth'),
        "Cijena je obavezna",
      ),
      if (_isRentingPerDay)
        Rules.requiredText(
          'pricePerDay',
          fields.text('pricePerDay'),
          "Cijena je obavezna",
        ),
      Rules.positiveNumber(
        'pricePerDay',
        fields.text('pricePerDay'),
        "Cijena mora biti validan broj veći od 0",
      ),
      if (fields.text('location').isEmpty)
        Rules.requiredMapPoint(
          'location',
          _pickedPoint,
          "Morate odabrati lokaciju na mapi",
        ),
      Rules.atLeastOneImage(
        'images',
        activeImages,
        "Morate dodati bar jednu sliku",
      ),
      Rules.mainImageRequired(
        'mainImage',
        activeImages,
        "Morate označiti jednu glavnu sliku",
      ),
      Rules.atLeastOneTag(
        'tags',
        _selectedTags,
        "Morate odabrati bar jedan tag",
      ),
    ], _addError);

    if (_selectedCityId == null) {
      _addError('cityId', "Grad je obavezan");
    }

    if (_selectedBuildingTypeId == null) {
      _addError('buildingTypeId', "Tip nekretnine je obavezan");
    }

    setState(() {});
    return isValid && _selectedCityId != null && _selectedBuildingTypeId != null;
  }

  Future<void> saveChanges() async {
    if (valid()) {
      try {
        double toDouble(String v) {
          final s = v.trim().replaceAll(',', '.');
          return double.tryParse(s) ?? 0.0;
        }

        final payload = <String, dynamic>{
          'userId': Session.userId,
          'name': fields.text('name').trim(),
          'cityId': _selectedCityId,
          'buildingTypeId': _selectedBuildingTypeId,
          'location': fields.text('location').trim(),
          'pricePerDay': _isRentingPerDay
              ? double.tryParse(fields.controller('pricePerDay').text) ?? 0.0
              : 0.0,
          'pricePerMonth': toDouble(fields.text('pricePerMonth')),
          'tags': _selectedTags.isEmpty ? null : _selectedTags,
          'squareMeters': fields.text('square').trim().isEmpty
              ? null
              : fields.text('square').trim(),
          'details': fields.text('details').trim().isEmpty
              ? null
              : fields.text('details').trim(),
          'isAvailable': true,
          'IsRentingPerDay': _isRentingPerDay,
          'IsActiveOnApp': _isActiveOnApp,
        };

        int propertyId;

        if (widget.isCreate) {
          final created = await _propertyProvider.insert(payload);
          propertyId = created.id;

          await _saveImages(propertyId);

          if (!mounted) return;

          SnackbarHelper.showSuccess(context, "Nekretnina je uspješno dodana");

          Navigator.pop(context, true);
          return;
        } else {
          await _propertyProvider.update(widget.property!.id, payload);
          propertyId = widget.property!.id;

          await _saveImages(propertyId);

          if (!mounted) return;

          SnackbarHelper.showUpdate(context, "Nekretnina je uspješno uređena");

          setState(() {
            _isEditing = false;
            widget.onEditingChanged?.call(false);
          });
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, extractErrorMessage(e));
        }
      }
    }
  }

  Future<void> _deleteProperty() async {
    if (widget.property == null) return;

    try {
      final propertyId = widget.property!.id;

      final imageResult = await _propertyImageProvider.get(
        filter: {'propertyId': propertyId},
      );

      for (final image in imageResult.items) {
        final imagePath = image.propertyImg ?? '';
        final isHttpImage =
            imagePath.isNotEmpty && ImageHelper.isHttp(imagePath);

        if (!isHttpImage && imagePath.isNotEmpty) {
          await ImageAppProvider.delete(
            folder: 'properties',
            fileName: imagePath,
            propertyId: propertyId,
          );
        }

        if (image.id != null && image.id! > 0) {
          await _propertyImageProvider.delete(image.id!);
        }
      }

      await _propertyProvider.delete(propertyId);

      if (!mounted) return;

      SnackbarHelper.showDelete(context, "Nekretnina je uspješno obrisana");
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, extractErrorMessage(e));
      }
    }
  }

  Future<void> _confirmDeleteProperty() async {
  final confirmed = await ConfirmDialogs.badGoodConfirmation(
    context,
    title: "Obriši nekretninu",
    question:
        "Da li ste sigurni da želite obrisati nekretninu \"${widget.property?.name ?? ''}\"?",
    goodText: "Da, obriši",
    badText: "Odustani",
  );

  if (confirmed) {
    await _deleteProperty();
  }
}

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isReverseLoading = true);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
      });

      final res = await http.get(
        uri,
        headers: {
          'User-Agent':
              'RentifyDesktop/1.0 (Flutter app; contact: ajdin.sofic@gmail.com)',
        },
      );

      if (res.statusCode != 200) {
        fields.setText('location', 'Nije moguće dohvatiti adresu.');
        return;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final displayName = (data['display_name'] ?? '') as String;

      fields.setText(
        'location',
        displayName.isNotEmpty ? displayName : 'Adresa nije pronađena.',
      );
    } catch (e) {
      fields.setText('location', 'Greška pri dohvaćanju adrese.');
    } finally {
      if (mounted) setState(() => _isReverseLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    creatingProviders();
    creatingTextFieldsAndOther();

    if (!widget.isCreate) {
      fillingTextFieldsAndOther();
      loadImages(widget.property!.id);

      _isActiveOnApp = widget.property?.isActiveOnApp ?? false;
      _isRentingPerDay = widget.property?.isRentingPerDay ?? false;
    } else {
      _isActiveOnApp = false;
      _isRentingPerDay = false;
    }

    addingErrorAutoRemovals();
    isEditingOrNot();
    _loadReferenceData();
  }

  void creatingProviders() {
    _propertyImageProvider = Provider.of<PropertyImageProvider>(
      context,
      listen: false,
    );
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _cityProvider = Provider.of<CityProvider>(context, listen: false);
    _buildingTypeProvider = Provider.of<BuildingTypeProvider>(
      context,
      listen: false,
    );
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoadingReferences = true);

    try {
      final cityResult = await _cityProvider.get(
        filter: {"retrieveAll": true, "page": 0, "pageSize": 1000},
      );
      final buildingTypeResult = await _buildingTypeProvider.get(
        filter: {"retrieveAll": true, "page": 0, "pageSize": 1000},
      );

      if (!mounted) return;

      setState(() {
        _cities = cityResult.items;
        _buildingTypes = buildingTypeResult.items;

        _selectedCityId ??= widget.property?.cityId;
        _selectedBuildingTypeId ??= widget.property?.buildingTypeId;

        if (_selectedCityId == null && _cities.isNotEmpty) {
          _selectedCityId = _cities.first.id;
        }
        if (_selectedBuildingTypeId == null && _buildingTypes.isNotEmpty) {
          _selectedBuildingTypeId = _buildingTypes.first.id;
        }
      });
    } catch (e) {
      debugPrint('_loadReferenceData error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReferences = false);
    }
  }

  void creatingTextFieldsAndOther() {
    fields = Fields.fromNames([
      'name',
      'pricePerMonth',
      'square',
      'details',
      'location',
      'pricePerDay',
    ]);
  }

  void fillingTextFieldsAndOther() {
    final p = widget.property;
    if (p != null) {
      fields.setText('name', p.name);
      fields.setText('pricePerMonth', p.pricePerMonth.toStringAsFixed(0));
      fields.setText('square', p.squareMeters.toString());
      fields.setText('details', p.details);
      fields.setText('location', p.location);
      fields.setText('pricePerDay', p.pricePerDay.toString());
      _selectedCityId = p.cityId;
      _selectedBuildingTypeId = p.buildingTypeId;

      if (p.tags != null) {
        _selectedTags = List<String>.from(p.tags!);
      }
    }
  }

  void addingErrorAutoRemovals() {
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'name',
      fieldErrors: _fieldErrors,
      controller: fields.controller('name'),
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'pricePerMonth',
      fieldErrors: _fieldErrors,
      controller: fields.controller('pricePerMonth'),
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'square',
      fieldErrors: _fieldErrors,
      controller: fields.controller('square'),
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'details',
      fieldErrors: _fieldErrors,
      controller: fields.controller('details'),
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnListField<LatLng>(
      field: 'location',
      fieldErrors: _fieldErrors,
      list: _pickedPoint != null ? [_pickedPoint!] : [],
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnListField<PropertyImageDisplay>(
      field: 'images',
      fieldErrors: _fieldErrors,
      list: _activeImages,
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnListField<PropertyImageDisplay>(
      field: 'mainImage',
      fieldErrors: _fieldErrors,
      list: _activeImages.where((img) => img.propertyImage.isMain).toList(),
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnListField<String>(
      field: 'tags',
      fieldErrors: _fieldErrors,
      list: _selectedTags,
      setState: () => setState(() {}),
    );
  }

  void isEditingOrNot() {
    _isEditing = widget.isCreate;
    if (!widget.isCreate) {
      widget.onEditingChanged?.call(false);
    } else {
      widget.onEditingChanged?.call(true);
    }
  }

  Future<void> loadImages(int propertyId) async {
    final result = await _propertyImageProvider.get(
      filter: {"propertyId": propertyId},
    );

    setState(() {
      _imagesDisplay = result.items
          .map((img) => PropertyImageDisplay(propertyImage: img))
          .toList();

      if (_activeImages.isNotEmpty &&
          !_activeImages.any((e) => e.propertyImage.isMain)) {
        _activeImages.first.propertyImage.isMain = true;
        if (!_activeImages.first.isNew) {
          _activeImages.first.isUpdate = true;
        }
      }

      if (_activeImages.isEmpty) {
        _currentImageIndex = 0;
      } else {
        _currentImageIndex = _currentImageIndex.clamp(
          0,
          _activeImages.length - 1,
        );
      }
    });
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActiveOnApp =
        !widget.isCreate && (widget.property?.isActiveOnApp ?? false);

    final bool isRentingPerDay =
        !widget.isCreate && (widget.property?.isRentingPerDay ?? false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 270,
          child: Container(
            margin: const EdgeInsets.only(top: 30, left: 20),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: _leftImageBlock(),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: _imageButtons(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_fieldErrors['images'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _fieldErrors['images']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_fieldErrors['mainImage'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _fieldErrors['mainImage']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggleBadge(
                        text: "Aktivna",
                        value: _isActiveOnApp,
                        icon: Icons.check_circle,
                        onTap: () {
                          setState(() {
                            _isActiveOnApp = !_isActiveOnApp;
                            _isEditedForCreateButton = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildToggleBadge(
                        text: "Po danu",
                        value: _isRentingPerDay,
                        icon: Icons.calendar_today,
                        onTap: () {
                          setState(() {
                            _isRentingPerDay = !_isRentingPerDay;
                            _isEditedForCreateButton = true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Container(width: 1, color: Colors.black.withOpacity(0.08)),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 40,
              top: 40,
              left: 40,
              bottom: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowTop(),
                const SizedBox(height: 14),
                _priceAndCitySection(),
                const SizedBox(height: 14),
                _rowBottom(),
                const SizedBox(height: 14),
                if (!widget.isCreate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _confirmDeleteProperty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Obriši nekretninu',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isEditing
                                ? null
                                : () {
                                    setState(() {
                                      _isEditing = true;
                                      widget.onEditingChanged?.call(true);
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: HomeScreen.rentifyGreenDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: HomeScreen.rentifyGreenDark,
                                  width: 1.8,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Uredi nekretninu',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _saveButton(),
                        ],
                      ),
                    ],
                  ),
                if (widget.isCreate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_addButton()],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _leftImageBlock() {
    final visibleImages = _activeImages;

    if (visibleImages.isEmpty) {
      return _imageContainer(child: _housePlaceholder());
    }

    _currentImageIndex = _currentImageIndex.clamp(0, visibleImages.length - 1);

    final imageDisplay = visibleImages[_currentImageIndex];
    final image = imageDisplay.propertyImage;

    return Stack(
      children: [
        _imageContainer(
          child: imageDisplay.localFile != null
              ? Image.file(imageDisplay.localFile!, fit: BoxFit.cover)
              : Image.network(
                  ImageHelper.httpCheck(image.propertyImg ?? '', 'properties'),
                  fit: BoxFit.cover,
                ),
        ),
        if (image.isMain)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Glavna slika',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        if (visibleImages.length > 1)
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 30),
              onPressed: () {
                setState(() {
                  _currentImageIndex =
                      (_currentImageIndex - 1 + visibleImages.length) %
                      visibleImages.length;
                });
              },
            ),
          ),
        if (visibleImages.length > 1)
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 30),
              onPressed: () {
                setState(() {
                  _currentImageIndex =
                      (_currentImageIndex + 1) % visibleImages.length;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _imageContainer({required Widget child}) {
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }

  Widget _buildToggleBadge({
    required String text,
    required bool value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: _isEditing ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: value ? Colors.green : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _housePlaceholder() {
    return Container(
      color: const Color(0xFFF2F2F2),
      child: Center(
        child: Image.asset(
          'assets/images/house_placeholder.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.home_work_outlined,
            size: 80,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  Widget _imageButtons() {
    if (!_isEditing) return const SizedBox();

    final currentImage = _currentActiveImage;

    return Column(
      children: [
        ElevatedButton(
          onPressed: _addNewImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: rentifyGreenDark,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Dodaj sliku",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        if (currentImage != null) ...[
          ElevatedButton(
            onPressed: () => _deleteImage(currentImage),
            child: const Text("Obriši sliku"),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () => _setMainImage(currentImage),
            child: const Text("Postavi kao glavnu"),
          ),
        ],
      ],
    );
  }

  Widget _rowTop() {
    return Row(
      children: [
        Expanded(
          child: _field(
            label: "Unesite naziv:",
            controller: fields.controller('name'),
            errorType: _fieldErrors['name'],
          ),
        ),
      ],
    );
  }

  Widget _priceAndCitySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                label: "Cijena (mjesečno):",
                controller: fields.controller('pricePerMonth'),
                keyboardType: TextInputType.number,
                errorType: _fieldErrors['pricePerMonth'],
              ),
            ),
            const SizedBox(width: 14),
            if (_isRentingPerDay)
              Expanded(
                child: _field(
                  label: "Cijena (dnevno):",
                  controller: fields.controller('pricePerDay'),
                  keyboardType: TextInputType.number,
                  errorType: _fieldErrors['pricePerDay'],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _cityField()),
            const SizedBox(width: 14),
            Expanded(child: _buildingTypeField()),
          ],
        ),
      ],
    );
  }

  Widget _rowBottom() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _mapPlaceholder(),
              const SizedBox(height: 14),
              _field(
                label: "Unesite broj kvadrata:",
                controller: fields.controller('square'),
                keyboardType: TextInputType.number,
                errorType: _fieldErrors['square'],
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(children: [_tagSelector(), _detailsField()])),
      ],
    );
  }

  Widget _tagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Taggovi:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: rentifyGreenDark.withOpacity(0.15),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: _isEditing
                  ? () {
                      setState(() {
                        _selectedTags.remove(tag);
                        ErrorAutoRemoval.removeErrorOnListField<String>(
                          field: 'tags',
                          fieldErrors: _fieldErrors,
                          list: _selectedTags,
                          setState: () => setState(() {}),
                        );
                        _isEditedForCreateButton = true;
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (_fieldErrors['tags'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _fieldErrors['tags']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (_isEditing)
          RawAutocomplete<String>(
            textEditingController: _tagController,
            focusNode: _tagFocus,
            optionsBuilder: (TextEditingValue value) {
              if (value.text.isEmpty) return const Iterable<String>.empty();

              return allTags
                  .where(
                    (tag) =>
                        tag.toLowerCase().contains(value.text.toLowerCase()) &&
                        !_selectedTags.contains(tag),
                  )
                  .take(5);
            },
            onSelected: (String tag) {
              setState(() {
                _selectedTags.add(tag);
                ErrorAutoRemoval.removeErrorOnListField<String>(
                  field: 'tags',
                  fieldErrors: _fieldErrors,
                  list: _selectedTags,
                  setState: () => setState(() {}),
                );
                _isEditedForCreateButton = true;
                _tagController.clear();
              });

              Future.delayed(
                const Duration(milliseconds: 100),
                () => _tagFocus.requestFocus(),
              );
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    onChanged: (value) {
                      setState(() {
                        _isEditedForCreateButton = true;
                      });
                    },
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: "Kucaj tag...",
                      filled: true,
                      fillColor: lightFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  );
                },
            optionsViewBuilder:
                (context, onSelected, Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 260,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
          ),
      ],
    );
  }

  Widget _cityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grad:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _cities.any((x) => x.id == _selectedCityId)
              ? _selectedCityId
              : null,
          items: _cities
              .map(
                (city) => DropdownMenuItem<int>(
                  value: city.id,
                  child: Text(city.name),
                ),
              )
              .toList(),
          onChanged: !_isEditing || _isLoadingReferences
              ? null
              : (value) {
                  setState(() {
                    _selectedCityId = value;
                    _fieldErrors.remove('cityId');
                    _isEditedForCreateButton = true;
                  });
                },
          decoration: InputDecoration(
            hintText: _isLoadingReferences ? "Ucitavanje..." : "Odaberite grad",
            filled: true,
            fillColor: lightFill,
            errorText: _fieldErrors['cityId'],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildingTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tip nekretnine:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _buildingTypes.any((x) => x.id == _selectedBuildingTypeId)
              ? _selectedBuildingTypeId
              : null,
          items: _buildingTypes
              .map(
                (type) => DropdownMenuItem<int>(
                  value: type.id,
                  child: Text(type.name),
                ),
              )
              .toList(),
          onChanged: !_isEditing || _isLoadingReferences
              ? null
              : (value) {
                  setState(() {
                    _selectedBuildingTypeId = value;
                    _fieldErrors.remove('buildingTypeId');
                    _isEditedForCreateButton = true;
                  });
                },
          decoration: InputDecoration(
            hintText: _isLoadingReferences ? "Ucitavanje..." : "Odaberite tip",
            filled: true,
            fillColor: lightFill,
            errorText: _fieldErrors['buildingTypeId'],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapPlaceholder() {
    final center = _pickedPoint ?? const LatLng(43.8563, 18.4131);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dodajte lokaciju:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: !_isEditing
                ? ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14,
                        interactiveFlags: InteractiveFlag.none,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.rentify_desktop',
                        ),
                        if (_pickedPoint != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _pickedPoint!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                      interactiveFlags: InteractiveFlag.all,
                      onTap: (tapPosition, latLng) async {
                        setState(() => _pickedPoint = latLng);
                        await _reverseGeocode(latLng);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.rentify_desktop',
                      ),
                      if (_pickedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedPoint!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: fields.controller('location'),
          readOnly: true,
          onChanged: (value) {
            _isEditedForCreateButton = true;
          },
          enabled: _isEditing,
          decoration: InputDecoration(
            hintText: _isReverseLoading
                ? 'Učitavam adresu...'
                : 'Klikni na mapu da izabereš lokaciju',
            filled: true,
            fillColor: lightFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: _isReverseLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.place_outlined),
          ),
        ),
      ],
    );
  }

  Widget _detailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detaljan opis:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: (value) {
            _isEditedForCreateButton = true;
          },
          enabled: _isEditing,
          controller: fields.controller('details'),
          maxLines: 8,
          decoration: InputDecoration(
            hintText: "Type here",
            errorText: _fieldErrors['details'],
            filled: true,
            fillColor: lightFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? errorType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: (value) {
            setState(() {
              _isEditedForCreateButton = true;
            });
          },
          enabled: _isEditing,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: lightFill,
            errorText: errorType,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: 160,
      height: 44,
      child: ElevatedButton(
        onPressed: _isEditing ? () => saveChanges() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: rentifyGreenDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Sačuvaj",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _addButton() {
    return SizedBox(
      width: 160,
      height: 44,
      child: ElevatedButton(
        onPressed: _isEditedForCreateButton ? () => saveChanges() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: rentifyGreenDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Dodaj nekretninu",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
