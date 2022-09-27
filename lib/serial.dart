
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

class Serial {
  static const EventChannel _eventChannel = EventChannel('usb_serial/events');
  late Stream<UsbEvent> _eventStream;

  int _counter = 0;
  List<String> _logData = [];

  Stream<UsbEvent> get usbEventStream {
    _eventStream = _eventChannel.receiveBroadcastStream().map<UsbEvent>((value) {
      UsbEvent msg = UsbEvent();
      print("Stream event (${msg.toString()})");
      msg.device = UsbDevice.fromJSON(value);
      msg.event = value["event"];
      return msg;
    });
    return _eventStream;
  }


  int get logDataLines {
    return _logData.length;
  }

  Serial() {
    print("::Serial::init");


  }

  static Future<List<UsbDevice>> getList() async {
    return UsbSerial.listDevices();
  }

  void onPlus(String s) {
    _counter++;
    print("::Serial::onPlus / $_counter");
    _logData.add(s);
  }

  void onMinus(String s) {
    _counter--;
    print("::Serial::onMinus / $_counter");
  }
}
