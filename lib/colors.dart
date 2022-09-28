
import 'package:flutter/material.dart';

const List<MaterialColor> _portColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.brown,
  Colors.amber,
  Colors.cyan,
];

MaterialColor portColor(int index)
{
  if(index >= _portColors.length) return _portColors[0];
  return _portColors[index];
}