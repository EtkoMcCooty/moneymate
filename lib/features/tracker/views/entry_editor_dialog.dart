import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal dialog for editing a monthly line-item entry amount,
/// optional extra debt payment, and contextual note (e.g. "[1] Half Nursery fees").
class EntryEditorDialog extends StatefulWidget {
  final String itemName;
  final String currencySymbol;
  final double initialAmount;
  final double? initialExtraPayment;
  final String? initialNote;
  final bool isDebt;
  final Future<void> Function({
    required double amount,
    double? extraPayment,
    String? note,
  }) onSave;

  const EntryEditorDialog({
    super.key,
    required this.itemName,
    this.currencySymbol = '£',
    this.initialAmount = 0.0,
    this.initialExtraPayment,
    this.initialNote,
    this.isDebt = false,
    required this.onSave,
  });

  @override
  State<EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<EntryEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _extraPaymentController;
  late final TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount > 0 ? widget.initialAmount.toStringAsFixed(2) : '',
    );
    _extraPaymentController = TextEditingController(
      text: (widget.initialExtraPayment != null && widget.initialExtraPayment! > 0)
          ? widget.initialExtraPayment!.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _extraPaymentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final extraPayment = widget.isDebt
          ? double.tryParse(_extraPaymentController.text.trim())
          : null;
      final noteText = _noteController.text.trim();
      final note = noteText.isEmpty ? null : noteText;

      await widget.onSave(
        amount: amount,
        extraPayment: extraPayment,
        note: note,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Edit Entry'),
          const SizedBox(height: 2),
          Text(
            widget.itemName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('entry_amount_field'),
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${widget.currencySymbol} ',
                  hintText: '0.00',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(val.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              if (widget.isDebt) ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('entry_extra_payment_field'),
                  controller: _extraPaymentController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Extra Debt Payment (optional)',
                    prefixText: '${widget.currencySymbol} ',
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('entry_note_field'),
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. [1] Half Nursery fees',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('entry_cancel_button'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('entry_save_button'),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
