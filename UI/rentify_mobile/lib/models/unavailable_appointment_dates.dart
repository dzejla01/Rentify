class UnavailableAppointmentsResponse {
  final int propertyId;
  final List<DateTime> dateTimes;

  UnavailableAppointmentsResponse({
    required this.propertyId,
    required this.dateTimes,
  });

  factory UnavailableAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['dateTimes'] as List<dynamic>? ?? const []);

    return UnavailableAppointmentsResponse(
      propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
      dateTimes: raw
          .where((x) => x != null)
          .map((x) => DateTime.parse(x.toString())) 
          .toList(),
    );
  }
}