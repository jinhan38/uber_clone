

import 'package:flutter/material.dart';

class Util{

  static MaterialStateProperty<RoundedRectangleBorder> getBorderRadius(double radius_double){
    return MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_double),
      ),
    );
  }

  static focusOut(BuildContext context){
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
  }
}