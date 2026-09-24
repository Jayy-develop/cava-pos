import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ModifierSelectionDialog extends StatefulWidget {
  final Product product;
  final void Function({
    required ProductVariant? variant,
    required List<ProductModifierOption> selectedModifiers,
    required String notes,
    required int quantity,
  }) onConfirm;

  const ModifierSelectionDialog({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<ModifierSelectionDialog> createState() => _ModifierSelectionDialogState();
}

class _ModifierSelectionDialogState extends State<ModifierSelectionDialog> {
  ProductVariant? _selectedVariant;
  final Map<String, Set<ProductModifierOption>> _selectedModifiersByGroup = {};
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Default variant to first option if available
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }

    // Default required modifier groups to first option
    for (final group in widget.product.modifierGroups) {
      _selectedModifiersByGroup[group.id] = {};
      if (group.isRequired && group.options.isNotEmpty) {
        _selectedModifiersByGroup[group.id]!.add(group.options.first);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double _calculateCurrentUnitPrice() {
    double total = widget.product.basePrice;
    if (_selectedVariant != null) {
      total += _selectedVariant!.priceDelta;
    }
    for (final set in _selectedModifiersByGroup.values) {
      for (final mod in set) {
        total += mod.additionalPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = _calculateCurrentUnitPrice();
    final totalPrice = unitPrice * _quantity;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                children: [
                  // Variants / Size Selection
                  if (widget.product.variants.isNotEmpty) ...[
                    const Text(
                      'PILIH UKURAN / SIZE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: widget.product.variants.map((variant) {
                        final isSelected = _selectedVariant?.id == variant.id;
                        final deltaText = variant.priceDelta > 0
                            ? ' (+${CurrencyFormatter.format(variant.priceDelta)})'
                            : '';
                        return ChoiceChip(
                          label: Text('${variant.name}$deltaText'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedVariant = variant);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Modifier Groups (e.g. Sugar, Milk, Add-ons)
                  ...widget.product.modifierGroups.map((group) {
                    final selectedInGroup = _selectedModifiersByGroup[group.id] ?? {};
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.primary,
                              ),
                            ),
                            if (group.isRequired) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Wajib',
                                  style: TextStyle(fontSize: 10, color: AppColors.danger),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...group.options.map((option) {
                          final isSelected = selectedInGroup.contains(option);
                          final priceStr = option.additionalPrice > 0
                              ? '+${CurrencyFormatter.format(option.additionalPrice)}'
                              : 'Free';

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (group.maxSelection == 1) {
                                  _selectedModifiersByGroup[group.id] = {option};
                                } else {
                                  if (isSelected) {
                                    _selectedModifiersByGroup[group.id]!.remove(option);
                                  } else {
                                    if (selectedInGroup.length < group.maxSelection) {
                                      _selectedModifiersByGroup[group.id]!.add(option);
                                    }
                                  }
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    group.maxSelection == 1
                                        ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_off)
                                        : (isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option.name,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    priceStr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: option.additionalPrice > 0
                                          ? AppColors.primaryDark
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 18),
                      ],
                    );
                  }),

                  // Kitchen Notes
                  const Text(
                    'CATATAN BAR / KITCHEN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Extra dingin, jangan pakai sedotan plastik...',
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Footer Actions: Quantity Stepper & Add Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Quantity Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          color: AppColors.textPrimary,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _quantity++),
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final allSelectedMods = _selectedModifiersByGroup.values
                            .expand((s) => s)
                            .toList();

                        widget.onConfirm(
                          variant: _selectedVariant,
                          selectedModifiers: allSelectedMods,
                          notes: _notesController.text.trim(),
                          quantity: _quantity,
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tambah Pesanan'),
                          Text(
                            CurrencyFormatter.format(totalPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
