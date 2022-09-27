import 'package:flutter/material.dart';

class DataModel {
  var name;
  var manuf;

  DataModel({
    this.name,
    this.manuf
  });
}

List<DataModel> dataList = [
  DataModel(
    name: 'AAA',
    manuf: 'Sil',
  ),
  DataModel(
    name: 'BBB',
    manuf: 'Sil',
  ),
  DataModel(
    name: 'CCC',
    manuf: 'Sil',
  ),
];

class PortList extends StatefulWidget {
  PortList({Key? key}) : super(key: key);

  @override
  State<PortList> createState() => _PortListState();
}

class _PortListState extends State<PortList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: dataList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              return PortItem(dataList[index], index);
            }
      );
  }
}

class PortItem extends StatelessWidget {
  final DataModel model;
  final int pos;

  const PortItem(this.model, this.pos);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.amber[600],
      child: const Center(child: Text('Port')),
    );
  }
}