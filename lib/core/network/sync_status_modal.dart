import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cloud_sync_service.dart';
import '../constants/app_colors.dart';

class SyncStatusModal extends StatefulWidget {
  const SyncStatusModal({super.key});

  @override
  State<SyncStatusModal> createState() => _SyncStatusModalState();
}

class _SyncStatusModalState extends State<SyncStatusModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _syncService = CloudSyncService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _syncService.addListener(_onSyncUpdate);
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onSyncUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _syncService.isOnline;
    final isSyncing = _syncService.isSyncing;
    final pendingCount = _syncService.pendingOrdersCount;
    final lastSync = DateFormat('HH:mm:ss WIB').format(_syncService.lastSyncTime);

    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
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
                      color: isOnline ? AppColors.accentSoft : AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      color: isOnline ? AppColors.accent : AppColors.danger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Koneksi Cloud Database: Online' : 'Koneksi Cloud: Mode Offline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOnline ? AppColors.accent : AppColors.danger,
                          ),
                        ),
                        Text(
                          isOnline
                              ? 'Terhubung ke ${_syncService.databaseProvider}'
                              : 'Transaksi disimpan di Database Lokal (SQLite / Cache)',
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

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.lightTextSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.sync_rounded, size: 18), text: 'Status & Sinkronisasi'),
                Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'Panduan Integrasi Database'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Live Status & Simulation
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Status Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Provider Database:',
                              _syncService.databaseProvider,
                              icon: Icons.storage_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Endpoint Cloud URL:',
                              _syncService.databaseEndpoint,
                              icon: Icons.link_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Terakhir Sinkronisasi:',
                              lastSync,
                              icon: Icons.access_time_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Antrean Offline Pending:',
                              pendingCount == 0 ? 'Semua Tersinkron (0)' : '$pendingCount Transaksi Tertunda',
                              icon: Icons.queue_rounded,
                              highlightColor: pendingCount > 0 ? AppColors.warning : AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Offline Simulation Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.primarySoft.withValues(alpha: 0.5) : AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isOnline ? AppColors.primary.withValues(alpha: 0.3) : AppColors.warning,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOnline ? 'Simulasi: Terkoneksi Internet' : 'Simulasi: Internet Terputus (Offline)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOnline
                                        ? 'Matikan koneksi untuk menguji POS menjual tanpa internet.'
                                        : 'Aplikasi beroperasi normal menggunakan database lokal!',
                                    style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isOnline,
                              activeThumbColor: AppColors.accent,
                              onChanged: (_) => _syncService.toggleConnectivity(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Manual Trigger Buttons
                      Row(
                        children: [
                          if (!isOnline)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _syncService.recordOfflineTransaction('sim-${DateTime.now().millisecondsSinceEpoch}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('+1 Transaksi offline tersimpan di database lokal')),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: const Text('+ Simpan Order Offline', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          if (!isOnline) const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isOnline && !isSyncing
                                  ? () async {
                                      await _syncService.syncNow();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Database lokal berhasil disinkronkan ke Supabase Cloud!'),
                                            backgroundColor: AppColors.accent,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              icon: isSyncing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.cloud_upload_rounded, size: 16),
                              label: Text(
                                isSyncing ? 'Sedang Sinkron...' : 'Sinkronkan Sekarang',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Tab 2: Architecture & Integration Guide
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStepCard(
                        '1. Arsitektur 2 Role (Kasir vs Owner)',
                        '• Role Kasir: Operasional cepat, order meja, split bill, cetak struk ESC/POS, lapor kas shift. Pembatasan: Tidak bisa ubah harga atau buka laporan keuangan tanpa PIN Owner.\n'
                        '• Role Owner: Akses penuh analitik penjualan, laporan laba rugi P&L komprehensif, ubah harga & foto menu, serta audit HPP.',
                        Icons.admin_panel_settings_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildStepCard(
                        '2. Arsitektur Offline-First Database (Drift / SQLite)',
                        '• Setiap kali kasir tap "Selesaikan Pesanan", data tersimpan dulu di Local DB SQLite/Drift/Hive dalam hitungan milidetik (Zero Latency).\n'
                        '• Jika internet terputus, kasir tetap lancar mencetak struk thermal dan melayani antrean tanpa takut loading.',
                        Icons.offline_bolt_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildStepCard(
                        '3. Koneksi ke Cloud Database (Supabase / Firebase)',
                        '• Saat internet aktif, background worker / sync engine mem-push antrean lokal ke remote database:\n'
                        '  - Tabel users (id, name, role, pin_hash)\n'
                        '  - Tabel products (id, name, base_price, cost_price, image_url)\n'
                        '  - Tabel orders & order_items (id, total, payment_type, items)\n'
                        '• Mendukung multi-device: Pesanan dari tablet kasir langsung muncul di layar dapur (Kitchen Display) secara Realtime via WebSocket Supabase / Firebase Snapshot.',
                        Icons.cloud_sync_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon, Color? highlightColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: highlightColor ?? AppColors.lightTextSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlightColor ?? AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}
