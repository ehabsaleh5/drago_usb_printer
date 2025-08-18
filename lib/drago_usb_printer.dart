import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class UsbDevice {
  final int? productId;
  final String? deviceName;
  final int? vendorId;
  final int? deviceId;
  final String? manufacturer;
  final String? address;

  const UsbDevice({
    this.productId,
    this.deviceName,
    this.vendorId,
    this.deviceId,
    this.manufacturer,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId ?? 0,
      'productId': productId ?? 0,
      'deviceName': deviceName ?? "",
      'manufacturer': manufacturer ?? "",
      'deviceId': deviceId ?? 0,
      'address': address ?? "",
    };
  }

  factory UsbDevice.fromJson(Map json) {
    T? safeGet<T>(String key, {T? defaultValue}) {
      final value = json[key];
      if (value is T) return value;
      if (T == int) return int.tryParse(value?.toString() ?? '') as T?;
      if (T == String) return value?.toString() as T?;
      return defaultValue;
    }

    return UsbDevice(
      productId: safeGet<int>('productId', defaultValue: 0) ?? 0,
      vendorId: safeGet<int>('vendorId', defaultValue: 0) ?? 0,
      deviceId: safeGet<int>('deviceId', defaultValue: 0) ?? 0,
      deviceName: safeGet<String>('deviceName', defaultValue: '') ?? "",
      manufacturer: safeGet<String>('manufacturer') ?? "",
      address: safeGet<String>('address') ?? "",
    );
  }

  static List<UsbDevice> parseUsbDevices(List<dynamic> jsonList) {
    return jsonList.map((json) {
      final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
      return UsbDevice.fromJson(safeJson);
    }).toList();
  }
}

class DragoUsbPrinter {
  static const MethodChannel _channel =
      const MethodChannel('drago_usb_printer');

  UsbDevice? _connectedDevice;

  /// [getUSBDeviceList]
  /// get list of available usb devices on android
  static Future<List<UsbDevice>> getUSBDeviceList() async {
    if (Platform.isAndroid) {
      List<dynamic> devices = await _channel.invokeMethod('getUSBDeviceList');
      return UsbDevice.parseUsbDevices(devices);
    } else {
      return <UsbDevice>[];
    }
  }

  /// [connect]
  /// connect to a printer via UsbDevice
  Future<bool?> connect(UsbDevice device) async {
    _connectedDevice = device;

    final params = {
      "vendorId": device.vendorId,
      "productId": device.productId,
      "deviceId": device.deviceId,
      "address": device.address,
    };

    final bool? result = await _channel.invokeMethod('connect', params);
    print('connected $result');
    return result;
  }

  /// [close]
  /// close the connection after print with usb printer
  Future<bool?> close() async {
    if (_connectedDevice == null) return false;

    final params = {
      "vendorId": _connectedDevice!.vendorId,
      "productId": _connectedDevice!.productId,
      "deviceId": _connectedDevice!.deviceId,
      "address": _connectedDevice!.address,
    };

    final bool? result = await _channel.invokeMethod('disconnect', params);
    return result;
  }

  /// [printText]
  Future<bool?> printText(String text) async {
    if (_connectedDevice == null) return false;

    final params = {
      "text": text,
      "vendorId": _connectedDevice!.vendorId,
      "productId": _connectedDevice!.productId,
      "deviceId": _connectedDevice!.deviceId,
      "address": _connectedDevice!.address,
    };

    return await _channel.invokeMethod('printText', params);
  }

  /// [printRawText]
  Future<bool?> printRawText(String text) async {
    if (_connectedDevice == null) return false;

    final params = {
      "raw": text,
