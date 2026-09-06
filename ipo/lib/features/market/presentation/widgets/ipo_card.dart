import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/core/utils/formatters.dart';
import 'package:ipo/features/ipo_details/presentation/ipo_details_screen.dart';
import 'package:ipo/features/market/domain/ipo_model.dart';

class IpoCard extends StatelessWidget {
  final IpoModel ipo;

  const IpoCard({super.key, required this.ipo});

  Color _getStatusColor() {
    switch (ipo.status.toLowerCase()) {
      case 'open':
        return AppColors.open;
      case 'upcoming':
        return AppColors.upcoming;
      case 'closed':
        return AppColors.closed;
      case 'listed':
        return AppColors.listed;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor() {
    switch (ipo.status.toLowerCase()) {
      case 'open':
        return AppColors.openBg;
      case 'upcoming':
        return AppColors.upcomingBg;
      case 'closed':
        return AppColors.closedBg;
      case 'listed':
        return AppColors.listedBg;
      default:
        return AppColors.cardBorder;
    }
  }

  Future<void> _launchAllotmentUrl(BuildContext context) async {
    final urlStr = ipo.officialAllotmentUrl;
    if (urlStr == null || urlStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.officialLinkUnavailable),
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
            content: Text(AppStrings.officialLinkUnavailable),
            backgroundColor: AppColors.closed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBgColor();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category, Status, Symbol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ipo.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ipo.symbol,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ipo.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Company Name
            Text(
              ipo.companyName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 14),

            // Financial & IPO Parameters Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildParamItem(
                    'Price Band',
                    ipo.lowerPrice != null && ipo.upperPrice != null
                        ? '₹${ipo.lowerPrice!.toStringAsFixed(0)} - ₹${ipo.upperPrice!.toStringAsFixed(0)}'
                        : (ipo.upperPrice != null ? '₹${ipo.upperPrice!.toStringAsFixed(0)}' : 'Not Available'),
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    'Lot Size',
                    ipo.lotSize != null ? '${ipo.lotSize} Shares' : 'Not Available',
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    'Min. Investment',
                    ipo.minimumInvestment != null
                        ? Formatters.formatCurrency(ipo.minimumInvestment)
                        : 'Not Available',
                    isHighlight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildParamItem(
                    'Open Date',
                    Formatters.formatDate(ipo.openDate),
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    'Close Date',
                    Formatters.formatDate(ipo.closeDate),
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    'Issue Size',
                    ipo.issueSize != null ? '₹${ipo.issueSize!.toStringAsFixed(1)} Cr' : 'Not Available',
                  ),
                ),
              ],
            ),

            // Subscription Section (Strictly when real values exist)
            if (ipo.totalSubscription != null || ipo.retailSubscription != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubTag('Retail', Formatters.formatMultiple(ipo.retailSubscription)),
                    _buildSubTag('QIB', Formatters.formatMultiple(ipo.qibSubscription)),
                    _buildSubTag('NII/HNI', Formatters.formatMultiple(ipo.niiSubscription)),
                    _buildSubTag('Total', Formatters.formatMultiple(ipo.totalSubscription), isBold: true),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // GMP Section (Strictly legitimate/official provider or Not Available)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ipo.gmpValue != null ? AppColors.accentLight : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ipo.gmpValue != null
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : AppColors.cardBorder,
                ),
              ),
              child: ipo.gmpValue != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GMP: ₹${ipo.gmpValue!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                            Text(
                              'Source: ${ipo.gmpProvider ?? "Configured Provider"}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Unofficial Market Data',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                            if (ipo.gmpLastUpdated != null)
                              Text(
                                'Updated: ${Formatters.formatDate(ipo.gmpLastUpdated)}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ],
                    )
                  : const Text(
                      AppStrings.gmpNotAvailable,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),

            if (ipo.registrarName != null && ipo.registrarName!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Registrar: ${ipo.registrarName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Bottom Buttons: Exactly [ MORE INFORMATION ] and [ ALLOTMENT ]
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IpoDetailsScreen(ipoId: ipo.id),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      AppStrings.moreInformation,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _launchAllotmentUrl(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      AppStrings.allotment,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTag(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
