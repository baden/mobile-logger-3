
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