import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class UsbPrinterDevice {
  final String deviceName; // unique identifier
  final int vendorId;
  final int productId;
  final String? manufacturerName;
  final String? productName;

  UsbPrinterDevice({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    this.manufacturerName,
    this.productName,
  });

  factory UsbPrinterDevice.fromMap(Map<String, dynamic> map) {
    return UsbPrinterDevice(
      deviceName: map["deviceName"],
      vendorId: map["vendorId"],
      productId: map["productId"],
      manufacturerName: map["manufacturerName"],
      productName: map["productName"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "deviceName": deviceName,
      "vendorId": vendorId,
      "productId": productId,
      "manufacturerName": manufacturerName,
      "productName": productName,
    };
  }

  @override
  String toString() {
    return "$manufacturerName $productName ($vendorId:$productId) [$deviceName]";
  }
}

class DragoUsbPrinter {
  static const MethodChannel _channel = MethodChannel('drago_usb_printer');

  UsbPrinterDevice? _connectedDevice;

  /// ✅ Get available devices
  static Future<List<UsbPrinterDevice>> getUSBDeviceList() async {
    if (!Platform.isAndroid) return [];
    final List<dynamic> devices = await _channel.invokeMethod('getUSBDeviceList');
    return devices
        .cast<Map<dynamic, dynamic>>()
        .map((e) => UsbPrinterDevice.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// ✅ Connect using device object (deviceName based)
  Future<bool?> connect(UsbPrinterDevice device) async {
    _connectedDevice = device;
    final bool? result = await _channel.invokeMethod('connect', {
      "device": device.toMap(),
    });
    print("Connected: $result -> ${device.deviceName}");
    return result;
  }

  /// ✅ Disconnect
  Future<bool?> close() async {
    if (_connectedDevice == null) return false;
    final bool? result = await _channel.invokeMethod('disconnect', {
      "device": _connectedDevice!.toMap(),
    });
    _connectedDevice = null;
    return result;
  }

  /// ✅ Print text
  Future<bool?> printText(String text) async {
    if (_connectedDevice == null) return false;
    return await _channel.invokeMethod('printText', {
      "device": _connectedDevice!.toMap(),
      "text": text,
    });
  }

  /// ✅ Print raw text
  Future<bool?> printRawText(String text) async {
    if (_connectedDevice == null) return false;
    return await _channel.invokeMethod('printRawText', {
      "device": _connectedDevice!.toMap(),
      "raw": text,
    });
  }

  /// ✅ Write raw bytes
  Future<bool?> write(Uint8List data) async {
    if (_connectedDevice == null) return false;
    return await _channel.invokeMethod('write', {
      "device": _connectedDevice!.toMap(),
      "data": data,
    });
  }
}
