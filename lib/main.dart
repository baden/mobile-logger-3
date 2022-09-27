import 'package:flutter/material.dart';
import 'package:logger3/widgets/port_list_item.dart';
import 'package:usb_serial/usb_serial.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  String _debug = "";



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
            PortList(),
            Text(
              '[$_debug]',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listDevices,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _listDevices() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);
    setState(() {
      _debug = "";
      for(var d in devices) {
        print("name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}");
        _debug += "name: ${d.deviceName}  manuf: ${d.manufacturerName??'-'}\r\n";
      }
	    //_debug = "${devices.toString()}";
    });
  }
}