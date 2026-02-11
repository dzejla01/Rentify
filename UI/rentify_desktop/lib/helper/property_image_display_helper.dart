import 'dart:io';

import 'package:rentify_desktop/models/property_images.dart';

class PropertyImageDisplay {
  PropertyImage propertyImage;
  bool isDeleted;
  bool isNew;
  bool isUpdate;
  File? localFile;

  PropertyImageDisplay({
    required this.propertyImage,
    this.isDeleted = false,
    this.isNew = false,
    this.isUpdate = false,
    this.localFile
  });
}
