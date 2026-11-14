class CouponFeedbackModel {
  final String code;
  final String ageGroup;
  final String interestCategory;
  final String preferredEventFormat;
  final String generalSatisfaction;
  final String discountBenefit;
  final DateTime createdAt;
  bool isRedeemed;
  String? redeemedStoreName;

  CouponFeedbackModel({
    required this.code,
    required this.ageGroup,
    required this.interestCategory,
    required this.preferredEventFormat,
    required this.generalSatisfaction,
    required this.discountBenefit,
    required this.createdAt,
    this.isRedeemed = false,
    this.redeemedStoreName,
  });

  factory CouponFeedbackModel.fromJson(Map<String, dynamic> json) {
    return CouponFeedbackModel(
      code: json['code'] as String,
      ageGroup: json['ageGroup'] as String,
      interestCategory: json['interestCategory'] as String,
      preferredEventFormat: json['preferredEventFormat'] as String,
      generalSatisfaction: json['generalSatisfaction'] as String,
      discountBenefit: json['discountBenefit'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRedeemed: json['isRedeemed'] as bool? ?? false,
      redeemedStoreName: json['redeemedStoreName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'ageGroup': ageGroup,
        'interestCategory': interestCategory,
        'preferredEventFormat': preferredEventFormat,
        'generalSatisfaction': generalSatisfaction,
        'discountBenefit': discountBenefit,
        'createdAt': createdAt.toIso8601String(),
        'isRedeemed': isRedeemed,
        'redeemedStoreName': redeemedStoreName,
      };
}