

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class Util{

  static MaterialStateProperty<RoundedRectangleBorder> getBorderRadius(double radius_double){
    return MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_double),
      ),
    );
  }
}