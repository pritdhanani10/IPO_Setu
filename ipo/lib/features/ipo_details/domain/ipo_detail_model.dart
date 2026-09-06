class FinancialRecord {
  final String period;
  final double? revenue;
  final double? ebitda;
  final double? profitAfterTax;
  final double? netWorth;
  final double? totalAssets;
  final double? borrowings;
  final double? eps;

  const FinancialRecord({
    required this.period,
    this.revenue,
    this.ebitda,
    this.profitAfterTax,
    this.netWorth,
    this.totalAssets,
    this.borrowings,
    this.eps,
  });

  factory FinancialRecord.fromJson(Map<String, dynamic> json) {
    return FinancialRecord(
      period: json['period'] ?? '',
      revenue: json['revenue'] != null ? (json['revenue'] as num).toDouble() : null,
      ebitda: json['ebitda'] != null ? (json['ebitda'] as num).toDouble() : null,
      profitAfterTax: json['profitAfterTax'] != null ? (json['profitAfterTax'] as num).toDouble() : null,
      netWorth: json['netWorth'] != null ? (json['netWorth'] as num).toDouble() : null,
      totalAssets: json['totalAssets'] != null ? (json['totalAssets'] as num).toDouble() : null,
      borrowings: json['borrowings'] != null ? (json['borrowings'] as num).toDouble() : null,
      eps: json['eps'] != null ? (json['eps'] as num).toDouble() : null,
    );
  }
}

class DocumentRecord {
  final String title;
  final String documentType;
  final String officialUrl;

  const DocumentRecord({
    required this.title,
    required this.documentType,
    required this.officialUrl,
  });

  factory DocumentRecord.fromJson(Map<String, dynamic> json) {
    return DocumentRecord(
      title: json['title'] ?? '',
      documentType: json['documentType'] ?? 'RHP',
      officialUrl: json['officialUrl'] ?? '',
    );
  }
}

class IpoDetailModel {
  final String id;
  final String companyName;
  final String symbol;
  final String category;
  final String status;
  final DateTime? openDate;
  final DateTime? closeDate;
  final DateTime? listingDate;
  final DateTime? allotmentDate;
  final DateTime? refundDate;
  final DateTime? dematCreditDate;

  final double? lowerPrice;
  final double? upperPrice;
  final int? lotSize;
  final double? minimumInvestment;
  final double? issueSize;
  final double? faceValue;
  final double? freshIssueAmount;
  final double? offerForSaleAmount;
  final int? totalShares;
  final String? listingExchange;
  final String? registrarName;
  final String? leadManagers;

  // Company Details
  final String? industry;
  final String? businessDescription;
  final String? businessModel;
  final String? promoters;
  final String? companyWebsite;
  final String? objectsOfIssue;

  // Issue Structure
  final double? retailPortionPercent;
  final double? qibPortionPercent;
  final double? niiPortionPercent;
  final double? anchorPortionPercent;

  // GMP
  final double? gmpValue;
  final String? gmpProvider;
  final DateTime? gmpLastUpdated;

  // Official Links
  final String? officialNseUrl;
  final String? officialBseUrl;
  final String? officialAllotmentUrl;
  final String? sourceName;
  final DateTime lastUpdatedAt;

  final List<FinancialRecord> financials;
  final List<DocumentRecord> documents;

  const IpoDetailModel({
    required this.id,
    required this.companyName,
    required this.symbol,
    required this.category,
    required this.status,
    this.openDate,
    this.closeDate,
    this.listingDate,
    this.allotmentDate,
    this.refundDate,
    this.dematCreditDate,
    this.lowerPrice,
    this.upperPrice,
    this.lotSize,
    this.minimumInvestment,
    this.issueSize,
    this.faceValue,
    this.freshIssueAmount,
    this.offerForSaleAmount,
    this.totalShares,
    this.listingExchange,
    this.registrarName,
    this.leadManagers,
    this.industry,
    this.businessDescription,
    this.businessModel,
    this.promoters,
    this.companyWebsite,
    this.objectsOfIssue,
    this.retailPortionPercent,
    this.qibPortionPercent,
    this.niiPortionPercent,
    this.anchorPortionPercent,
    this.gmpValue,
    this.gmpProvider,
    this.gmpLastUpdated,
    this.officialNseUrl,
    this.officialBseUrl,
    this.officialAllotmentUrl,
    this.sourceName,
    required this.lastUpdatedAt,
    this.financials = const [],
    this.documents = const [],
  });

