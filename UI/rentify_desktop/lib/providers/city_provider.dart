import 'package:rentify_desktop/models/city.dart';
import 'base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic data) => City.fromJson(data);
}
