import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/core/utils/formatters.dart';
import 'package:ipo/shared/widgets/empty_state_widget.dart';
import 'package:ipo/shared/widgets/error_state_widget.dart';
import 'package:ipo/features/ipo_details/data/ipo_details_repository.dart';

class IpoDetailsScreen extends ConsumerWidget {
  final String ipoId;

  const IpoDetailsScreen({super.key, required this.ipoId});

  Future<void> _launchExternalUrl(BuildContext context, String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document link not available.'),
          backgroundColor: AppColors.upcoming,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(urlStr);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open external link.'),
            backgroundColor: AppColors.closed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ipoDetailProvider(ipoId));

    return Scaffold(
      body: detailAsync.when(
        data: (ipo) {
          if (ipo == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('IPO Details')),
              body: EmptyStateWidget(
                title: AppStrings.dataUnavailable,
                subtitle: 'The details for this IPO could not be found.',
                onRetry: () => ref.invalidate(ipoDetailProvider(ipoId)),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Sliver App Bar
              SliverAppBar(
                expandedHeight: 140.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                  title: Text(
                    ipo.companyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Container(
                    color: AppColors.primary.withValues(alpha: 0.04),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Category Badge Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ipo.category.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.openBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ipo.status.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.open),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Symbol: ${ipo.symbol}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 1. IPO Key Dates & Details
                      _buildSectionHeader(context, 'IPO Timeline & Key Details'),
                      _buildCard([
                        _buildRow('Open Date', Formatters.formatDate(ipo.openDate)),
                        _buildRow('Close Date', Formatters.formatDate(ipo.closeDate)),
                        _buildRow('Basis of Allotment', Formatters.formatDate(ipo.allotmentDate)),
                        _buildRow('Initiation of Refunds', Formatters.formatDate(ipo.refundDate)),
                        _buildRow('Credit of Shares to Demat', Formatters.formatDate(ipo.dematCreditDate)),
                        _buildRow('Listing Date', Formatters.formatDate(ipo.listingDate)),
                        _buildRow(
                          'Price Band',
                          ipo.lowerPrice != null && ipo.upperPrice != null
                              ? '₹${ipo.lowerPrice!.toStringAsFixed(0)} - ₹${ipo.upperPrice!.toStringAsFixed(0)}'
                              : 'Not Available',
                        ),
                        _buildRow('Lot Size', ipo.lotSize != null ? '${ipo.lotSize} Shares' : 'Not Available'),
                        _buildRow(
                          'Minimum Investment',
                          ipo.minimumInvestment != null ? Formatters.formatCurrency(ipo.minimumInvestment) : 'Not Available',
                          isBold: true,
                        ),
                        _buildRow('Total Issue Size', ipo.issueSize != null ? '₹${ipo.issueSize!.toStringAsFixed(1)} Cr' : 'Not Available'),
                        _buildRow('Fresh Issue', ipo.freshIssueAmount != null ? '₹${ipo.freshIssueAmount!.toStringAsFixed(1)} Cr' : 'Not Available'),
                        _buildRow('Offer For Sale (OFS)', ipo.offerForSaleAmount != null ? '₹${ipo.offerForSaleAmount!.toStringAsFixed(1)} Cr' : 'Not Available'),
                        _buildRow('Face Value', ipo.faceValue != null ? '₹${ipo.faceValue!.toStringAsFixed(0)} per share' : 'Not Available'),
                        _buildRow('Listing Exchange', ipo.listingExchange ?? 'Not Available'),
                        _buildRow('Registrar', ipo.registrarName ?? 'Not Available'),
                        _buildRow('Lead Managers', ipo.leadManagers ?? 'Not Available'),
                      ]),

                      const SizedBox(height: 24),

                      // 2. Company Details
                      _buildSectionHeader(context, 'Company Details'),
                      _buildCard([
                        _buildRow('Industry', ipo.industry ?? 'Not Available'),
                        if (ipo.businessDescription != null) ...[
                          const SizedBox(height: 8),
                          const Text('Business Description', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(ipo.businessDescription!, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                        ],
                        if (ipo.businessModel != null) ...[
                          const SizedBox(height: 8),
                          const Text('Business Model', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(ipo.businessModel!, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                        ],
                        _buildRow('Promoters', ipo.promoters ?? 'Not Available'),
                        if (ipo.companyWebsite != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Website', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                InkWell(
                                  onTap: () => _launchExternalUrl(context, ipo.companyWebsite),
                                  child: Text(
                                    ipo.companyWebsite!,
                                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ]),

                      const SizedBox(height: 24),

                      // 3. Objects of the Issue
                      _buildSectionHeader(context, 'Objects of the Issue'),
                      _buildCard([
                        Text(
                          ipo.objectsOfIssue != null && ipo.objectsOfIssue!.isNotEmpty
                              ? ipo.objectsOfIssue!
                              : 'Not Available from official offer documents yet.',
                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // 4. Financial Information
                      _buildSectionHeader(context, 'Financial Information (₹ in Crores)'),
                      if (ipo.financials.isEmpty)
                        _buildCard([
                          const Text(
                            'Financial information not available in configured official source.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ])
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.06)),
                            columns: const [
                              DataColumn(label: Text('Period', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('EBITDA', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('PAT', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Net Worth', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Total Assets', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Borrowings', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('EPS (₹)', style: TextStyle(fontWeight: FontWeight.w700))),
                            ],
                            rows: ipo.financials.map((f) {
                              return DataRow(cells: [
                                DataCell(Text(f.period, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(f.revenue != null ? f.revenue!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.ebitda != null ? f.ebitda!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.profitAfterTax != null ? f.profitAfterTax!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.netWorth != null ? f.netWorth!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.totalAssets != null ? f.totalAssets!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.borrowings != null ? f.borrowings!.toStringAsFixed(2) : 'N/A')),
                                DataCell(Text(f.eps != null ? f.eps!.toStringAsFixed(2) : 'N/A')),
                              ]);
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 5. Issue Structure
                      _buildSectionHeader(context, 'Issue Structure'),
                      _buildCard([
                        _buildRow('Retail Portion', ipo.retailPortionPercent != null ? '${ipo.retailPortionPercent!.toStringAsFixed(0)}%' : 'Not Available'),
                        _buildRow('QIB Portion', ipo.qibPortionPercent != null ? '${ipo.qibPortionPercent!.toStringAsFixed(0)}%' : 'Not Available'),
                        _buildRow('NII/HNI Portion', ipo.niiPortionPercent != null ? '${ipo.niiPortionPercent!.toStringAsFixed(0)}%' : 'Not Available'),
                        _buildRow('Anchor Portion', ipo.anchorPortionPercent != null ? '${ipo.anchorPortionPercent!.toStringAsFixed(0)}%' : 'Not Available'),
                      ]),

                      const SizedBox(height: 24),

                      // 6. Official Documents
                      _buildSectionHeader(context, 'Official Documents & Filings'),
                      if (ipo.documents.isEmpty && ipo.officialNseUrl == null && ipo.officialBseUrl == null)
                        _buildCard([
                          const Text(
                            'Official document links not available from source.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ])
                      else
                        Column(
                          children: [
                            ...ipo.documents.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _launchExternalUrl(context, doc.officialUrl),
                                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                                    label: Text(doc.title),
                                  ),
                                ),
                              );
                            }),
                            if (ipo.officialNseUrl != null)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _launchExternalUrl(context, ipo.officialNseUrl),
                                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                  label: const Text('Official NSE IPO Information'),
                                ),
                              ),
                            if (ipo.officialBseUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _launchExternalUrl(context, ipo.officialBseUrl),
                                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                    label: const Text('Official BSE IPO Information'),
                                  ),
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Official Allotment Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchExternalUrl(context, ipo.officialAllotmentUrl),
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: const Text('CHECK ALLOTMENT ON OFFICIAL REGISTRAR'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('IPO Details')),
          body: ErrorStateWidget(
            message: err.toString(),
            onRetry: () => ref.invalidate(ipoDetailProvider(ipoId)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
