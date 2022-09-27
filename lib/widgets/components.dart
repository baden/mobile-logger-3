
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class IconKey extends StatelessWidget {
  IconKey(
    this.icon, this.label, {Key? key, required this.onPressed}
    ) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;


  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    backgroundColor: Colors.grey[100],
    minimumSize: Size(88, 48),
    padding: EdgeInsets.symmetric(horizontal: 12.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  @override
  Widget build(BuildContext context) {
    // return Row(children: [
    //   Icon(
    //     icon,
    //     color: Colors.green,
    //     size: 24.0,
    //   ),
    //   Text(label)
    // ]);


    return /*TextButton*/ElevatedButton(
      style: style/*flatButtonStyle*/,
      onPressed: onPressed,
      child: Row(
        children: [
        Icon(
          icon,
          color: Colors.green,
          size: 32.0,
        ),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
      ])
    );

  }
}

void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0
  );
}

const List<int> boudList = <int>[2400, 4800, 9600, 19200, 115200];

class DropDown extends StatelessWidget {
  final int baud;
  final Function(int baud) notifyParent;

  const DropDown({super.key, required this.baud, required this.notifyParent });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: baud,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? value) {
        // This is called when the user selects an item.
        notifyParent(value!);
      },
      items: boudList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}


// class DropdownButtonExample extends StatefulWidget {
//   final int baud;
//   final Function(int baud) notifyParent;
//   const DropdownButtonExample({super.key, required this.baud, required this.notifyParent});

//   @override
//   State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
// }

// class _DropdownButtonExampleState extends State<DropdownButtonExample> {

//   static const List<int> boudList = <int>[2400, 4800, 9600, 19200, 115200];

//   // int dropdownValue = boudList.last;
//   // int dropdownValue = widget.baud;

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<int>(
//       value: dropdownValue,
//       icon: const Icon(Icons.arrow_downward),
//       elevation: 16,
//       style: const TextStyle(color: Colors.deepPurple),
//       underline: Container(
//         height: 2,
//         color: Colors.deepPurpleAccent,
//       ),
//       onChanged: (int? value) {
//         // This is called when the user selects an item.
//         setState(() {
//           dropdownValue = value!;
//         });
//         widget.notifyParent(value!);
//       },
//       items: boudList.map<DropdownMenuItem<int>>((int value) {
//         return DropdownMenuItem<int>(
//           value: value,
//           child: Text(value.toString()),
//         );
//       }).toList(),
//     );
//   }
// }
