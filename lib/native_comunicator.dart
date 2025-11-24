import 'package:flutter/services.dart';

class NativeComunicator {
  static const MethodChannel _channel = MethodChannel('com.example.app/native');

  static Future<String> invokeNativeMethod(String method, Map<String, dynamic> arguments) async {
    try {
      final result = await _channel.invokeMethod(method, arguments);
      return result.toString();
    } on PlatformException catch (e) {
      throw Exception('Failed to invoke native method: $e');
    }
  }

}