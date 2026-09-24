import 'package:equatable/equatable.dart';

enum ReportPeriodType { daily, monthly, yearly }

class FinancialReportData extends Equatable {
  final ReportPeriodType periodType;
  final DateTime selectedDate; // Used for day, month/year, or year
  final String periodLabel;

  // Revenues
  final double grossSales;
  final double discounts;
  final double netSales; // grossSales - discounts

  // COGS (HPP)
  final double coffeeBeansCost;
  final double milkDairyOatCost;
  final double syrupsAndSugarCost;
  final double foodAndPastryCost;
  final double packagingCost;
  final double totalCogs;

  // Gross Profit
  final double grossProfit; // netSales - totalCogs
  final double grossMarginPercent; // (grossProfit / netSales) * 100

  // OPEX (Beban Operasional)
  final double employeeSalaries;
  final double electricityAndWater;
  final double rentExpense;
  final double maintenanceAndSupplies;
  final double internetAndMarketing;
  final double totalOpex;

  // Net Profit (Laba Bersih)
  final double netOperatingProfit; // grossProfit - totalOpex
  final double netProfitMarginPercent; // (netOperatingProfit / netSales) * 100

  // Non-Revenue Collections (Taxes & Services)
  final double pb1TaxCollected; // 10%
  final double serviceChargeCollected; // 5%

  // Cash Flow
  final double cashReceived;
  final double digitalPaymentsReceived; // QRIS, Debit, E-Wallet
  final int totalTransactions;

  const FinancialReportData({
    required this.periodType,
    required this.selectedDate,
    required this.periodLabel,
    required this.grossSales,
    required this.discounts,
    required this.netSales,
    required this.coffeeBeansCost,
    required this.milkDairyOatCost,
    required this.syrupsAndSugarCost,
    required this.foodAndPastryCost,
    required this.packagingCost,
    required this.totalCogs,
    required this.grossProfit,
    required this.grossMarginPercent,
    required this.employeeSalaries,
    required this.electricityAndWater,
    required this.rentExpense,
    required this.maintenanceAndSupplies,
    required this.internetAndMarketing,
    required this.totalOpex,
    required this.netOperatingProfit,
    required this.netProfitMarginPercent,
    required this.pb1TaxCollected,
    required this.serviceChargeCollected,
    required this.cashReceived,
    required this.digitalPaymentsReceived,
    required this.totalTransactions,
  });

  /// Generate sample daily financial report
  factory FinancialReportData.daily(DateTime date) {
    const gross = 8420000.0;
    const disc = 320000.0;
    const net = gross - disc; // 8.100.000

    // COGS
    const coffee = 756000.0;
    const milk = 920000.0;
    const syrups = 380000.0;
    const food = 840000.0;
    const pack = 210000.0;
    const cogs = coffee + milk + syrups + food + pack; // 3.106.000

    const gp = net - cogs; // 4.994.000
    final gpPct = (gp / net) * 100; // ~61.6%

    // Daily allocated OPEX
    const salary = 850000.0; // 3 staff daily
    const util = 220000.0; // Electricity & water daily
    const rent = 350000.0; // Daily rent allocation
    const maint = 75000.0;
    const mkt = 50000.0;
    const opex = salary + util + rent + maint + mkt; // 1.545.000

    const netProfit = gp - opex; // 3.449.000
    final netPct = (netProfit / net) * 100; // ~42.5%

    const tax = net * 0.10; // 810.000
    const service = net * 0.05; // 405.000

    const cash = 2450000.0;
    const digital = (net + tax + service) - cash;

    return FinancialReportData(
      periodType: ReportPeriodType.daily,
      selectedDate: date,
      periodLabel: '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      grossSales: gross,
      discounts: disc,
      netSales: net,
      coffeeBeansCost: coffee,
      milkDairyOatCost: milk,
      syrupsAndSugarCost: syrups,
      foodAndPastryCost: food,
      packagingCost: pack,
      totalCogs: cogs,
      grossProfit: gp,
      grossMarginPercent: gpPct,
      employeeSalaries: salary,
      electricityAndWater: util,
      rentExpense: rent,
      maintenanceAndSupplies: maint,
      internetAndMarketing: mkt,
      totalOpex: opex,
      netOperatingProfit: netProfit,
      netProfitMarginPercent: netPct,
      pb1TaxCollected: tax,
      serviceChargeCollected: service,
      cashReceived: cash,
      digitalPaymentsReceived: digital,
      totalTransactions: 84,
    );
  }

