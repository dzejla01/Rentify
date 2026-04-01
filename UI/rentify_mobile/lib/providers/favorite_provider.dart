import 'package:rentify_mobile/models/favorite.dart';
import 'package:rentify_mobile/providers/base_provider.dart';

class FavoriteProvider extends BaseProvider<Favorite> {
  FavoriteProvider() : super("Favorite");

  @override
  Favorite fromJson(data) {
    return Favorite.fromJson(Map<String, dynamic>.from(data));
  }
}