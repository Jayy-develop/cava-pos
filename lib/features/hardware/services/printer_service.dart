import 'dart:typed_data';
import '../../pos/domain/entities/order.dart';

enum PaperSize { mm58, mm80 }

enum PrinterConnectionStatus { disconnected, connecting, connected, error }

class PrinterDevice {
  final String id;
  final String name;
  final String address; // MAC address for Bluetooth or IP:port for Network
  final bool isBluetooth;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.address,
    this.isBluetooth = true,
  });
}

abstract class IPrinterService {
  Future<List<PrinterDevice>> scanBluetoothPrinters();
  Future<bool> connect(PrinterDevice device);
  Future<void> disconnect();
  PrinterConnectionStatus get status;

  Uint8List generateCustomerReceipt({
    required Order order,
    PaperSize paperSize = PaperSize.mm58,
    bool openCashDrawer = true,
  });

  Uint8List generateKitchenTicket({
    required Order order,
    PaperSize paperSize = PaperSize.mm58,
    String station = 'KITCHEN & BAR',
  });

  Uint8List generateCashDrawerCommand();

  Future<bool> printBytes(Uint8List bytes);
}