  factory IpoDetailModel.fromJson(Map<String, dynamic> json) {
    return IpoDetailModel(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      symbol: json['symbol'] ?? '',
      category: json['category'] ?? 'mainboard',
      status: json['status'] ?? 'upcoming',
      openDate: json['openDate'] != null ? DateTime.tryParse(json['openDate']) : null,
      closeDate: json['closeDate'] != null ? DateTime.tryParse(json['closeDate']) : null,
      listingDate: json['listingDate'] != null ? DateTime.tryParse(json['listingDate']) : null,
      allotmentDate: json['allotmentDate'] != null ? DateTime.tryParse(json['allotmentDate']) : null,
      refundDate: json['refundDate'] != null ? DateTime.tryParse(json['refundDate']) : null,
      dematCreditDate: json['dematCreditDate'] != null ? DateTime.tryParse(json['dematCreditDate']) : null,
      lowerPrice: json['lowerPrice'] != null ? (json['lowerPrice'] as num).toDouble() : null,
      upperPrice: json['upperPrice'] != null ? (json['upperPrice'] as num).toDouble() : null,
      lotSize: json['lotSize'] as int?,
      minimumInvestment: json['minimumInvestment'] != null
          ? (json['minimumInvestment'] as num).toDouble()
          : (json['upperPrice'] != null && json['lotSize'] != null
              ? (json['upperPrice'] as num).toDouble() * (json['lotSize'] as int)
              : null),
      issueSize: json['issueSize'] != null ? (json['issueSize'] as num).toDouble() : null,
      faceValue: json['faceValue'] != null ? (json['faceValue'] as num).toDouble() : null,
      freshIssueAmount: json['freshIssueAmount'] != null ? (json['freshIssueAmount'] as num).toDouble() : null,
      offerForSaleAmount: json['offerForSaleAmount'] != null ? (json['offerForSaleAmount'] as num).toDouble() : null,
      totalShares: json['totalShares'] != null ? (json['totalShares'] as num).toInt() : null,
      listingExchange: json['listingExchange'],
      registrarName: json['registrarName'],
      leadManagers: json['leadManagers'],
      industry: json['industry'],
      businessDescription: json['businessDescription'],
      businessModel: json['businessModel'],
      promoters: json['promoters'],
      companyWebsite: json['companyWebsite'],
      objectsOfIssue: json['objectsOfIssue'],
      retailPortionPercent: json['retailPortionPercent'] != null ? (json['retailPortionPercent'] as num).toDouble() : null,
      qibPortionPercent: json['qibPortionPercent'] != null ? (json['qibPortionPercent'] as num).toDouble() : null,
      niiPortionPercent: json['niiPortionPercent'] != null ? (json['niiPortionPercent'] as num).toDouble() : null,
      anchorPortionPercent: json['anchorPortionPercent'] != null ? (json['anchorPortionPercent'] as num).toDouble() : null,
      gmpValue: json['gmpValue'] != null ? (json['gmpValue'] as num).toDouble() : null,
      gmpProvider: json['gmpProvider'],
      gmpLastUpdated: json['gmpLastUpdated'] != null ? DateTime.tryParse(json['gmpLastUpdated']) : null,
      officialNseUrl: json['officialNseUrl'],
      officialBseUrl: json['officialBseUrl'],
      officialAllotmentUrl: json['officialAllotmentUrl'],
      sourceName: json['sourceName'],
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt']) ?? DateTime.now()
          : DateTime.now(),
      financials: json['financials'] != null
          ? (json['financials'] as List).map((f) => FinancialRecord.fromJson(f as Map<String, dynamic>)).toList()
          : [],
      documents: json['documents'] != null
          ? (json['documents'] as List).map((d) => DocumentRecord.fromJson(d as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