  /// Generate sample monthly financial report
  factory FinancialReportData.monthly(int month, int year) {
    const double multiplier = 30.0;
    final daily = FinancialReportData.daily(DateTime(year, month, 1));

    final gross = daily.grossSales * multiplier;
    final disc = daily.discounts * multiplier;
    final net = gross - disc;

    final cogs = daily.totalCogs * multiplier;
    final gp = net - cogs;
    final gpPct = (gp / net) * 100;

    final opex = daily.totalOpex * multiplier;
    final netProfit = gp - opex;
    final netPct = (netProfit / net) * 100;

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return FinancialReportData(
      periodType: ReportPeriodType.monthly,
      selectedDate: DateTime(year, month, 1),
      periodLabel: '${months[month - 1]} $year',
      grossSales: gross,
      discounts: disc,
      netSales: net,
      coffeeBeansCost: daily.coffeeBeansCost * multiplier,
      milkDairyOatCost: daily.milkDairyOatCost * multiplier,
      syrupsAndSugarCost: daily.syrupsAndSugarCost * multiplier,
      foodAndPastryCost: daily.foodAndPastryCost * multiplier,
      packagingCost: daily.packagingCost * multiplier,
      totalCogs: cogs,
      grossProfit: gp,
      grossMarginPercent: gpPct,
      employeeSalaries: daily.employeeSalaries * multiplier,
      electricityAndWater: daily.electricityAndWater * multiplier,
      rentExpense: daily.rentExpense * multiplier,
      maintenanceAndSupplies: daily.maintenanceAndSupplies * multiplier,
      internetAndMarketing: daily.internetAndMarketing * multiplier,
      totalOpex: opex,
      netOperatingProfit: netProfit,
      netProfitMarginPercent: netPct,
      pb1TaxCollected: daily.pb1TaxCollected * multiplier,
      serviceChargeCollected: daily.serviceChargeCollected * multiplier,
      cashReceived: daily.cashReceived * multiplier,
      digitalPaymentsReceived: daily.digitalPaymentsReceived * multiplier,
      totalTransactions: (daily.totalTransactions * multiplier).toInt(),
    );
  }

  /// Generate sample yearly financial report
  factory FinancialReportData.yearly(int year) {
    const double multiplier = 12.0;
    final monthly = FinancialReportData.monthly(1, year);

    final gross = monthly.grossSales * multiplier;
    final disc = monthly.discounts * multiplier;
    final net = gross - disc;

    final cogs = monthly.totalCogs * multiplier;
    final gp = net - cogs;
    final gpPct = (gp / net) * 100;

    final opex = monthly.totalOpex * multiplier;
    final netProfit = gp - opex;
    final netPct = (netProfit / net) * 100;

    return FinancialReportData(
      periodType: ReportPeriodType.yearly,
      selectedDate: DateTime(year, 1, 1),
      periodLabel: 'Tahun $year',
      grossSales: gross,
      discounts: disc,
      netSales: net,
      coffeeBeansCost: monthly.coffeeBeansCost * multiplier,
      milkDairyOatCost: monthly.milkDairyOatCost * multiplier,
      syrupsAndSugarCost: monthly.syrupsAndSugarCost * multiplier,
      foodAndPastryCost: monthly.foodAndPastryCost * multiplier,
      packagingCost: monthly.packagingCost * multiplier,
      totalCogs: cogs,
      grossProfit: gp,
      grossMarginPercent: gpPct,
      employeeSalaries: monthly.employeeSalaries * multiplier,
      electricityAndWater: monthly.electricityAndWater * multiplier,
      rentExpense: monthly.rentExpense * multiplier,
      maintenanceAndSupplies: monthly.maintenanceAndSupplies * multiplier,
      internetAndMarketing: monthly.internetAndMarketing * multiplier,
      totalOpex: opex,
      netOperatingProfit: netProfit,
      netProfitMarginPercent: netPct,
      pb1TaxCollected: monthly.pb1TaxCollected * multiplier,
      serviceChargeCollected: monthly.serviceChargeCollected * multiplier,
      cashReceived: monthly.cashReceived * multiplier,
      digitalPaymentsReceived: monthly.digitalPaymentsReceived * multiplier,
      totalTransactions: (monthly.totalTransactions * multiplier).toInt(),
    );
  }

  @override
  List<Object?> get props => [periodType, selectedDate, periodLabel, netSales, totalCogs, totalOpex, netOperatingProfit];
}
