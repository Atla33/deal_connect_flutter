import 'package:flutter/material.dart';


Map<int, Color> _swatchOpacity ={

  50 : const Color.fromRGBO(0, 33, 113, .1),
  100 : const Color.fromRGBO(0, 33, 113, .2),
  200 : const Color.fromRGBO(0, 33, 113, .3),
  300 : const Color.fromRGBO(0, 33, 113, .4),
  400 : const Color.fromRGBO(0, 33, 113, .5),
  500 : const Color.fromRGBO(0, 33, 113, .6),
  600 : const Color.fromRGBO(0, 33, 113, .7),
  700 : const Color.fromRGBO(0, 33, 113, .8),
  800 : const Color.fromRGBO(0, 33, 113, .9),
  900 : const Color.fromRGBO(0, 33, 113, 1),

};


abstract class CustomColors {
  static  Color customContrastColor = Colors.red.shade700;
  static  MaterialColor customSwatchColor = MaterialColor(
    0xFF002171, _swatchOpacity
  );
}