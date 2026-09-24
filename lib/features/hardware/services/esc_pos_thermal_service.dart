import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../pos/domain/entities/order.dart';
import '../../../core/utils/currency_formatter.dart';
import 'printer_service.dart';

class EscPosThermalService implements IPrinterService {
  PrinterConnectionStatus _status = PrinterConnectionStatus.disconnected;

  @override
  PrinterConnectionStatus get status => _status;

  @override
  Future<List<PrinterDevice>> scanBluetoothPrinters() async {
    // In production, integrate with flutter_pos_printer_platform or flutter_blue_plus
    return [
      const PrinterDevice(
        id: 'BT_PRINTER_01',
        name: 'RPP02N 58mm Thermal (Cashier)',
        address: '66:22:33:44:55:66',
        isBluetooth: true,
      ),
      const PrinterDevice(
        id: 'NET_PRINTER_01',
        name: 'Epson TM-T82X (Kitchen LAN)',
        address: '192.168.1.200:9100',
        isBluetooth: false,
      ),
    ];
  }

  @override
  Future<bool> connect(PrinterDevice device) async {
    _status = PrinterConnectionStatus.connecting;
    // Simulate socket or bluetooth connection
    await Future.delayed(const Duration(milliseconds: 300));
    _status = PrinterConnectionStatus.connected;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _status = PrinterConnectionStatus.disconnected;
  }

  @override
  Future<bool> printBytes(Uint8List bytes) async {
    // In production: send bytes directly to Bluetooth socket or Raw TCP Socket
    // await socket.add(bytes); await socket.flush();
    return true;
  }

  @override
  Uint8List generateCashDrawerCommand() {
    // ESC p m t1 t2: Kick drawer pin 2 (pulse 50ms, off 500ms)
    return Uint8List.fromList([0x1B, 0x70, 0x00, 0x19, 0xFA]);
  }

