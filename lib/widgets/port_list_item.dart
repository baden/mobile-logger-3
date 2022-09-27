import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:usb_serial/usb_serial.dart';

import 'components.dart';

class DataModel {
  String name;
  String manuf;
  bool isChecked;

  DataModel({
    required this.name,
    required this.manuf,
    this.isChecked = false
  });
}

class PortList extends StatefulWidget {
  PortList({Key? key}) : super(key: key);

  @override
  State<PortList> createState() => _PortListState();

}

class _PortListState extends State<PortList> {

  List<DataModel> dataList = [];

  void rescanPorts() async {
    // print("Rescanin ports");
    setState(() {
      dataList.clear();
    });

    List<UsbDevice> devices = await UsbSerial.listDevices();

    setState(() {
      // dataList.clear();
      for(var d in devices) {
        // print("name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}");
        // _debug += "name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}\r\n";
        dataList.add(DataModel(name: d.deviceName, manuf: d.manufacturerName??'-'));
      }
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rescanPorts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () {
          print("Update (TDP)");
          rescanPorts();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: const IconKey(Icons.update, "Update")
        )
      ),
      ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: dataList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              return PortItem(dataList[index], index, false);
            }
      ),
    ]);
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