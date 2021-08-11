import 'package:flutter/cupertino.dart';
import 'package:uber/Model/address.dart';

class AppData extends ChangeNotifier {

  Address userPickUpLocation = Address();

  void updatePickUpLocationAddress(Address pickUpAddress){
    userPickUpLocation = pickUpAddress;
    notifyListeners();
  }

}