  @override
  Uint8List generateCustomerReceipt({
    required Order order,
    PaperSize paperSize = PaperSize.mm58,
    bool openCashDrawer = true,
  }) {
    final int width = paperSize == PaperSize.mm58 ? 32 : 48;
    final buffer = BytesBuilder();

    // 1. Initialize Printer
    buffer.add([0x1B, 0x40]); // ESC @

    // Open cash drawer if requested (usually on cash checkout)
    if (openCashDrawer) {
      buffer.add(generateCashDrawerCommand());
    }

    // 2. Cafe Header (Center Aligned)
    _setAlign(buffer, 1); // Center
    _setDoubleSize(buffer, true);
    buffer.add(_encodeText('CAVA COFFEE\n'));
    _setDoubleSize(buffer, false);
    _setBold(buffer, false);

    buffer.add(_encodeText('Specialty Roastery & Eatery\n'));
    buffer.add(_encodeText('Jl. Senopati No. 88, Jakarta\n'));
    buffer.add(_encodeText('Telp: +62 812-3456-7890\n'));
    buffer.add(_encodeText('WiFi: Cava_Guest / cava2026\n'));
    buffer.add(_encodeText('${'-' * width}\n'));

    // 3. Receipt Metadata (Left Aligned)
    _setAlign(buffer, 0); // Left
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String dateTimeStr = dateFormat.format(order.createdAt);

    buffer.add(_encodeText(_formatTwoColumns('Invoice:', order.orderNumber, width)));
    buffer.add(_encodeText(_formatTwoColumns('Date:', dateTimeStr, width)));
    buffer.add(_encodeText(_formatTwoColumns('Cashier:', order.cashierName, width)));
    buffer.add(_encodeText(_formatTwoColumns(
      'Type:',
      order.orderType == OrderType.dineIn
          ? 'Dine In (${order.tableNumber ?? "-"})'
          : 'Take Away',
      width,
    )));
    if (order.customerName.isNotEmpty && order.customerName != 'Guest') {
      buffer.add(_encodeText(_formatTwoColumns('Customer:', order.customerName, width)));
    }
    buffer.add(_encodeText('${'-' * width}\n'));

    // 4. Line Items
    for (final item in order.items) {
      _setBold(buffer, true);
      final String itemHeader = '${item.quantity}x ${item.productName}';
      final String priceStr = CurrencyFormatter.format(item.grossTotal);
      buffer.add(_encodeText(_formatTwoColumns(itemHeader, priceStr, width)));
      _setBold(buffer, false);

      // Print Variant if any
      if (item.selectedVariant != null) {
        buffer.add(_encodeText('   Variant: ${item.selectedVariant!.name}\n'));
      }

      // Print Modifiers
      for (final mod in item.selectedModifiers) {
        final modPrice = mod.additionalPrice > 0
            ? ' (+${CurrencyFormatter.format(mod.additionalPrice)})'
            : '';
        buffer.add(_encodeText('   + ${mod.name}$modPrice\n'));
      }

      // Print Item Discount if any
      if (item.itemDiscount > 0) {
        buffer.add(_encodeText(_formatTwoColumns(
          '   Discount',
          '-${CurrencyFormatter.format(item.itemDiscount)}',
          width,
        )));
      }

      // Notes
      if (item.notes.isNotEmpty) {
        buffer.add(_encodeText('   *Note: ${item.notes}\n'));
      }
    }
    buffer.add(_encodeText('${'-' * width}\n'));

    // 5. Totals & Tax Calculation Breakdown
    buffer.add(_encodeText(_formatTwoColumns('Subtotal', CurrencyFormatter.format(order.subtotal), width)));

    if (order.orderDiscount > 0) {
      buffer.add(_encodeText(_formatTwoColumns(
        'Discount',
        '-${CurrencyFormatter.format(order.orderDiscount)}',
        width,
      )));
    }

    if (order.serviceChargeAmount > 0) {
      final int scPercent = (order.serviceChargeRate * 100).toInt();
      buffer.add(_encodeText(_formatTwoColumns(
        'Service Charge ($scPercent%)',
        CurrencyFormatter.format(order.serviceChargeAmount),
        width,
      )));
    }

    if (order.taxAmount > 0) {
      final int taxPercent = (order.taxRate * 100).toInt();
      buffer.add(_encodeText(_formatTwoColumns(
        'PB1 ($taxPercent%)',
        CurrencyFormatter.format(order.taxAmount),
        width,
      )));
    }

    if (order.roundingAmount != 0) {
      buffer.add(_encodeText(_formatTwoColumns(
        'Rounding',
        CurrencyFormatter.format(order.roundingAmount),
        width,
      )));
    }

    buffer.add(_encodeText('${'=' * width}\n'));

    // Grand Total (Bold)
    _setBold(buffer, true);
    buffer.add(_encodeText(_formatTwoColumns(
      'GRAND TOTAL',
      CurrencyFormatter.format(order.grandTotal),
      width,
    )));
    _setBold(buffer, false);

    buffer.add(_encodeText('${'-' * width}\n'));

    // 6. Payment Information
    final paymentMethodName = order.paymentMethod?.name.toUpperCase() ?? 'UNPAID';
    buffer.add(_encodeText(_formatTwoColumns('Payment ($paymentMethodName)', CurrencyFormatter.format(order.grandTotal), width)));

    if (order.paymentMethod == PaymentMethod.cash) {
      buffer.add(_encodeText(_formatTwoColumns('Cash Tendered', CurrencyFormatter.format(order.cashReceived), width)));
      buffer.add(_encodeText(_formatTwoColumns('Change Due', CurrencyFormatter.format(order.cashChange), width)));
    }

    buffer.add(_encodeText('${'-' * width}\n'));

    // 7. Footer
    _setAlign(buffer, 1); // Center
    buffer.add(_encodeText('Terima Kasih Atas Kunjungan Anda!\n'));
    buffer.add(_encodeText('Follow IG: @cavacoffee.id\n'));
    buffer.add(_encodeText('Simpan struk ini untuk promo loyalty\n\n'));

    // Feed lines & Cut paper
    buffer.add([0x1B, 0x64, 0x03]); // Feed 3 lines
    buffer.add([0x1D, 0x56, 0x41, 0x03]); // GS V A 3 (Feed and Cut)

    return buffer.toBytes();
  }

