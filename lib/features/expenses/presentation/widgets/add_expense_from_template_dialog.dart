import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/expense_item.dart';
import '../../domain/expense_template.dart';
import '../../services/expense_service.dart';
import '../../../../core/constants/app_colors.dart';

class AddExpenseFromTemplateDialog extends StatefulWidget {
  final ExpenseItem? existingExpense; // If editing an existing expense

  const AddExpenseFromTemplateDialog({super.key, this.existingExpense});

  @override
  State<AddExpenseFromTemplateDialog> createState() => _AddExpenseFromTemplateDialogState();
}

class _AddExpenseFromTemplateDialogState extends State<AddExpenseFromTemplateDialog> {
  final _expenseService = ExpenseService();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _receiptRefController;
  late ExpenseCategory _category;
  late String _paymentSource;
  ExpenseTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    final item = widget.existingExpense;
    if (item != null) {
      _titleController = TextEditingController(text: item.title);
      _amountController = TextEditingController(text: item.amount.toInt().toString());
      _notesController = TextEditingController(text: item.notes);
      _receiptRefController = TextEditingController(text: item.receiptRef);
      _category = item.category;
      _paymentSource = item.paymentSource;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _notesController = TextEditingController();
      _receiptRefController = TextEditingController(text: 'RCP-EXP-${DateTime.now().millisecondsSinceEpoch % 10000}');
      _category = ExpenseCategory.operasional;
      _paymentSource = 'Kas Laci (Petty Cash)';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _receiptRefController.dispose();
    super.dispose();
  }

  void _applyTemplate(ExpenseTemplate tpl) {
    setState(() {
      _selectedTemplate = tpl;
      _titleController.text = tpl.title;
      _category = tpl.category;
      _paymentSource = tpl.defaultPaymentSource;
      _notesController.text = tpl.defaultNotes;
      if (tpl.defaultAmount > 0) {
        _amountController.text = tpl.defaultAmount.toInt().toString();
      }
    });
  }

  void _adjustAmount(double delta) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    final updated = (current + delta).clamp(0.0, 100000000.0);
    setState(() {
      _amountController.text = updated.toInt().toString();
    });
  }

  IconData _getCategoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.bahanDapur:
        return Icons.kitchen;
      case ExpenseCategory.utilitas:
        return Icons.bolt;
      case ExpenseCategory.operasional:
        return Icons.inventory;
      case ExpenseCategory.gajiUpah:
        return Icons.payments_outlined;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.sewaIuran:
        return Icons.holiday_village;
      case ExpenseCategory.lainnya:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;
    final templates = _expenseService.templates;

    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.payments_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Catatan Biaya Pengeluaran' : 'Catat Biaya Pengeluaran (OPEX)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        Text(
                          isEditing ? 'Perbarui rincian pengeluaran operasional' : 'Gunakan template cepat atau isi rincian custom',
                          style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Section: Template Cepat (Hanya saat create baru)
                  if (!isEditing) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PILIH DARI TEMPLATE BIAYA CEPAT:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.1),
                        ),
                        Text(
                          '${templates.length} Template',
                          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Horizontal Scrolling Templates
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final tpl = templates[index];
                          final isSelected = _selectedTemplate?.id == tpl.id;

                          return InkWell(
                            onTap: () => _applyTemplate(tpl),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 170,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primarySoft : AppColors.lightSurfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.lightBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getCategoryIcon(tpl.category), size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          tpl.category.label,
                                          style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tpl.title,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tpl.defaultAmount > 0 ? 'Rp ${tpl.defaultAmount.toInt()}' : 'Kustom',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 8),
                  ],

                  // Section: Rincian Biaya (Bisa diedit apa saja)
                  const Text(
                    'RINCIAN PENGELUARAN (BISA DIEDIT SESUAI KEBUTUHAN):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 12),

                  // Judul Biaya
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama / Judul Biaya Pengeluaran',
                      hintText: 'Contoh: Beli Es Batu Tube Bar / Beli Token PLN',
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kategori Biaya
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Akuntansi Biaya',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Nominal Pengeluaran
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.danger),
                    decoration: const InputDecoration(
                      labelText: 'Nominal Biaya Pengeluaran',
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      hintText: 'Contoh: 50000',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Nominal Add Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(label: const Text('+ 10rb'), onPressed: () => _adjustAmount(10000)),
                      ActionChip(label: const Text('+ 25rb'), onPressed: () => _adjustAmount(25000)),
                      ActionChip(label: const Text('+ 50rb'), onPressed: () => _adjustAmount(50000)),
                      ActionChip(label: const Text('+ 100rb'), onPressed: () => _adjustAmount(100000)),
                      ActionChip(label: const Text('+ 500rb'), onPressed: () => _adjustAmount(500000)),
                      ActionChip(label: const Text('Reset'), onPressed: () => setState(() => _amountController.text = '0')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sumber Dana Pembayaran (Kas Laci vs Transfer Bank)
                  const Text(
                    'SUMBER DANA PENGELUARAN:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _paymentSource = 'Kas Laci (Petty Cash)'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: _paymentSource.contains('Laci') ? AppColors.primarySoft : AppColors.lightSurfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _paymentSource.contains('Laci') ? AppColors.primary : AppColors.lightBorder,
                                width: _paymentSource.contains('Laci') ? 2 : 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.point_of_sale, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Kas Laci Kasir (Cash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _paymentSource = 'Transfer Bank / Rekening'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: _paymentSource.contains('Transfer') ? AppColors.accentSoft : AppColors.lightSurfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _paymentSource.contains('Transfer') ? AppColors.accent : AppColors.lightBorder,
                                width: _paymentSource.contains('Transfer') ? 2 : 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance, size: 18, color: AppColors.accent),
                                SizedBox(width: 8),
                                Text('Transfer Rekening', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Catatan / Keterangan
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan / Keterangan Tambahan',
                      hintText: 'Misal: Beli di minimarket seberang, bon terlampir',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // No. Bukti / Kwitansi
                  TextField(
                    controller: _receiptRefController,
                    decoration: const InputDecoration(
                      labelText: 'No. Bukti / Referensi Nota',
                      prefixIcon: Icon(Icons.receipt_outlined),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = _titleController.text.trim();
                        final amount = double.tryParse(_amountController.text);

                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama / judul biaya tidak boleh kosong')),
                          );
                          return;
                        }

                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nominal biaya harus lebih dari Rp 0')),
                          );
                          return;
                        }

                        if (isEditing) {
                          final updated = widget.existingExpense!.copyWith(
                            title: title,
                            category: _category,
                            amount: amount,
                            paymentSource: _paymentSource,
                            notes: _notesController.text.trim(),
                            receiptRef: _receiptRefController.text.trim(),
                          );
                          _expenseService.updateExpense(updated);
                        } else {
                          final newExpense = ExpenseItem(
                            id: 'exp-${const Uuid().v4().substring(0, 8)}',
                            title: title,
                            category: _category,
                            amount: amount,
                            date: DateTime.now(),
                            paymentSource: _paymentSource,
                            notes: _notesController.text.trim(),
                            recordedBy: 'Kasir / Owner',
                            receiptRef: _receiptRefController.text.trim(),
                          );
                          _expenseService.addExpense(newExpense);
                        }

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pengeluaran "$title" sebesar Rp ${amount.toInt()} berhasil disimpan!'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      },
                      child: Text(isEditing ? 'Simpan Perubahan Biaya' : 'Simpan Biaya Pengeluaran'),
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
