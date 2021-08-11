import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uber/Assistants/requestAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Model/address.dart';
import 'package:uber/configMaps.dart';

class AssistantMethods {
  /// position(lat, long)으로 주소 얻어오기
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    var placeAddress = "";

    String st1, st2, st3, st4;

    var url = sprintf(ConfigMaps().positionUrl,
        ["${position.latitude},${position.longitude}"]);
    print("주소 url : $url");
    var response = await RequestAssistant.getRequest(url);

    if (response != "fail") {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][2]["long_name"];
      st3 = response["results"][0]["address_components"][1]["long_name"];
      placeAddress = "$st1, $st2, $st3";

      Address userPickUpAddress = Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }
}
