import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/expense_item.dart';
import '../../domain/expense_template.dart';
import '../../services/expense_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ManageTemplatesDialog extends StatefulWidget {
  const ManageTemplatesDialog({super.key});

  @override
  State<ManageTemplatesDialog> createState() => _ManageTemplatesDialogState();
}

class _ManageTemplatesDialogState extends State<ManageTemplatesDialog> {
  final _expenseService = ExpenseService();

  @override
  void initState() {
    super.initState();
    _expenseService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _expenseService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _openEditTemplateModal({ExpenseTemplate? templateToEdit}) {
    final isNew = templateToEdit == null;
    final titleController = TextEditingController(text: templateToEdit?.title ?? '');
    final amountController = TextEditingController(
      text: templateToEdit != null && templateToEdit.defaultAmount > 0
          ? templateToEdit.defaultAmount.toInt().toString()
          : '',
    );
    final notesController = TextEditingController(text: templateToEdit?.defaultNotes ?? '');
    ExpenseCategory category = templateToEdit?.category ?? ExpenseCategory.operasional;
    String paymentSource = templateToEdit?.defaultPaymentSource ?? 'Kas Laci (Petty Cash)';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.lightSurface,
            title: Row(
              children: [
                Icon(isNew ? Icons.add_box_rounded : Icons.edit_note_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(isNew ? 'Tambah Template Biaya' : 'Edit Template Biaya', style: const TextStyle(fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Template Biaya',
                      hintText: 'Contoh: Beli Kopi Sachet / Galon Air',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Kategori Biaya'),
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal Default (Rp)',
                      hintText: '0 (atau nominal acuan)',
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: paymentSource,
                    decoration: const InputDecoration(labelText: 'Sumber Dana Default'),
                    items: const [
                      DropdownMenuItem(value: 'Kas Laci (Petty Cash)', child: Text('Kas Laci Kasir (Cash)')),
                      DropdownMenuItem(value: 'Transfer Bank / Rekening', child: Text('Transfer Bank / Rekening')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentSource = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan Default',
                      hintText: 'Misal: Beli es batu kristal 2 sak untuk bar',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0.0;

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama template tidak boleh kosong')),
                    );
                    return;
                  }

                  if (isNew) {
                    final newTpl = ExpenseTemplate(
                      id: 'tpl-${const Uuid().v4().substring(0, 8)}',
                      title: title,
                      category: category,
                      defaultAmount: amount,
                      defaultPaymentSource: paymentSource,
                      defaultNotes: notesController.text.trim(),
                    );
                    _expenseService.addTemplate(newTpl);
                  } else {
                    final updated = templateToEdit.copyWith(
                      title: title,
                      category: category,
                      defaultAmount: amount,
                      defaultPaymentSource: paymentSource,
                      defaultNotes: notesController.text.trim(),
                    );
                    _expenseService.updateTemplate(updated);
                  }

                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "$title" berhasil ${isNew ? "dibuat" : "diperbarui"}!'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                },
                child: const Text('Simpan Template'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = _expenseService.templates;

    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
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
                    child: const Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Template Biaya Kafe',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        Text(
                          'Edit template bawaan atau buat template kustom baru',
                          style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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

            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar ${templates.length} Template Aktif',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openEditTemplateModal(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Buat Template Baru', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // List of Templates
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: templates.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tpl = templates[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 18),
                    ),
                    title: Text(
                      tpl.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${tpl.category.label} • Default: ${tpl.defaultAmount > 0 ? CurrencyFormatter.format(tpl.defaultAmount) : "Kustom"} • ${tpl.defaultPaymentSource}',
                      style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          tooltip: 'Edit Template',
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          onPressed: () => _openEditTemplateModal(templateToEdit: tpl),
                        ),
                        // Delete button
                        if (templates.length > 1)
                          IconButton(
                            tooltip: 'Hapus Template',
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () {
                              _expenseService.deleteTemplate(tpl.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Template "${tpl.title}" dihapus')),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Footer close
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Selesai'),
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
