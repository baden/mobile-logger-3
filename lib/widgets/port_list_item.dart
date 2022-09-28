import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger3/serial.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';

import '../colors.dart';
import 'components.dart';

class DataModel {
  int index;
  UsbDevice device;
  bool isChecked;
  int baud;

  String status = "Idle";
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbPort? _port;


  DataModel({
    required this.index,
    required this.device,
    this.isChecked = false,
    this.baud = 115200
  });
}


class PortList extends StatefulWidget {
  const PortList({Key? key, required this.serial, required this.onLineData}) : super(key: key);

  final Serial serial;
  final Function(int index, String line) onLineData;

  @override
  State<PortList> createState() => _PortListState();
}

class _PortListState extends State<PortList> {

  List<DataModel> dataList = [];

  // TODO: Temporrary
  // List<Widget> _ports = [];
  // List<Widget> _serialData = [];
  // StreamSubscription<String>? _subscription;
  // Transaction<String>? _transaction;
  // UsbPort? _port;
  // UsbDevice? _device;

  bool hidePorts = false;

  void rescanPorts() async {
    print("Rescanin ports");
    setState(() {
      for(var dl in dataList) {
        dl.device?.port?.close();
      }
      dataList.clear();
    //   // TODO: Disconnect from all ports? No? Only for old.
    //   //_ports.clear();
    });

    List<UsbDevice> devices = await UsbSerial.listDevices();

    setState(() {
      // dataList.clear();
      devices.asMap().forEach((index, d) {
        dataList.add(DataModel(device: d, index: index));
      });
      /*for(var d in devices) {
        // print("name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}");
        // _debug += "name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}\r\n";
        dataList.add(DataModel(device: d, color: Colors.amber));
        // dataList.firstWhere((e) => e.device.deviceName == d.deviceName);
        
        // _ports.add(_portListItem(DataModel(name: d.deviceName, manuf: d.manufacturerName??'-', device: d)));
      }*/
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
          padding: const EdgeInsets.fromLTRB(12, 1, 12, 1),
          child: Row(children: [
            IconKey( Icons.update, "Update",
              onPressed: (_) { rescanPorts();}
            ),
            Expanded(child: Text("")),
            IconKey( Icons.remove_red_eye_rounded, "", onPressed: (_) {
              setState(() {
                hidePorts = !hidePorts;
              });
            })
          ])
        ),
        hidePorts ? Text("") : RefreshIndicator(
          onRefresh: onRefresh,
          child: Container(
            // color: Colors.green,
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minHeight: 100),
            // height: 200,
            child: 
            dataList/*_ports*/.length == 0 ? Text("No devices found")/*Center(child: CircularProgressIndicator())*/ : 
            ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: dataList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    // return PortItem(dataList[index], index, false);
                    return _portListItem(dataList[index]);
                  }
            ),
            
            /*Column(children: _ports)*/
          ),
        )
          
    ]);
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


  Future<bool> _connectTo(DataModel dm) async {
    // dm._serialData.clear();

    if (dm._subscription != null) {
      dm._subscription!.cancel();
      dm._subscription = null;
    }

    if (dm._transaction != null) {
      dm._transaction!.dispose();
      dm._transaction = null;
    }

    if (dm._port != null) {
      dm._port!.close();
      dm._port = null;
    }

    // if (dm.device == null) {
    //   dm.device = null;
    //   setState(() {
    //     dm.status = "Disconnected";
    //   });
    //   return true;
    // }

    dm._port = await dm.device.create();
    if (await (dm._port!.open()) != true) {
      setState(() {
        dm.status = "Failed to open port";
      });
      return false;
    }
    // dm.device = device;

    await dm._port!.setDTR(false);
    await dm._port!.setRTS(false);
    await dm._port!.setPortParameters(
        dm.baud, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    dm._transaction = Transaction.stringTerminated(
        dm._port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    dm._subscription = dm._transaction!.stream.listen((String line) {
      setState(() {
        print("Data:${line}");
        widget.onLineData(dm.index, line);
        // _serialData.add(Text(line));
        // if (_serialData.length > 20) {
        //   _serialData.removeAt(0);
        // }
      });
    });

    setState(() {
      dm.status = "Connected";
    });
    return true;
  }

  Future<bool> _disconnectTo(DataModel dm) async {
    return true;
  }


  Widget _portListItem(DataModel model)
  {
    final String name = model.device.deviceName;
    final String manuf = model.device.manufacturerName??'-';

    return Container(
        height: 68,
        // color: model.color, //Colors.amber[600],
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          children: [
            Text("$name ($manuf)", textScaleFactor: 0.9,),
            Row(
              children: [
                Container(color: portColor(model.index), width: 32, height: 32, margin: const EdgeInsets.fromLTRB(0, 0, 20, 0))
              /*Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: model.isChecked,
                onChanged: (bool? value) {
                  print("TDP($value)");
                  setState(() {
                    model.isChecked = value!;
                    // _ports[0].isChecked = value!;
                  //   isChecked = value!;
                  });
                },
              )*/,

              // Text("$pos:"),
              

              // DropdownButtonExample(notifyParent: (baud) { /*_onSetBaudRate(model.device, baud);*/ model.baud = baud; }),
              DropDown(
                baud: model.baud,
                notifyParent: (baud) {
                  setState(() {
                    model.baud = baud;
                  });
                  /*_onSetBaudRate(model.device, baud);*/
                }
              ),

              Expanded(child: Text('${model.status}')),

              GestureDetector(
                onTap: () {
                  print("_onConnectTap ${model.device.deviceName}");
                  _connectTo(model);
                  // _onConnectTap(model.device);
                },
                child: Icon(Icons.play_arrow_rounded, size: 36),
              )
            ]
          ),
        ]),
      );
    
  }
  
  // void _onConnectTap(UsbDevice device) {
  //   print("_onConnectTap ${device.deviceName}");
  // }
  

}

