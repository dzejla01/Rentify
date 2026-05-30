import 'package:rentify_desktop/models/building_type.dart';
import 'base_provider.dart';

class BuildingTypeProvider extends BaseProvider<BuildingType> {
  BuildingTypeProvider() : super("BuildingType");

  @override
  BuildingType fromJson(dynamic data) => BuildingType.fromJson(data);
}
