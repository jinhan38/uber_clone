import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uber/AllScreens/register_screen.dart';
import 'package:uber/AllWidgets/divider.dart';
import 'package:uber/AllWidgets/progress_dialog.dart';
import 'package:uber/Assistants/requestAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Model/PlacePredictions.dart';
import 'package:uber/Model/address.dart';
import 'package:uber/configMaps.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).userPickUpLocation.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 25, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style:
                              TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                  hintText: "PickUp Location",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                                onChanged: (keyword) {
                                  findPlace(keyword);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                    hintText: "Where to? ",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8))),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return PredictionTile(
                          placePredictions: placePredictionList[index]);
                    },
                    separatorBuilder: (context, index) => DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${ConfigMaps.mapKey}&sessiontoken=1234567890&components=country:KR";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "fail") {
        return;
      } else {
        if (res["status"] == "OK") {
          var predictions = res["predictions"];
          var placeList = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();
          setState(() {
            placePredictionList = placeList;
          });
        }
        print("autoComplete : $res");
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  const PredictionTile({Key? key, required this.placePredictions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
      ),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id.toString(), context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(placePredictions.main_text.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text(placePredictions.secondary_text.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(message: "도착지를 검색중입니다"));

    var url = sprintf(ConfigMaps().placeDetailurl, [placeId]);
    print("도착지 확인 url : $url");

    var res = await RequestAssistant.getRequest(url);

    Navigator.pop(context);

    if (res == "fail") {
      return;
    } else {
      if (res["status"] == "OK") {
        Address address = Address();
        address.placeName = res["result"]["name"];
        address.placeId = placeId;
        address.latitude = res["result"]["geometry"]["location"]["lat"];
        address.longitude = res["result"]["geometry"]["location"]["lng"];

        Provider.of<AppData>(context, listen: false)
            .updateDropOffLocationAddress(address);

        print("도착지 이름 : ${address.placeName}");
        Navigator.pop(context, 'obtainDirection');
        // displayToastMessage(
        //     "도착지 이름 : ${address.placeName}, latitude : ${address.latitude}, longitude : ${address.longitude},");
      } else {
        return;
      }
    }
  }
}
