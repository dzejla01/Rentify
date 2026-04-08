import 'package:rentify_desktop/models/appointment.dart';
import 'package:rentify_desktop/providers/base_provider.dart';

class AppoitmentProvider extends BaseProvider<Appointment> {
  AppoitmentProvider() : super("appointment");

  @override
  Appointment fromJson(dynamic data) {
    return Appointment.fromJson(data);
  }

}




  