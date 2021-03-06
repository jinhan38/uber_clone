import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uber/Assistants/requestAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Model/address.dart';
import 'package:uber/Model/all_users.dart';
import 'package:uber/Model/direct_details.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/utils/util.dart';

class AssistantMethods {
  /// position(lat, long)으로 주소 얻어오기
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    var placeAddress = "";

    String st1, st2, st3, st4;

    var url = sprintf(positionUrl,
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

  ///출발지, 도착지 좌표로 지도에 표시
  static Future<DirectDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    var s1 = "${initialPosition.latitude},${initialPosition.longitude}";
    var s2 = "${finalPosition.latitude},${finalPosition.longitude}";
    var url = sprintf(direction, [s1, s2]);
    var res = await RequestAssistant.getRequest(url);

    if (res == "fail") {
      return null;
    } else {
      if (res["status"] != "ZERO_RESULTS") {
        DirectDetails directDetails = DirectDetails();
        print("res 확인 : $res");
        directDetails.encodePoint =
            res["routes"][0]["overview_polyline"]["points"];
        directDetails.distanceText =
            res["routes"][0]["legs"][0]["distance"]["text"];
        directDetails.distanceValue =
            res["routes"][0]["legs"][0]["distance"]["value"];
        directDetails.durationText =
            res["routes"][0]["legs"][0]["duration"]["text"];
        directDetails.durationValue =
            res["routes"][0]["legs"][0]["duration"]["value"];
        return directDetails;
      } else {
        return null;
      }
    }
  }

  ///거리당 금액 계산
  /// 1$ * 1000Won
  static String calculateFares(DirectDetails directionDetails) {
    var durationValue = directionDetails.durationValue ?? 0;
    if (durationValue > 0) {
      double timeTraveledFare = (durationValue / 60) * 0.20;
      double distanceTraveledFare = (durationValue / 1000) * 0.20;
      double totalFareAmount = timeTraveledFare + distanceTraveledFare;
      return "${Util.calculateFare(totalFareAmount.truncate())}원";
    } else {
      return "";
    }
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      String userId = firebaseUser!.uid;
      DatabaseReference reference =
          FirebaseDatabase.instance.reference().child("users").child(userId);
      reference.once().then((DataSnapshot dataSnapshot) {
        Users users = Users.fromSnapshot(dataSnapshot);
      });
    }
  }
}
