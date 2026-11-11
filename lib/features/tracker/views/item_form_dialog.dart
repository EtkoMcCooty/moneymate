import 'package:material_ui/material_ui.dart';
import '../../../core/database/app_database.dart';
import '../models/tracker_ledger_models.dart';

/// Modal dialog for adding or editing a finance item, setting optional recurring due days,
/// and configuring debt balance metadata in plain, friendly language.
class ItemFormDialog extends StatefulWidget {
  final List<Category> categories;
  final int initialCategoryId;
  final String currencySymbol;
  final FinanceItemWithEntry? itemToEdit;
  final Future<void> Function({
    required int categoryId,
    required String name,
    double? amount,
    int? dueDay,
    double? totalPrincipal,
    double? interestRate,
  }) onSave;
  final Future<void> Function(int itemId)? onArchive;
  final Future<void> Function(int itemId)? onDelete;

  const ItemFormDialog({
    super.key,
    required this.categories,
    required this.initialCategoryId,
    required this.currencySymbol,
    this.itemToEdit,
    required this.onSave,
    this.onArchive,
    this.onDelete,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedCategoryId;
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _principalController;
  late final TextEditingController _interestController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.itemToEdit != null;

  Category? get _currentCategory =>
      widget.categories.where((c) => c.id == _selectedCategoryId).firstOrNull;

  bool get _isDebtCategory =>
      _currentCategory?.categoryType.toLowerCase() == 'debt';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;

    final existing = widget.itemToEdit;
    _nameController = TextEditingController(text: existing?.item.name ?? '');
    _amountController = TextEditingController(
      text: existing?.amount != null && existing!.amount > 0
          ? existing.amount.toStringAsFixed(2)
          : '',
    );
    _dueDayController = TextEditingController(
      text: existing?.item.dueDay != null ? existing!.item.dueDay.toString() : '',
    );
    _principalController = TextEditingController(
      text: existing?.debtMetadata != null
          ? existing!.debtMetadata!.totalPrincipal.toStringAsFixed(2)
          : '',
    );
    _interestController = TextEditingController(
      text: existing?.debtMetadata != null && existing!.debtMetadata!.interestRate > 0
          ? existing.debtMetadata!.interestRate.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDayController.dispose();
    _principalController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = amountText.isNotEmpty
        ? double.tryParse(amountText)
        : (_isEditing ? 0.0 : null);
    final dueDayText = _dueDayController.text.trim();
    final dueDay = dueDayText.isNotEmpty ? int.tryParse(dueDayText) : null;

    double? principal;
    double? interest;
    if (_isDebtCategory) {
      final pText = _principalController.text.trim();
      final iText = _interestController.text.trim();
      principal = pText.isNotEmpty ? double.tryParse(pText) : 0.0;
      interest = iText.isNotEmpty ? double.tryParse(iText) : 0.0;
    }

    try {
      await widget.onSave(
        categoryId: _selectedCategoryId,
        name: name,
        amount: amount,
        dueDay: dueDay,
        totalPrincipal: principal,
        interestRate: interest,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to remove "${widget.itemToEdit!.item.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDelete != null && mounted) {
      setState(() => _isSubmitting = true);
      try {
        await widget.onDelete!(widget.itemToEdit!.item.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  Future<void> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Item?'),
        content: Text(
          'Archiving "${widget.itemToEdit!.item.name}" will hide it from future months while keeping past records safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onArchive != null && mounted) {
      setState(() => _isSubmitting = true);
      try {
        await widget.onArchive!(widget.itemToEdit!.item.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Dropdown
              DropdownButtonFormField<int>(
                key: const Key('item_category_dropdown'),
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Section / Category',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                items: widget.categories.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategoryId = val);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Item Name
              TextFormField(
                key: const Key('item_name_field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Rent, Groceries, Monzo Flex',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Amount
              TextFormField(
                key: const Key('item_amount_field'),
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixText: '${widget.currencySymbol} ',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Due Day (Optional)
              TextFormField(
                key: const Key('item_due_day_field'),
                controller: _dueDayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Due Day (Optional)',
                  hintText: 'e.g. 29',
                  helperText: 'Day of month bills or payments are due (1-31)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final day = int.tryParse(val.trim());
                  if (day == null || day < 1 || day > 31) {
                    return 'Enter a valid day between 1 and 31';
                  }
                  return null;
                },
              ),

              // Debt fields if debt category
              if (_isDebtCategory) ...[
                const SizedBox(height: 16),
                Text(
                  'Debt Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('item_debt_principal_field'),
                  controller: _principalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Total Remaining Balance',
                    hintText: '0.00',
                    prefixText: '${widget.currencySymbol} ',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    if (double.tryParse(val.trim()) == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('item_debt_interest_field'),
                  controller: _interestController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate (Optional APR)',
                    hintText: 'e.g. 19.9',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    if (double.tryParse(val.trim()) == null) {
                      return 'Enter a valid percentage';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditing && widget.onDelete != null)
          TextButton(
            key: const Key('delete_item_button'),
            onPressed: _isSubmitting ? null : _confirmDelete,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          )
        else if (_isEditing && widget.onArchive != null)
          TextButton(
            key: const Key('archive_item_button'),
            onPressed: _isSubmitting ? null : _confirmArchive,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Archive'),
          ),
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save_item_button'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
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
