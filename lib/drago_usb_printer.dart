import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class DragoUsbPrinter {
  static const MethodChannel _channel =
      const MethodChannel('drago_usb_printer');

  int vendorId = 0;
  int productId = 0;
  int deviceId = 0;

  /// [getUSBDeviceList]
  /// get list of available usb device on android
  static Future<List<Map<String, dynamic>>> getUSBDeviceList() async {
    if (Platform.isAndroid) {
      List<dynamic> devices = await _channel.invokeMethod('getUSBDeviceList');
      print(devices);
      var result = devices
          .cast<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      return result;
    } else {
      return <Map<String, dynamic>>[];
    }
  }

  /// [connect]
  /// connect to a printer via vendorId, productId and deviceId
  Future<bool?> connect(int vendorId, int productId, int deviceId) async {
    this.vendorId = vendorId;
    this.productId = productId;
    this.deviceId = deviceId;

    Map<String, dynamic> params = {
      "vendorId": vendorId,
      "productId": productId,
      "deviceId": deviceId,
    };
    final bool? result = await _channel.invokeMethod('connect', params);
    print('connected $result');
    return result;
  }

  /// [close]
  /// close the connection after print with usb printer
  Future<bool?> close() async {
    Map<String, dynamic> params = {
      "vendorId": vendorId,
      "productId": productId,
      "deviceId": deviceId,
    };
    final bool? result = await _channel.invokeMethod('disconnect', params);
    return result;
  }

  /// [printText]
  /// print text
  Future<bool?> printText(String text) async {
    Map<String, dynamic> params = {
      "text": text,
      "vendorId": vendorId,
      "productId": productId,
      "deviceId": deviceId,
    };
    final bool? result = await _channel.invokeMethod('printText', params);
    return result;
  }

  /// [printRawText]
  /// print raw text
  Future<bool?> printRawText(String text) async {
    Map<String, dynamic> params = {
      "raw": text,
      "vendorId": vendorId,
      "productId": productId,
      "deviceId": deviceId,
    };
    final bool? result = await _channel.invokeMethod('printRawText', params);
    return result;
  }

  /// [write]
  /// write data byte
  Future<bool?> write(Uint8List data) async {
    Map<String, dynamic> params = {
      "data": data,
      "vendorId": vendorId,
      "productId": productId,
      "deviceId": deviceId,
    };
    final bool? result = await _channel.invokeMethod('write', params);
    return result;
  }
}
