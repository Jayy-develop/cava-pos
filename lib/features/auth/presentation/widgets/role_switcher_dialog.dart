import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/constants/app_colors.dart';

class RoleSwitcherDialog extends StatefulWidget {
  const RoleSwitcherDialog({super.key});

  @override
  State<RoleSwitcherDialog> createState() => _RoleSwitcherDialogState();
}

class _RoleSwitcherDialogState extends State<RoleSwitcherDialog> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      },
      builder: (context, state) {
        final currentRole = state.currentUser.role;

        return Dialog(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.manage_accounts, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Role Pengguna (RBAC)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Ganti role antara Kasir operasional dan Business Owner',
                              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
                const Divider(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Role Option 1: Kasir
                      _buildRoleCard(
                        title: 'Kasir (Cashier)',
                        subtitle: 'Arya Pratama • Shift Operasional Terminal',
                        role: RoleType.cashier,
                        isActive: currentRole == RoleType.cashier,
                        icon: Icons.point_of_sale_rounded,
                        color: AppColors.info,
                        bgColor: AppColors.infoSoft,
                        features: [
                          'Akses cepat katalog menu & order meja',
                          'Kalkulasi transaksi tunai, QRIS, & kembalian',
                          'Cetak struk pelanggan & tiket bar/dapur',
                          'Buka & tutup shift kasir (X/Z report)',
                        ],
                        restrictions: [
                          'Akses analitik omzet & laba dibatasi',
                          'Void transaksi memerlukan PIN supervisor/owner',
                        ],
                        onSelect: () {
                          context.read<AuthBloc>().add(
                                const QuickSwitchRoleEvent(RoleType.cashier),
                              );
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role Option 2: Business Owner
                      _buildRoleCard(
                        title: 'Business Owner',
                        subtitle: 'Budi Santoso • Akses Penuh Manajemen & Analitik',
                        role: RoleType.owner,
                        isActive: currentRole == RoleType.owner,
                        icon: Icons.insights_rounded,
                        color: AppColors.primary,
                        bgColor: AppColors.primarySoft,
                        features: [
                          'Dashboard Omzet Realtime & Gross/Net Sales',
                          'Manajemen Bahan Baku, Resep & COGS/HPP',
                          'Otorisasi Void transaksi tanpa batasan',
                          'Laporan laba kotor, margin, & jam sibuk kafe',
                        ],
                        restrictions: const [],
                        onSelect: () {
                          if (currentRole == RoleType.owner) {
                            Navigator.of(context).pop();
                            return;
                          }
                          // Prompt PIN modal
                          _showPinVerificationDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Role Aktif Saat Ini: ${state.currentUser.role == RoleType.owner ? "Business Owner" : "Kasir"}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.lightTextPrimary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPinVerificationDialog(BuildContext parentContext) {
    final pinCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Verifikasi PIN Owner'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan PIN Owner untuk membuka hak akses analitik dan manajemen kafe.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '••••',
                labelText: 'PIN Owner (Default: 8888)',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinCtrl.text.trim();
              parentContext.read<AuthBloc>().add(
                    SwitchRoleEvent(role: RoleType.owner, pin: pin),
                  );
              Navigator.of(ctx).pop();
              Navigator.of(parentContext).pop();
            },
            child: const Text('Masuk Sebagai Owner'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required RoleType role,
    required bool isActive,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required List<String> features,
    required List<String> restrictions,
    required VoidCallback onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.05) : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : AppColors.lightBorder,
          width: isActive ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppColors.lightSurfaceLight : color,
                  foregroundColor: isActive ? AppColors.lightTextPrimary : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(isActive ? 'Aktif' : 'Pilih Role'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Features List
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.lightTextPrimary)),
                  ),
                ],
              ),
            ),
          ),

          // Restrictions List
          ...restrictions.map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
