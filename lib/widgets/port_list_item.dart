import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger3/serial.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'components.dart';

class DataModel {
  String name;
  String manuf;
  UsbDevice device;
  bool isChecked;

  DataModel({
    required this.name,
    required this.manuf,
    required this.device,
    this.isChecked = false
  });
}

class PortList extends StatefulWidget {
  const PortList({Key? key, required this.serial}) : super(key: key);

  final Serial serial;

  @override
  State<PortList> createState() => _PortListState();

}

class _PortListState extends State<PortList> {

  List<DataModel> dataList = [];

  void rescanPorts() async {
    // print("Rescanin ports");
    setState(() {
      // dataList.clear();
      // TODO: Disconnect from all ports? No? Only for old.
      _ports.clear();
    });

    List<UsbDevice> devices = await UsbSerial.listDevices();

    setState(() {
      // dataList.clear();
      for(var d in devices) {
        // print("name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}");
        // _debug += "name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}\r\n";
        // dataList.add(DataModel(name: d.deviceName, manuf: d.manufacturerName??'-', device: d));
        _ports.add(_portListItem(DataModel(name: d.deviceName, manuf: d.manufacturerName??'-', device: d)));
      }
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent msg) {
      rescanPorts();
      // print(msg);
      // if (msg.event == UsbEvent.ACTION_USB_ATTACHED) {
      //   // open a device now...
      // }
      // if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
      //   //  close device now...
      // }
    });

    rescanPorts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("TODO: Disconnect all");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: IconKey( Icons.update, "Update",
            onPressed: () { rescanPorts();}
          )
        ),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: Container(
            // color: Colors.green,
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minHeight: 100),
            // height: 200,
            child: 
            /*dataList*/_ports.length == 0 ? Text("No devices found")/*Center(child: CircularProgressIndicator())*/ : 
            /*ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: dataList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    return PortItem(dataList[index], index, false);
                  }
            ),
            */
            Column(children: _ports)
          ),
        ),
        bottomPanel(),
        statsPanel()
          
    ]);
  }

  Widget bottomPanel()
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.yellow,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Row(children: [
        IconKey(Icons.plus_one, "+", onPressed: onPlus),
        IconKey(Icons.exposure_minus_1, "-", onPressed: onMinus),
        IconKey(Icons.save, "Save", onPressed: onSave)
      ])
    );
  }

  
  Widget statsPanel()
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.yellow,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Row(children: [
        Text("Log: ${widget.serial.logDataLines} | Status: ${_status}"),
      ])
    );
  }

  void onSave() async {
    // Look good example
    // https://github.com/aponduet/allshare/blob/6d35ee2c216588662d130b4ab81b14f515abed76/allshare/lib/view/receive_display/image.dart

    Uint8List data = Uint8List.fromList([48, 49, 50, 13, 10]);
    final now = DateTime.now();
    final String fileName = "Log3_${now.year}_${now.month}_${now.day}-${now.hour}_${now.minute}";
    await FileSaver.instance.saveAs(fileName, data, "txt", MimeType.TEXT);
  }

  Future<void> onRefresh() async
  {
    print("OnRefresh (TDP)");
    rescanPorts();
  }

  void onPlus() {
    setState(() {
      widget.serial.onPlus("foo");
    });
  }

  void onMinus() {
    widget.serial.onMinus("foo");
  }

  // TODO: Temporrary
  List<Widget> _ports = [];
  List<Widget> _serialData = [];
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbPort? _port;
  UsbDevice? _device;
  String _status = "Idle";

  Future<bool> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(false);
    await _port!.setRTS(false);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  Widget _portListItem(DataModel model)
  {
    final String name = model.device.deviceName;
    final String manuf = model.device.manufacturerName??'-';

    return GestureDetector(
      onTap: (){
        print("Tap");
        showToast("Port is used for log recording...(TDP)");
        //model.device;
      },
      child: Container(
        height: 80,
        color: Colors.amber[600],
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          children: [
            Text("$name/$manuf"),
            Row(
              children: [
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: model.isChecked,
                onChanged: (bool? value) {
                  print("TDP($value)");
                  // setState(() {
                  //   isChecked = value!;
                  // });
                },
              ),

              // Text("$pos:"),
              

              DropdownButtonExample(notifyParent: (baud) { _onSetBaudRate(model.device, baud); }),

              GestureDetector(
                onTap: () => _onConnectTap(model.device),
                child: Icon(Icons.play_arrow_rounded, size: 36),
              )
            ]
          ),
        ]),
      )
    );
  }
  
  void _onConnectTap(UsbDevice device) {
    print("_onConnectTap ${device.deviceName}");
  }
  
  void _onSetBaudRate(UsbDevice device, int baud) {
    print("_onSetBaudRate ${device.deviceName} <= $baud");
  }

  


}




class PortItem extends StatelessWidget {
  final DataModel model;
  final int pos;
  final bool isChecked;

  const PortItem(this.model, this.pos, this.isChecked, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("Tap");
        showToast("Port is used for log recording...(TDP)");
        //model.device;
      },
      child: Container(
        height: 40,
        color: Colors.amber[600],
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Row(
          children: [

            Checkbox(
              checkColor: Colors.white,
              // fillColor: MaterialStateProperty.resolveWith(getColor),
              value: isChecked,
              onChanged: (bool? value) {
                print("TDP($value)");
                // setState(() {
                //   isChecked = value!;
                // });
              },
            ),

            Text("$pos:"),
            Text("${model.name}"),
            Text("${model.manuf}"),
          ]
        ),
      )
    );
  }
}