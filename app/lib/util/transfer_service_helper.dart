import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Keeps a foreground service alive on Android while transfers are running,
/// so the app isn't killed or frozen when backgrounded.
class TransferServiceHelper {
  static const _channel = MethodChannel('com.gravitysend.app/localsend');
  static int _counter = 0;

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    if (++_counter > 1) return;
    try {
      await _channel.invokeMethod('startTransferService');
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    if (_counter == 0) return;
    _counter--;
    if (_counter > 0) return;
    try {
      await _channel.invokeMethod('stopTransferService');
    } catch (_) {}
  }

  /// Resets the internal counter. Only useful in tests.
  static void reset() => _counter = 0;
}
