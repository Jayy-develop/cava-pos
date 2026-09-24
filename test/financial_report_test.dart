import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/features/financial_report/domain/financial_report_data.dart';
import 'package:cava_pos/features/financial_report/services/financial_export_service.dart';

void main() {
  group('FinancialReportData Tests', () {
    test('Daily financial report data calculates correct margins and net profit', () {
      final date = DateTime(2026, 9, 11);
      final report = FinancialReportData.daily(date);

      expect(report.periodType, ReportPeriodType.daily);
      expect(report.grossSales, greaterThan(0));
      expect(report.netSales, equals(report.grossSales - report.discounts));
      expect(report.grossProfit, equals(report.netSales - report.totalCogs));
      expect(report.netOperatingProfit, equals(report.grossProfit - report.totalOpex));
      expect(report.grossMarginPercent, closeTo((report.grossProfit / report.netSales) * 100, 0.01));
      expect(report.netProfitMarginPercent, closeTo((report.netOperatingProfit / report.netSales) * 100, 0.01));
      expect(report.periodLabel, contains('11'));
      expect(report.periodLabel, contains('2026'));
    });

    test('Monthly financial report data aggregates properly', () {
      final report = FinancialReportData.monthly(9, 2026);

      expect(report.periodType, ReportPeriodType.monthly);
      expect(report.netSales, greaterThan(100000000)); // ~230jt+
      expect(report.grossProfit, greaterThan(report.totalOpex));
      expect(report.netOperatingProfit, greaterThan(0));
      expect(report.periodLabel, contains('September 2026'));
    });

    test('Yearly financial report data aggregates properly', () {
      final report = FinancialReportData.yearly(2026);

      expect(report.periodType, ReportPeriodType.yearly);
      expect(report.netSales, greaterThan(1000000000)); // ~2.8 Miliar+
      expect(report.periodLabel, contains('Tahun 2026'));
    });
  });

  group('FinancialExportService Tests', () {
    test('generatePdfReport produces non-empty Uint8List with valid PDF header', () async {
      final report = FinancialReportData.daily(DateTime(2026, 9, 11));
      final bytes = await FinancialExportService.generatePdfReport(report);

      expect(bytes, isNotEmpty);
      // Valid PDF files begin with '%PDF'
      final header = String.fromCharCodes(bytes.take(4));
      expect(header, equals('%PDF'));
    });

    test('generateExcelCsv produces well-formed CSV with financial line items', () {
      final report = FinancialReportData.monthly(9, 2026);
      final csv = FinancialExportService.generateExcelCsv(report);

      expect(csv, isNotEmpty);
      expect(csv, contains('CAVA SPECIALTY COFFEE'));
      expect(csv, contains('LAPORAN LABA RUGI'));
      expect(csv, contains('1. PENDAPATAN (REVENUE)'));
      expect(csv, contains('2. BIAYA POKOK PENJUALAN (HPP / COGS)'));
      expect(csv, contains('3. LABA KOTOR (GROSS PROFIT)'));
      expect(csv, contains('4. BIAYA OPERASIONAL (OPEX)'));
      expect(csv, contains('5. LABA BERSIH OPERASIONAL (NET PROFIT)'));
      expect(csv, contains('September 2026'));
    });
  });
}
