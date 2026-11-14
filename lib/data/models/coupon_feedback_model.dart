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
}

class CategoryMetricModel {
  final String name;
  final int baseInterestedCount;
  final int augustPercentage;
  final List<int> monthlyTrendJunToSep; // [Jun, Jul, Ago, Set]
  final Map<String, int> ageGroupAffinity; // % dentro de cada faixa etária
  final String opportunityTitle;
  final String opportunityDescription;

  const CategoryMetricModel({
    required this.name,
    required this.baseInterestedCount,
    required this.augustPercentage,
    required this.monthlyTrendJunToSep,
    required this.ageGroupAffinity,
    required this.opportunityTitle,
    required this.opportunityDescription,
  });
}

class AudienceProfileModel {
  final String ageGroup;
  final int baseConsumers;
  final String topInterest;

  const AudienceProfileModel({
    required this.ageGroup,
    required this.baseConsumers,
    required this.topInterest,
  });
}

class GooglePerceptionModel {
  final String theme;
  final String sentiment;
  final String detail;

  const GooglePerceptionModel({
    required this.theme,
    required this.sentiment,
    required this.detail,
  });
}