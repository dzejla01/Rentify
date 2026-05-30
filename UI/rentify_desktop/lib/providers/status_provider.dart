import 'package:rentify_desktop/models/status.dart';
import 'base_provider.dart';

class StatusProvider extends BaseProvider<Status> {
  StatusProvider() : super("Status");

  @override
  Status fromJson(dynamic data) => Status.fromJson(data);
}
