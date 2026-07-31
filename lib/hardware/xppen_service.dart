import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class XPPenService {
  static const MethodChannel _channel = MethodChannel('com.inkguru.hardware/xppen');
  static const EventChannel _eventChannel = EventChannel('com.inkguru.hardware/xppen_events');

  static Future<bool> isDeviceConnected() async {
    try {
      final bool result = await _channel.invokeMethod('isDeviceConnected');
      debugPrint('XP-Pen Device detected!');
      return result;
    } catch (e) {
      // Fallback to generic Windows Ink if SDK is missing or not compiled
      return false; 
    }
  }

  static Stream<Map<String, dynamic>> get tabletEvents {
    return _eventChannel.receiveBroadcastStream().map((event) => Map<String, dynamic>.from(event));
  }

  static Future<void> setPressureCurve(List<double> curve) async {
    try {
      await _channel.invokeMethod('setPressureCurve', {'curve': curve});
    } catch (e) {
      debugPrint('Warning: Failed to set pressure curve natively.');
    }
  }
}
