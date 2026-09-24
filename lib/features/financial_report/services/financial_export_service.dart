import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/financial_report_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/file_download_helper.dart';

class FinancialExportService {
  FinancialExportService._();

  /// Generates a professional PDF Financial Report
  static Future<Uint8List> generatePdfReport(FinancialReportData data) async {
    final pdf = pw.Document();

    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    try {
      if (DateFormat.localeExists('id_ID')) {
        dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
      }
    } catch (_) {}
    final String printTime = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CAVA SPECIALTY COFFEE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber800,
                      ),
                    ),
                    pw.Text('Roastery & Eatery | Jl. Senopati No. 88, Jakarta Selatan',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text('NPWPD: 01.234.567.8-012.000 | Izin Usaha Restoran: 912026888',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber100,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'LAPORAN LABA RUGI',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Periode: ${data.periodLabel}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Dicetak: $printTime WIB', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.amber800),
            pw.SizedBox(height: 12),

            // Summary Highlights Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfKpi('Pendapatan Bersih', CurrencyFormatter.format(data.netSales)),
                  _buildPdfKpi('Total HPP (COGS)', CurrencyFormatter.format(data.totalCogs)),
                  _buildPdfKpi('Laba Kotor (${data.grossMarginPercent.toStringAsFixed(1)}%)', CurrencyFormatter.format(data.grossProfit)),
                  _buildPdfKpi('Laba Bersih (${data.netProfitMarginPercent.toStringAsFixed(1)}%)', CurrencyFormatter.format(data.netOperatingProfit)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Financial P&L Statement Table
            pw.Text('RINCIAN LAPORAN KEUANGAN (IDR)',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(6),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                // 1. REVENUE
                _buildPdfHeaderRow('1. PENDAPATAN PENJUALAN (REVENUE)'),
                _buildPdfRow('   Penjualan Kotor Makanan & Minuman (Gross Sales)', CurrencyFormatter.format(data.grossSales)),
                _buildPdfRow('   Potongan Diskon & Promosi Kasir', '- ${CurrencyFormatter.format(data.discounts)}', isNegative: true),
                _buildPdfSubtotalRow('   Total Pendapatan Bersih (Net Sales)', CurrencyFormatter.format(data.netSales)),

                // 2. COGS (HPP)
                _buildPdfHeaderRow('2. HARGA POKOK PENJUALAN (HPP / COGS)'),
                _buildPdfRow('   Bahan Baku Kopi (House Blend Arabica Gayo & Flores)', CurrencyFormatter.format(data.coffeeBeansCost)),
                _buildPdfRow('   Bahan Baku Susu (Fresh Milk & Oat Milk Barista)', CurrencyFormatter.format(data.milkDairyOatCost)),
                _buildPdfRow('   Gula Aren Organik, Sirup Karamel, & Perasa', CurrencyFormatter.format(data.syrupsAndSugarCost)),
                _buildPdfRow('   Bahan Makanan (Fettuccine, Truffle Oil, Dori, dll.)', CurrencyFormatter.format(data.foodAndPastryCost)),
                _buildPdfRow('   Kemasan Takeaway (Paper Cup, Sedotan, Seal, Kantong)', CurrencyFormatter.format(data.packagingCost)),
                _buildPdfSubtotalRow('   Total Biaya HPP (COGS)', CurrencyFormatter.format(data.totalCogs)),

                // 3. GROSS PROFIT
                _buildPdfHighlightRow('3. LABA KOTOR (GROSS PROFIT)', CurrencyFormatter.format(data.grossProfit), 'Margin: ${data.grossMarginPercent.toStringAsFixed(1)}%'),

                // 4. OPEX
                _buildPdfHeaderRow('4. BEBAN OPERASIONAL (OPEX)'),
                _buildPdfRow('   Gaji Barista, Kasir, & Kitchen Staff', CurrencyFormatter.format(data.employeeSalaries)),
                _buildPdfRow('   Utilitas (Listrik PLN, Air Bersih PDAM, Gas LPG)', CurrencyFormatter.format(data.electricityAndWater)),
                _buildPdfRow('   Alokasi Biaya Sewa Lokasi Usaha', CurrencyFormatter.format(data.rentExpense)),
                _buildPdfRow('   Pemeliharaan Mesin Espresso, Grinder, & Restoran', CurrencyFormatter.format(data.maintenanceAndSupplies)),
                _buildPdfRow('   Internet WiFi Kafe, Software POS, & Promosi Sosmed', CurrencyFormatter.format(data.internetAndMarketing)),
                _buildPdfSubtotalRow('   Total Beban Operasional (OPEX)', CurrencyFormatter.format(data.totalOpex)),

                // 5. NET OPERATING PROFIT
                _buildPdfHighlightRow(
                  '5. LABA BERSIH OPERASIONAL (NET PROFIT)',
                  CurrencyFormatter.format(data.netOperatingProfit),
                  'Net Margin: ${data.netProfitMarginPercent.toStringAsFixed(1)}%',
                  isNetProfit: true,
                ),

                // 6. TAX & SERVICE (Non-revenue)
                _buildPdfHeaderRow('6. TITIPAN KONSUMEN & PAJAK DAERAH (NON-REVENUE)'),
                _buildPdfRow('   Pajak Restoran PB1 (10% disetor ke Bapenda Pemda)', CurrencyFormatter.format(data.pb1TaxCollected)),
                _buildPdfRow('   Service Charge (5% didistribusikan ke staf layanan)', CurrencyFormatter.format(data.serviceChargeCollected)),

                // 7. CASH FLOW
                _buildPdfHeaderRow('7. REKONSILIASI KAS & ARUS DANA'),
                _buildPdfRow('   Penerimaan Tunai Fisik di Laci Kasir (Cash)', CurrencyFormatter.format(data.cashReceived)),
                _buildPdfRow('   Penerimaan Non-Tunai Masuk Rekening (QRIS & EDC)', CurrencyFormatter.format(data.digitalPaymentsReceived)),
                _buildPdfRow('   Total Volume Transaksi Masuk', '${data.totalTransactions} Struk Selesai'),
              ],
            ),
            pw.SizedBox(height: 24),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Dibuat Oleh,', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 40),
                    pw.Text('( Arya Pratama )', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Kasir Kepala / Supervisor', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Disetujui & Diperiksa Oleh,', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 40),
                    pw.Text('( Budi Santoso )', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Business Owner & Managing Director', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Center(
              child: pw.Text(
                'Laporan ini digenerate secara otomatis oleh Cava POS Cloud Architecture - Data Valid & Terverifikasi',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Generates CSV spreadsheet format for Microsoft Excel & Google Sheets
  static String generateExcelCsv(FinancialReportData data) {
    final List<List<dynamic>> rows = [
      ['CAVA SPECIALTY COFFEE & EATERY'],
      ['LAPORAN LABA RUGI & KEUANGAN'],
      ['Periode:', data.periodLabel],
      ['Tanggal Ekspor:', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())],
      ['Mata Uang:', 'Indonesian Rupiah (IDR)'],
      [],
      ['KATEGORI KEUANGAN', 'NOMINAL (IDR)', 'CATATAN / MARGIN'],
      ['1. PENDAPATAN (REVENUE)', '', ''],
      ['   Penjualan Kotor (Gross Sales)', data.grossSales, 'Total pesanan sebelum diskon'],
      ['   Diskon & Promo Item/Member', -data.discounts, 'Pengurangan langsung'],
      ['   TOTAL PENDAPATAN BERSIH (NET SALES)', data.netSales, 'Dasar kalkulasi laba'],
      [],
      ['2. BIAYA POKOK PENJUALAN (HPP / COGS)', '', ''],
      ['   Biji Kopi Espresso Arabica', data.coffeeBeansCost, 'Gramatur resep terserap'],
      ['   Susu Segar Pasteurisasi & Oat Milk', data.milkDairyOatCost, 'Konsumsi susu per cup'],
      ['   Gula Aren, Sirup, & Perasa', data.syrupsAndSugarCost, 'Add-on bahan pemanis'],
      ['   Bahan Baku Makanan & Pastry', data.foodAndPastryCost, 'Bahan porsi dapur'],
      ['   Kemasan Takeaway & Cup Packaging', data.packagingCost, 'Paper cup, sedotan, bag'],
      ['   TOTAL HPP (COGS)', data.totalCogs, 'Total biaya modal produk'],
      [],
      ['3. LABA KOTOR (GROSS PROFIT)', data.grossProfit, 'Gross Margin: ${data.grossMarginPercent.toStringAsFixed(1)}%'],
      [],
      ['4. BIAYA OPERASIONAL (OPEX)', '', ''],
      ['   Gaji Barista, Kasir, & Kitchen Staff', data.employeeSalaries, 'Alokasi gaji operasional'],
      ['   Listrik PLN, Air PDAM, & Gas LPG', data.electricityAndWater, 'Utilitas operasional'],
      ['   Sewa Tempat Usaha & Lokasi', data.rentExpense, 'Alokasi sewa periode'],
      ['   Pemeliharaan Mesin & Peralatan', data.maintenanceAndSupplies, 'Perawatan rutin grinder/mesin'],
      ['   Internet WiFi & Pemasaran', data.internetAndMarketing, 'Konektivitas & sosmed'],
      ['   TOTAL BEBAN OPERASIONAL (OPEX)', data.totalOpex, 'Total biaya rutin'],
      [],
      ['5. LABA BERSIH OPERASIONAL (NET PROFIT)', data.netOperatingProfit, 'Net Margin: ${data.netProfitMarginPercent.toStringAsFixed(1)}%'],
      [],
      ['6. PAJAK & TITIPAN (NON-REVENUE)', '', ''],
      ['   Pajak Restoran PB1 (10%)', data.pb1TaxCollected, 'Setoran pajak ke Bapenda'],
      ['   Service Charge (5%)', data.serviceChargeCollected, 'Distribusi tip/servis tim'],
      [],
      ['7. ARUS KAS PENJUALAN', '', ''],
      ['   Penerimaan Tunai (Cash)', data.cashReceived, 'Fisik kas di laci kasir'],
      ['   Penerimaan Non-Tunai (QRIS/EDC)', data.digitalPaymentsReceived, 'Masuk rekening bank'],
      ['   Total Struk Transaksi', data.totalTransactions, 'Jumlah transaksi berhasil'],
    ];

    return const ListToCsvConverter().convert(rows);
  }

  /// Triggers instant browser download for Excel (.csv)
  static void exportToExcel(FinancialReportData data) {
    final csvString = generateExcelCsv(data);
    final String cleanPeriod = data.periodLabel.replaceAll(' ', '_').replaceAll('/', '-');
    final fileName = 'Laporan_Keuangan_Cava_$cleanPeriod.csv';

    FileDownloadHelper.downloadCsv(
      csvContent: csvString,
      fileName: fileName,
    );
  }

  /// Triggers instant browser download for PDF (.pdf)
  static Future<void> exportToPdf(FinancialReportData data) async {
    final pdfBytes = await generatePdfReport(data);
    final String cleanPeriod = data.periodLabel.replaceAll(' ', '_').replaceAll('/', '-');
    final fileName = 'Laporan_Keuangan_Cava_$cleanPeriod.pdf';

    FileDownloadHelper.download(
      bytes: pdfBytes,
      fileName: fileName,
      mimeType: 'application/pdf',
    );
  }

  // --- PDF Helper Row Widgets ---

  static pw.TableRow _buildPdfHeaderRow(String title) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text('', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.TableRow _buildPdfRow(String label, String value, {bool isNegative = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.normal,
                color: isNegative ? PdfColors.red700 : PdfColors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildPdfSubtotalRow(String label, String value) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildPdfHighlightRow(String label, String value, String note, {bool isNetProfit = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isNetProfit ? PdfColors.green50 : PdfColors.amber50,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: isNetProfit ? PdfColors.green900 : PdfColors.amber900)),
              pw.Text(note, style: pw.TextStyle(fontSize: 8, color: isNetProfit ? PdfColors.green800 : PdfColors.amber800)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: isNetProfit ? PdfColors.green900 : PdfColors.amber900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfKpi(String title, String amount) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(amount, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
      ],
    );
  }
}
