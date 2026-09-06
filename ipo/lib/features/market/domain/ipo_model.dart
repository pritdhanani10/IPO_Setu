class IpoModel {
  final String id;
  final String companyName;
  final String symbol;
  final String category; // mainboard | sme
  final String status;   // open | upcoming | closed | listed
  final DateTime? openDate;
  final DateTime? closeDate;
  final String? openTime;
  final String? closeTime;
  final double? lowerPrice;
  final double? upperPrice;
  final int? lotSize;
  final double? minimumInvestment;
  final double? issueSize;
  final DateTime? listingDate;
  final String? registrarName;

  // Real Subscription
  final double? retailSubscription;
  final double? qibSubscription;
  final double? niiSubscription;
  final double? totalSubscription;

  // GMP (strictly official/legitimate configured provider or null)
  final double? gmpValue;
  final String? gmpProvider;
  final DateTime? gmpLastUpdated;

  final String? officialAllotmentUrl;
  final String? sourceName;
  final DateTime lastUpdatedAt;

  const IpoModel({
    required this.id,
    required this.companyName,
    required this.symbol,
    required this.category,
    required this.status,
    this.openDate,
    this.closeDate,
    this.openTime,
    this.closeTime,
    this.lowerPrice,
    this.upperPrice,
    this.lotSize,
    this.minimumInvestment,
    this.issueSize,
    this.listingDate,
    this.registrarName,
    this.retailSubscription,
    this.qibSubscription,
    this.niiSubscription,
    this.totalSubscription,
    this.gmpValue,
    this.gmpProvider,
    this.gmpLastUpdated,
    this.officialAllotmentUrl,
    this.sourceName,
    required this.lastUpdatedAt,
  });

  factory IpoModel.fromJson(Map<String, dynamic> json) {
    return IpoModel(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      symbol: json['symbol'] ?? '',
      category: json['category'] ?? 'mainboard',
      status: json['status'] ?? 'upcoming',
      openDate: json['openDate'] != null ? DateTime.tryParse(json['openDate']) : null,
      closeDate: json['closeDate'] != null ? DateTime.tryParse(json['closeDate']) : null,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      lowerPrice: json['lowerPrice'] != null ? (json['lowerPrice'] as num).toDouble() : null,
      upperPrice: json['upperPrice'] != null ? (json['upperPrice'] as num).toDouble() : null,
      lotSize: json['lotSize'] as int?,
      minimumInvestment: json['minimumInvestment'] != null
          ? (json['minimumInvestment'] as num).toDouble()
          : (json['upperPrice'] != null && json['lotSize'] != null
              ? (json['upperPrice'] as num).toDouble() * (json['lotSize'] as int)
              : null),
      issueSize: json['issueSize'] != null ? (json['issueSize'] as num).toDouble() : null,
      listingDate: json['listingDate'] != null ? DateTime.tryParse(json['listingDate']) : null,
      registrarName: json['registrarName'],
      retailSubscription: json['retailSubscription'] != null ? (json['retailSubscription'] as num).toDouble() : null,
      qibSubscription: json['qibSubscription'] != null ? (json['qibSubscription'] as num).toDouble() : null,
      niiSubscription: json['niiSubscription'] != null ? (json['niiSubscription'] as num).toDouble() : null,
      totalSubscription: json['totalSubscription'] != null ? (json['totalSubscription'] as num).toDouble() : null,
      gmpValue: json['gmpValue'] != null ? (json['gmpValue'] as num).toDouble() : null,
      gmpProvider: json['gmpProvider'],
      gmpLastUpdated: json['gmpLastUpdated'] != null ? DateTime.tryParse(json['gmpLastUpdated']) : null,
      officialAllotmentUrl: json['officialAllotmentUrl'],
      sourceName: json['sourceName'],
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
