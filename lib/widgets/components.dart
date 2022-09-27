
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class IconKey extends StatelessWidget {
  const IconKey(this.icon, this.label, {Key? key}) : super(key: key);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        icon,
        color: Colors.green,
        size: 24.0,
      ),
      Text(label)
    ]);
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