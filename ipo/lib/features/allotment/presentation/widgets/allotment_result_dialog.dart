import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/core/utils/formatters.dart';
import 'package:ipo/features/allotment/domain/allotment_result_model.dart';

class AllotmentResultDialog extends StatelessWidget {
  final AllotmentCheckResultModel result;

  const AllotmentResultDialog({super.key, required this.result});

  Future<void> _openOfficialUrl(BuildContext context) async {
    final url = result.officialStatusUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.officialLinkUnavailable),
          backgroundColor: AppColors.closed,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
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
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.companyName.isNotEmpty ? result.companyName : 'Allotment Status',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('Allotment Results', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.officialCheckRequired) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.upcomingBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppColors.upcoming),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.message ?? AppStrings.autoAllotmentUnavailable,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openOfficialUrl(context),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: const Text(
                    AppStrings.checkOnOfficialWebsite,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ] else ...[
              // Summary Row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Total PANs Checked', '${result.totalPansChecked}'),
                    _buildSummaryRow('Allotted', '${result.allottedCount}', color: AppColors.open),
                    _buildSummaryRow('Not Allotted', '${result.notAllottedCount}', color: AppColors.closed),
                    if (result.unavailableCount > 0)
                      _buildSummaryRow('Unavailable', '${result.unavailableCount}', color: AppColors.upcoming),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 8),

              // Itemized PAN Results
              ...result.results.map((panRes) {
                final isAllotted = panRes.status.toUpperCase() == 'ALLOTTED';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAllotted ? AppColors.open.withValues(alpha: 0.3) : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            panRes.maskedPan,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAllotted ? AppColors.openBg : AppColors.closedBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              panRes.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isAllotted ? AppColors.open : AppColors.closed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (panRes.shares != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Shares: ${panRes.shares}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ],
                      if (panRes.amount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Amount: ${Formatters.formatCurrency(panRes.amount)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ],
                      if (panRes.message != null && panRes.message!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          panRes.message!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
