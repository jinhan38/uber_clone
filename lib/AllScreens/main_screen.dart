import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/AllScreens/searchScreen.dart';
import 'package:uber/AllWidgets/divider.dart';
import 'package:uber/Assistants/assistantMethods.dart';
import 'package:uber/DataHandler/appData.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  void locatePosition() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLatPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    var address = await AssistantMethods.searchCoordinateAddress(
        currentPosition, context);
    print("address : $address");
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Main Screen")),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png",
                          height: 65, width: 65),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "Brand-Bold")),
                          SizedBox(height: 6),
                          Text("Visit Profile"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(height: 12),
              ListTile(
                  leading: Icon(Icons.history),
                  title: Text("History", style: TextStyle(fontSize: 15))),
              ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Visit Profile", style: TextStyle(fontSize: 15))),
              ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About", style: TextStyle(fontSize: 15))),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locatePosition();
              setState(() {
                bottomPaddingOfMap = 320;
              });
            },
          ),

          Positioned(
            top: 45,
            left: 22,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState!.openDrawer();
                locatePosition();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 6,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7)),
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Container(
          //     height: 300,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(15),
          //         topRight: Radius.circular(15),
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black,
          //           blurRadius: 16,
          //           spreadRadius: 0.5,
          //           offset: Offset(0.7, 0.7),
          //         ),
          //       ],
          //     ),
          //     child: Padding(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           SizedBox(height: 16),
          //           Text("Hi there,", style: TextStyle(fontSize: 12)),
          //           Text("Where to?",
          //               style:
          //                   TextStyle(fontSize: 20, fontFamily: "Brand-Bold")),
          //           SizedBox(height: 20),
          //           Container(
          //             decoration: BoxDecoration(
          //               color: Colors.white,
          //               borderRadius: BorderRadius.circular(5),
          //               boxShadow: [
          //                 BoxShadow(
          //                     color: Colors.black54,
          //                     blurRadius: 6,
          //                     spreadRadius: 0.5,
          //                     offset: Offset(0.7, 0.7)),
          //               ],
          //             ),
          //             child: Padding(
          //               padding: const EdgeInsets.all(12.0),
          //               child: Row(
          //                 children: [
          //                   Icon(Icons.search, color: Colors.blueAccent),
          //                   SizedBox(height: 20),
          //                   Text("Search Drop Off Location"),
          //                 ],
          //               ),
          //             ),
          //           ),
          //           SizedBox(height: 24),
          //           Row(
          //             children: [
          //               Icon(Icons.home, color: Colors.grey),
          //               SizedBox(width: 12),
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text("Add Home",
          //                       style: TextStyle(
          //                           color: Colors.black,
          //                           fontSize: 14,
          //                           fontFamily: "Brand-Bold")),
          //                   SizedBox(height: 4),
          //                   Text("Your living home address",
          //                       style: TextStyle(
          //                           color: Colors.black54, fontSize: 12)),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           SizedBox(height: 24),
          //           DividerWidget(),
          //           SizedBox(height: 24),
          //           Row(
          //             children: [
          //               Icon(Icons.work, color: Colors.grey),
          //               SizedBox(width: 12),
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text("Add Work",
          //                       style: TextStyle(
          //                           color: Colors.black,
          //                           fontSize: 14,
          //                           fontFamily: "Brand-Bold")),
          //                   SizedBox(height: 4),
          //                   Text("Your office address",
          //                       style: TextStyle(
          //                           color: Colors.black54, fontSize: 12)),
          //                 ],
          //               ),
          //             ],
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                width: 300,
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text("Hi there,", style: TextStyle(fontSize: 12)),
                      Text("Where to?",
                          style: TextStyle(
                              fontSize: 20, fontFamily: "Brand-Bold")),
                      SizedBox(height: 20),
                      
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7)),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent),
                                SizedBox(height: 20),
                                Text("Search Drop Off Location"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(                            
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  Provider.of<AppData>(context)
                                              .userPickUpLocation.placeName != null
                                      ? Provider.of<AppData>(context)
                                          .userPickUpLocation
                                          .placeName!
                                      : "add Home",
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: "Brand-Bold")),
                              SizedBox(height: 4),
                              Text("Your living home address",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      DividerWidget(),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: "Brand-Bold")),
                              SizedBox(height: 4),
                              Text("Your office address",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
