import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/features/market/presentation/market_controller.dart';
import 'package:ipo/features/pans/presentation/add_pan_dialog.dart';
import 'package:ipo/features/pans/presentation/pan_controller.dart';
import 'package:ipo/features/allotment/domain/allotment_result_model.dart';
import 'package:ipo/features/allotment/presentation/allotment_controller.dart';
import 'package:ipo/features/allotment/presentation/widgets/allotment_result_dialog.dart';

class AllotmentScreen extends ConsumerWidget {
  const AllotmentScreen({super.key});

  void _showAddPanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddPanDialog(),
    );
  }

  void _showResultDialog(BuildContext context, AllotmentCheckResultModel result) {
    showDialog(
      context: context,
      builder: (_) => AllotmentResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pansAsync = ref.watch(savedPansProvider);
    final iposAsync = ref.watch(iposListProvider);
    final selectionState = ref.watch(allotmentSelectionProvider);
    final selectionNotifier = ref.read(allotmentSelectionProvider.notifier);
    final checkState = ref.watch(allotmentCheckControllerProvider);

    final isChecking = checkState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.tabAllotment,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savedPansProvider);
          ref.invalidate(iposListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PAN Management Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.yourPans,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddPanDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      AppStrings.addPan,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // PAN Cards List
              pansAsync.when(
                data: (pans) {
                  if (pans.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.credit_card_off_rounded, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          const Text(
                            'No saved PAN cards',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add your PAN cards once to check allotment for family members with a single tap.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _showAddPanDialog(context),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Your First PAN'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: pans.map((pan) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            pan.maskedPan,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1.5),
                          ),
                          subtitle: pan.label != null
                              ? Text(pan.label!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.closed, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete PAN'),
                                  content: Text('Are you sure you want to remove ${pan.maskedPan}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.closed),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                ref.read(panActionControllerProvider.notifier).deletePan(pan.id);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                error: (e, _) => Text('Could not load PAN cards: $e', style: const TextStyle(color: AppColors.closed)),
              ),

              const SizedBox(height: 32),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 16),

              // 2. Allotment Verification Section
              const Text(
                'Check Allotment Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select an IPO and one or more saved PAN cards to check allotment results.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // IPO Dropdown
              const Text(
                AppStrings.selectIpo,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              iposAsync.when(
                data: (ipos) {
                  if (ipos.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Text(
                        'No active or recently closed IPOs found.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectionState.selectedIpoId,
                        hint: const Text('Select an IPO', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                        isExpanded: true,
                        items: ipos.map((ipo) {
                          return DropdownMenuItem<String>(
                            value: ipo.id,
                            child: Text(
                              '${ipo.companyName} (${ipo.symbol})',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          selectionNotifier.selectIpo(val);
                        },
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading IPOs: $e', style: const TextStyle(color: AppColors.closed)),
              ),

              const SizedBox(height: 24),

              // PAN Checkboxes
              pansAsync.when(
                data: (pans) {
                  if (pans.isEmpty) return const SizedBox.shrink();

                  final allSelected = pans.length == selectionState.selectedPanIds.length && pans.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.selectPans,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              if (allSelected) {
                                selectionNotifier.clearPanSelection();
                              } else {
                                selectionNotifier.selectAllPans(pans.map((p) => p.id).toList());
                              }
                            },
                            child: Text(
                              allSelected ? 'Deselect All' : 'Select All',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: pans.map((pan) {
                            final isChecked = selectionState.selectedPanIds.contains(pan.id);
                            return CheckboxListTile(
                              value: isChecked,
                              title: Text(
                                pan.maskedPan,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 1.2),
                              ),
                              subtitle: pan.label != null ? Text(pan.label!, style: const TextStyle(fontSize: 12)) : null,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                              onChanged: (_) => selectionNotifier.togglePan(pan.id),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Check Allotment Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (selectionState.selectedIpoId != null &&
                                  selectionState.selectedPanIds.isNotEmpty &&
                                  !isChecking)
                              ? () async {
                                  final result = await ref.read(allotmentCheckControllerProvider.notifier).check(
                                        ipoId: selectionState.selectedIpoId!,
                                        selectedPanIds: selectionState.selectedPanIds.toList(),
                                      );

                                  if (context.mounted && result != null) {
                                    _showResultDialog(context, result);
                                  } else if (context.mounted && checkState.hasError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(checkState.error.toString()),
                                        backgroundColor: AppColors.closed,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: isChecking
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text(
                                  AppStrings.checkAllotment,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
