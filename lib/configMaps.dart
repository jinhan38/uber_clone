import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Model/all_users.dart';

const String mapKey = "AIzaSyCtqXiYOf4doorfXLMLa-8I7uit6E-EhKc";

String positionUrl =
    "https://maps.googleapis.com/maps/api/geocode/json?latlng=%s&key=$mapKey";

String placeDetailurl =
    "https://maps.googleapis.com/maps/api/place/details/json?place_id=%s&key=$mapKey";

String direction =
    "https://maps.googleapis.com/maps/api/directions/json?origin=%s&destination=%s&mode=transit&departure_time=now&key=$mapKey";

User? firebaseUser;

Users? userCurrentInfo;
