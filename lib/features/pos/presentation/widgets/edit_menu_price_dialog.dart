import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/models/menu_image_preset.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class EditMenuPriceDialog extends StatefulWidget {
  final Product product;

  const EditMenuPriceDialog({super.key, required this.product});

  @override
  State<EditMenuPriceDialog> createState() => _EditMenuPriceDialogState();
}

class _EditMenuPriceDialogState extends State<EditMenuPriceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _imageUrlController;
  final TextEditingController _pinController = TextEditingController();
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.basePrice.toInt().toString());
    _costController = TextEditingController(text: widget.product.costPrice.toInt().toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _isAvailable = widget.product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _imageUrlController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _adjustPrice(double delta) {
    final current = double.tryParse(_priceController.text) ?? widget.product.basePrice;
    final updated = (current + delta).clamp(0.0, 10000000.0);
    setState(() {
      _priceController.text = updated.toInt().toString();
    });
  }

  void _openPresetImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Foto dari Galeri Kafe Cava',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                          ),
                          Text(
                            'Pilihan gambar fotografi kafe HD siap pakai',
                            style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.15,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: MenuImagePreset.presets.length,
                      itemBuilder: (context, index) {
                        final preset = MenuImagePreset.presets[index];
                        final isSelected = _imageUrlController.text == preset.url;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _imageUrlController.text = preset.url;
                            });
                            Navigator.of(ctx).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.lightBorder,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  preset.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.lightSurfaceLight,
                                    child: const Icon(Icons.broken_image, color: AppColors.lightTextMuted),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          preset.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          preset.category,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isOwner = authState.isOwner;

    final currentSellingPrice = double.tryParse(_priceController.text) ?? widget.product.basePrice;
    final currentCostPrice = double.tryParse(_costController.text) ?? widget.product.costPrice;
    final profitMargin = currentSellingPrice - currentCostPrice;
    final marginPercentage = currentSellingPrice > 0 ? (profitMargin / currentSellingPrice) * 100 : 0.0;

    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Menu, Harga, & Foto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'SKU: ${widget.product.sku} • Kategori: ${widget.product.categoryId.toUpperCase()}',
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.lightTextMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name Field
                    const Text(
                      'NAMA MENU',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Nama Menu',
                        prefixIcon: Icon(Icons.drive_file_rename_outline, size: 18),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Product Image Preview & Selector Card
                    const Text(
                      'FOTO & GAMBAR MENU',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          // Image Thumbnail Box
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: AppColors.primarySoft,
                              child: _imageUrlController.text.isNotEmpty
                                  ? Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.coffee_rounded, color: AppColors.primary, size: 32),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.image_outlined, color: AppColors.lightTextMuted, size: 32),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Image Actions & URL
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _openPresetImagePicker,
                                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                                      label: const Text('Pilih dari Galeri Kafe', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_imageUrlController.text.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Hapus Gambar',
                                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                        onPressed: () => setState(() => _imageUrlController.clear()),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _imageUrlController,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Atau tempel URL Gambar (https://...)',
                                    prefixIcon: Icon(Icons.link, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Selling Price Input
                    const Text(
                      'HARGA JUAL KONSUMEN (RP)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        hintText: 'Contoh: 35000',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Quick Adjust Price Chips
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('+ Rp 1.000'),
                          onPressed: () => _adjustPrice(1000),
                        ),
                        ActionChip(
                          label: const Text('+ Rp 2.000'),
                          onPressed: () => _adjustPrice(2000),
                        ),
                        ActionChip(
                          label: const Text('+ Rp 5.000'),
                          onPressed: () => _adjustPrice(5000),
                        ),
                        ActionChip(
                          label: const Text('- Rp 1.000'),
                          onPressed: () => _adjustPrice(-1000),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Cost Price (HPP/COGS) & Profit Margin
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HARGA MODAL (HPP/COGS)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightTextSecondary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _costController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  prefixText: 'Rp ',
                                  hintText: '8500',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Profit Margin Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: profitMargin >= 0 ? AppColors.accentSoft : AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: profitMargin >= 0 ? AppColors.accent : AppColors.danger,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profitMargin >= 0 ? 'ESTIMASI MARGIN LABA' : 'RUGI / NEGATIF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: profitMargin >= 0 ? AppColors.accent : AppColors.danger,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(profitMargin),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: profitMargin >= 0 ? AppColors.accent : AppColors.danger,
                                  ),
                                ),
                                Text(
                                  '${marginPercentage.toStringAsFixed(1)}% dari harga jual',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: profitMargin >= 0 ? AppColors.accent : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Availability Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Ketersediaan Menu',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                _isAvailable ? 'Menu aktif dan dapat dipesan kasir' : 'Stok habis / dinonaktifkan sementara',
                                style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isAvailable,
                            activeThumbColor: AppColors.accent,
                            onChanged: (val) => setState(() => _isAvailable = val),
                          ),
                        ],
                      ),
                    ),

                    // PIN Verification if currently in Kasir role
                    if (!isOwner) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.security, color: AppColors.warning, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Otorisasi Supervisor / Owner Diperlukan',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warning),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Role kasir memerlukan verifikasi PIN Owner untuk mengubah menu dan harga resmi (Default PIN: 8888).',
                              style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'PIN Otorisasi Owner',
                                hintText: '8888',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          final newName = _nameController.text.trim();
                          final newPrice = double.tryParse(_priceController.text);
                          final newCost = double.tryParse(_costController.text);

                          if (newName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama menu tidak boleh kosong')),
                            );
                            return;
                          }

                          if (newPrice == null || newPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harga jual harus berupa nominal valid')),
                            );
                            return;
                          }

                          // Verify PIN if not Owner
                          if (!isOwner) {
                            if (_pinController.text.trim() != '8888') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PIN Owner salah. Perubahan menu ditolak.'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                              return;
                            }
                          }

                          // Dispatch update event to MenuBloc
                          context.read<MenuBloc>().add(
                                UpdateProductPriceEvent(
                                  productId: widget.product.id,
                                  newName: newName,
                                  newPrice: newPrice,
                                  newCostPrice: newCost,
                                  newImageUrl: _imageUrlController.text.trim(),
                                  isAvailable: _isAvailable,
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
