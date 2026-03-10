class ScreenerAccessLink {
  const ScreenerAccessLink({
    required this.token,
    required this.screenerId,
    required this.screenerName,
    required this.surveyId,
    required this.surveyDisplayName,
    required this.createdAt,
  });

  final String token;
  final String screenerId;
  final String screenerName;
  final String surveyId;
  final String surveyDisplayName;
  final DateTime createdAt;

  factory ScreenerAccessLink.fromJson(Map<String, dynamic> json) {
    return ScreenerAccessLink(
      token: json['token']?.toString() ?? '',
      screenerId: json['screenerId']?.toString() ?? '',
      screenerName: json['screenerName']?.toString() ?? '',
      surveyId: json['surveyId']?.toString() ?? '',
      surveyDisplayName: json['surveyDisplayName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
