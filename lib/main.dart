
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger3/colors.dart';
import 'package:logger3/serial.dart';
import 'package:logger3/widgets/components.dart';
import 'package:logger3/widgets/port_list_item.dart';
import 'package:file_saver/file_saver.dart';
// import 'package:xterm/xterm.dart';

// import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( primarySwatch: Colors.amber ),
      home: const MyHomePage(title: 'Logger/3'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class LogLine {
  LogLine({required this.index, required this.logLine});

  int index;
  String logLine;
}

class _MyHomePageState extends State<MyHomePage> {
  // String _debug = "";
  Serial serial = Serial();

  List<LogLine> logData = [];

  // Terminal terminal = Terminal(maxLines: 100);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PortList(serial: serial, onLineData: (index, line) {
              print("TODO: [$index] $line");
              setState(() {
                // _debug += "TODO: $deviceName: [$line]\r\n";
                logData.add(LogLine(index: index, logLine: line));
              });
            }),
            Expanded(child: /*TerminalView(terminal)*/
            
            /*Text(
              '[$_debug]',
              // style: Theme.of(context).textTheme.headline4,
            )*/

            Scrollbar(
              child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: logData.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      // return PortItem(dataList[index], index, false);
                      return Container(
                        // foregroundDecoration: portColor(index),
                        child: Text(logData[index].logLine, style: TextStyle(color: portColor(logData[index].index), fontWeight: FontWeight.bold))
                      );
                    }
              ),
            ),

            ),
            bottomPanel()
            
          ],
        
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _listDevices,
        tooltip: 'Start recording',
        child: const Icon(Icons.save_as_rounded),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Future<File> writeFile(Uint8List data, String name) async {
  //   // storage permission ask
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   // the downloads folder path
  //   Directory tempDir = await getApplicationDocumentsDirectory();
  //   String tempPath = tempDir.path;
  //   var filePath = '$tempPath/$name';
  //   // 

  //   // the data
  //   var bytes = ByteData.view(data.buffer);
  //   final buffer = bytes.buffer;
  //   // save the data in the path
  //   return File(filePath).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  // }  

  Widget bottomPanel()
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.yellow,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Row(children: [
        IconKey(Icons.remove, "Clear", onPressed: _onClear),
        Expanded(child: Text('')),
        IconKey(Icons.save, "Save", onPressed: _onSave)
      ])
    );
  }

  void _listDevices() async {

    showToast("Chose one or several ports for recording");
    // terminal.write('Hello, world!\r\n');

    // var file = await writeFile(data, 'log-example');
    // file.close();

    // List<UsbDevice> devices = await UsbSerial.listDevices();
    // print(devices);
    // setState(() {
    //   _debug = "";
    //   for(var d in devices) {
    //     print("name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}");
    //     _debug += "name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}\r\n";
    //   }
	  //   //_debug = "${devices.toString()}";
    // });
  }

  void _onClear(_) {

    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you realy want clear log?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  logData.clear();  
                });
                Navigator.pop(context, 'OK'); 
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );

    
  }

  void _onSave(_) async {
    // Look good example
    // https://github.com/aponduet/allshare/blob/6d35ee2c216588662d130b4ab81b14f515abed76/allshare/lib/view/receive_display/image.dart

    String fileData;

    
    final now = DateTime.now();

    /*
    Stream.fromIterable(
      utf8.encode(text).map((elements) => Uint8List.fromList([elements])).toList();

    List<int> di = utf8.encode(Stream.fromIterable(logData.map((e) => e.logLine)));
    */
    // Concat strings
    final List<int> codeUnits = logData.map(((e) => "[${e.index}]: ${e.logLine}\r\n")).join().codeUnits;
    Uint8List data = Uint8List.fromList(codeUnits);
    final String fileName = "Log3_${now.year}_${now.month}_${now.day}-${now.hour}_${now.minute}";
    await FileSaver.instance.saveAs(fileName, data, "txt", MimeType.TEXT);
    
  }
}
