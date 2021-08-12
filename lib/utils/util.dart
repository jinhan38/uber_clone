import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Util {
  static MaterialStateProperty<RoundedRectangleBorder> getBorderRadius(
      double radius_double) {
    return MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_double),
      ),
    );
  }

  static focusOut(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
  }

  static Marker setMarker(double bitmapColor, String placeName,
      String snippetText, LatLng latLng, String markerId) {
    return Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(bitmapColor),
      infoWindow: InfoWindow(title: placeName, snippet: snippetText),
      position: latLng,
      markerId: MarkerId(markerId),
    );
  }

  static Circle setCircle(Color color, LatLng latLng, String circleId) {
    return Circle(
      fillColor: color,
      center: latLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: color,
      circleId: CircleId(circleId),
    );
  }


  ///Money format
  static String changeMoneyFormat(int value){
    return NumberFormat('###,###,###,###').format(value);

  }

  ///달러 -> 원 환산
  static String calculateFare(int fare) {
    return changeMoneyFormat(fare * 1000);
  }
}
