class UnavailableDatesResponse {
  final int propertyId;
  final List<DateTime> dates;

  UnavailableDatesResponse({
    required this.propertyId,
    required this.dates,
  });

  factory UnavailableDatesResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['dates'] as List<dynamic>? ?? const []);

    return UnavailableDatesResponse(
      propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
      dates: raw
          .where((x) => x != null)
          .map((x) => DateTime.parse(x.toString()))
          // normalizuj na yyyy-mm-dd (da ti set.contains radi 1:1)
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList(),
    );
  }
}