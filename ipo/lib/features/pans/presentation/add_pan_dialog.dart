import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/utils/pan_validator.dart';
import 'package:ipo/features/pans/presentation/pan_controller.dart';

class AddPanDialog extends ConsumerStatefulWidget {
  const AddPanDialog({super.key});

  @override
  ConsumerState<AddPanDialog> createState() => _AddPanDialogState();
}

class _AddPanDialogState extends ConsumerState<AddPanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _labelController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _panController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(panActionControllerProvider.notifier).addPan(
          _panController.text.trim().toUpperCase(),
          _labelController.text.trim().isNotEmpty ? _labelController.text.trim() : null,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PAN card added successfully.'),
            backgroundColor: AppColors.open,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add PAN card. Please check if already added.'),
            backgroundColor: AppColors.closed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add PAN Card', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your PAN is encrypted at rest and never shared or stored in plain text.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _panController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'PAN Number',
                hintText: 'ABCDE1234F',
                counterText: '',
              ),
              validator: (val) {
                if (!PanValidator.isValid(val)) {
                  return 'Enter valid 10-digit PAN (e.g. ABCDE1234F)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Optional Label',
                hintText: 'e.g. My PAN, Family PAN 1',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Add PAN'),
        ),
      ],
    );
  }
}
