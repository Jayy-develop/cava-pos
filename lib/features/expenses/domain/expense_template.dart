import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'expense_item.dart';

class ExpenseTemplate extends Equatable {
  final String id;
  final String title;
  final ExpenseCategory category;
  final double defaultAmount;
  final String defaultPaymentSource;
  final String defaultNotes;
  final String iconCode;

  const ExpenseTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultAmount,
    this.defaultPaymentSource = 'Kas Laci (Petty Cash)',
    this.defaultNotes = '',
    this.iconCode = 'receipt',
  });

  ExpenseItem toExpenseItem({double? customAmount, String? customNotes, String? recordedBy}) {
    return ExpenseItem(
      id: 'exp-${const Uuid().v4().substring(0, 8)}',
      title: title,
      category: category,
      amount: customAmount ?? defaultAmount,
      date: DateTime.now(),
      paymentSource: defaultPaymentSource,
      notes: customNotes ?? defaultNotes,
      recordedBy: recordedBy ?? 'Arya (Kasir)',
      receiptRef: 'RCP-EXP-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
  }

  ExpenseTemplate copyWith({
    String? id,
    String? title,
    ExpenseCategory? category,
    double? defaultAmount,
    String? defaultPaymentSource,
    String? defaultNotes,
    String? iconCode,
  }) {
    return ExpenseTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      defaultPaymentSource: defaultPaymentSource ?? this.defaultPaymentSource,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  static const List<ExpenseTemplate> defaultTemplates = [
    // 1. Bahan Baku & Dapur Cepat
    ExpenseTemplate(
      id: 'tpl_ice',
      title: 'Beli Es Batu Kristal (Tube)',
      category: ExpenseCategory.bahanDapur,
      defaultAmount: 25000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Beli 2 kantong es batu kristal tube untuk bar',
      iconCode: 'ac_unit',
    ),
    ExpenseTemplate(
      id: 'tpl_water_gallon',
      title: 'Isi Ulang Air Mineral Galon Bar',
      category: ExpenseCategory.bahanDapur,
      defaultAmount: 22000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Isi ulang 1 galon Aqua untuk persiapan seduh kopi manual',
      iconCode: 'local_drink',
    ),
    ExpenseTemplate(
      id: 'tpl_lpg_gas',
      title: 'Tabung Gas LPG 12kg Dapur',
      category: ExpenseCategory.utilitas,
      defaultAmount: 215000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Refill gas LPG dapur memasak pasta & snack',
      iconCode: 'propane_tank',
    ),

    // 2. Utilitas & Tagihan Rutin
    ExpenseTemplate(
      id: 'tpl_token_pln',
      title: 'Beli Token Listrik PLN Kafe',
      category: ExpenseCategory.utilitas,
      defaultAmount: 500000,
      defaultPaymentSource: 'Transfer Bank / Rekening',
      defaultNotes: 'Token listrik PLN daya 3500VA operasional mesin espresso',
      iconCode: 'bolt',
    ),
    ExpenseTemplate(
      id: 'tpl_wifi_internet',
      title: 'Tagihan Internet WiFi & Cloud POS',
      category: ExpenseCategory.utilitas,
      defaultAmount: 385000,
      defaultPaymentSource: 'Transfer Bank / Rekening',
      defaultNotes: 'Paket internet fiber optic 100Mbps untuk tamu & POS',
      iconCode: 'wifi',
    ),

    // 3. Operasional & Perlengkapan Harian
    ExpenseTemplate(
      id: 'tpl_thermal_paper',
      title: 'Kertas Struk Thermal Roll (Pack)',
      category: ExpenseCategory.operasional,
      defaultAmount: 75000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Beli 10 roll kertas thermal 58mm untuk printer kasir',
      iconCode: 'receipt_long',
    ),
    ExpenseTemplate(
      id: 'tpl_cleaning_supplies',
      title: 'Sabun Cuci Piring, Tissue, & Plastik',
      category: ExpenseCategory.operasional,
      defaultAmount: 65000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Sunlight kemasan pouch, tissue meja tamu, dan plastik sampah hitam',
      iconCode: 'cleaning_services',
    ),

    // 4. Perawatan & Servis Mesin
    ExpenseTemplate(
      id: 'tpl_espresso_service',
      title: 'Servis / Maintenance Mesin Espresso',
      category: ExpenseCategory.maintenance,
      defaultAmount: 350000,
      defaultPaymentSource: 'Transfer Bank / Rekening',
      defaultNotes: 'Descaling rutin, ganti gasket shower screen & seal group head',
      iconCode: 'build',
    ),

    // 5. Gaji & Uang Makan Lembur
    ExpenseTemplate(
      id: 'tpl_meal_overtime',
      title: 'Uang Makan & Lembur Barista Shift Malam',
      category: ExpenseCategory.gajiUpah,
      defaultAmount: 50000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Uang makan lembur barista saat weekend rush hour',
      iconCode: 'payments',
    ),

    // 6. Sewa & Iuran Lingkungan
    ExpenseTemplate(
      id: 'tpl_security_waste',
      title: 'Iuran Kebersihan & Keamanan Ruko',
      category: ExpenseCategory.sewaIuran,
      defaultAmount: 150000,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Iuran bulanan pengangkutan sampah & paguyuban ruko',
      iconCode: 'security',
    ),

    // 7. Promosi & Marketing
    ExpenseTemplate(
      id: 'tpl_ig_marketing',
      title: 'Promosi Iklan Instagram / Media Sosial',
      category: ExpenseCategory.marketing,
      defaultAmount: 200000,
      defaultPaymentSource: 'Transfer Bank / Rekening',
      defaultNotes: 'Boost post event live music & promo diskon akhir pekan',
      iconCode: 'campaign',
    ),

    // 8. Pengeluaran Kustom Bebas
    ExpenseTemplate(
      id: 'tpl_custom',
      title: 'Biaya Kustom Lainnya (Bebas Diedit)',
      category: ExpenseCategory.lainnya,
      defaultAmount: 0,
      defaultPaymentSource: 'Kas Laci (Petty Cash)',
      defaultNotes: 'Catatan pengeluaran lainnya sesuai kebutuhan',
      iconCode: 'more_horiz',
    ),
  ];

  @override
  List<Object?> get props => [id, title, category, defaultAmount, defaultPaymentSource, defaultNotes, iconCode];
}