  @override
  Uint8List generateKitchenTicket({
    required Order order,
    PaperSize paperSize = PaperSize.mm58,
    String station = 'KITCHEN & BAR',
  }) {
    final int width = paperSize == PaperSize.mm58 ? 32 : 48;
    final buffer = BytesBuilder();

    // 1. Initialize
    buffer.add([0x1B, 0x40]);

    // 2. Station Header
    _setAlign(buffer, 1); // Center
    _setBold(buffer, true);
    _setDoubleSize(buffer, true);
    buffer.add(_encodeText('*** $station ***\n'));
    _setDoubleSize(buffer, false);

    // Emphasize Table / Order Type
    buffer.add(_encodeText('${'=' * width}\n'));
    _setDoubleSize(buffer, true);
    if (order.orderType == OrderType.dineIn) {
      buffer.add(_encodeText('MEJA: ${order.tableNumber ?? "-"}\n'));
    } else {
      buffer.add(_encodeText('TAKE AWAY\n'));
    }
    _setDoubleSize(buffer, false);
    buffer.add(_encodeText('${'=' * width}\n'));

    // 3. Ticket Time & Order Info
    _setAlign(buffer, 0); // Left
    final timeFormat = DateFormat('HH:mm:ss');
    buffer.add(_encodeText('No: ${order.orderNumber}\n'));
    buffer.add(_encodeText('Time: ${timeFormat.format(order.createdAt)}\n'));
    buffer.add(_encodeText('Server: ${order.cashierName}\n'));
    buffer.add(_encodeText('${'-' * width}\n'));

    // 4. Kitchen Line Items (Large font for item name, modifiers clearly marked)
    for (final item in order.items) {
      _setBold(buffer, true);
      buffer.add(_encodeText('[ ${item.quantity}x ] ${item.productName}\n'));
      _setBold(buffer, false);

      if (item.selectedVariant != null) {
        buffer.add(_encodeText('    >> Size: ${item.selectedVariant!.name}\n'));
      }

      for (final mod in item.selectedModifiers) {
        buffer.add(_encodeText('    >> ${mod.name}\n'));
      }

      if (item.notes.isNotEmpty) {
        _setBold(buffer, true);
        buffer.add(_encodeText('    ** NOTE: ${item.notes.toUpperCase()} **\n'));
        _setBold(buffer, false);
      }
      buffer.add(_encodeText('\n'));
    }

    buffer.add(_encodeText('${'=' * width}\n'));

    // Feed & Cut
    buffer.add([0x1B, 0x64, 0x03]); // Feed 3 lines
    buffer.add([0x1D, 0x56, 0x41, 0x03]); // GS V A 3 (Cut)

    return buffer.toBytes();
  }

  // --- ESC/POS Helper Protocols ---

  static void _setAlign(BytesBuilder buffer, int align) {
    // 0: Left, 1: Center, 2: Right
    buffer.add([0x1B, 0x61, align]);
  }

  static void _setBold(BytesBuilder buffer, bool enable) {
    buffer.add([0x1B, 0x45, enable ? 0x01 : 0x00]);
  }

  static void _setDoubleSize(BytesBuilder buffer, bool enable) {
    // 0x11 = double height + double width
    buffer.add([0x1D, 0x21, enable ? 0x11 : 0x00]);
  }

  static List<int> _encodeText(String text) {
    return latin1.encode(text);
  }

  static String _formatTwoColumns(String left, String right, int width) {
    final int available = width - right.length;
    if (left.length > available - 1) {
      left = left.substring(0, available - 1);
    }
    final int spaces = width - left.length - right.length;
    return '$left${' ' * (spaces > 0 ? spaces : 1)}$right\n';
  }
}
