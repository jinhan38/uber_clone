import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/AllScreens/searchScreen.dart';
import 'package:uber/AllWidgets/divider.dart';
import 'package:uber/AllWidgets/main_drawer.dart';
import 'package:uber/AllWidgets/progress_dialog.dart';
import 'package:uber/Assistants/assistantMethods.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Model/direct_details.dart';
import 'package:uber/utils/util.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DirectDetails tripDirectDetails = DirectDetails();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 320;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double searchContainerHeight = 320;
  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;

  bool drawerOpen = true;
  bool cancelContainerOpen = false;

  DatabaseReference? rideRequestRef;

  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 30,
    fontFamily: "Signatra",
  );

  void hideCancelContainer() {
    setState(() {
      cancelContainerOpen = false;
      requestRideContainerHeight = 0;
      displayRideDetailsContainer();
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      cancelContainerOpen = true;
      requestRideContainerHeight = 250;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 240;
      drawerOpen = true;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 320;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 320;
      polylineSet.clear();
      markersSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      bottomPaddingOfMap = 0;
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240;
      bottomPaddingOfMap = 240;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLatPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    var details = await AssistantMethods.searchCoordinateAddress(
        currentPosition, context);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  _onBackPressed(BuildContext context) async {
    if (cancelContainerOpen) {
      hideCancelContainer();
    } else if (rideDetailsContainerHeight > 0) {
      resetApp();
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("앱을 종료하시겠습니까?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("아니오")),
            TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text("네")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(title: Text("Main Screen")),
        drawer: Container(
          color: Colors.white,
          width: 255,
          child: MainDrawer(),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                locatePosition();
                setState(() {
                  // bottomPaddingOfMap = 320;
                });
              },
            ),
            Positioned(
              top: 38,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  if (drawerOpen) {
                    scaffoldKey.currentState!.openDrawer();
                  } else {
                    resetApp();
                  }
                  // locatePosition();
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
                      (drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 160),
                child: SingleChildScrollView(
                  child: Container(
                    height: searchContainerHeight,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
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
                            onTap: () async {
                              final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen()));
                              if (res == "obtainDirection") {
                                displayRideDetailsContainer();
                              }
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
                                    Icon(Icons.search,
                                        color: Colors.blueAccent),
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
                                                  .userPickUpLocation
                                                  .placeName !=
                                              null
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
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent[100],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset("images/taxi.png",
                                    height: 70, width: 80),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Car",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Brand-Bold")),
                                    Text(tripDirectDetails.distanceText ?? "",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                            fontFamily: "Brand-Bold")),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                    AssistantMethods.calculateFares(
                                        tripDirectDetails),
                                    style: TextStyle(fontFamily: "Brand-Bold")),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.moneyCheckAlt,
                                  size: 18, color: Colors.black54),
                              SizedBox(width: 16),
                              Text("Cash"),
                              SizedBox(width: 16),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black54, size: 16),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              displayRequestRideContainer();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 160),
                child: Container(
                  height: requestRideContainerHeight,
                  padding: const EdgeInsets.all(30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 0.5,
                          blurRadius: 16,
                          color: Colors.black54,
                          offset: Offset(0.7, 0.7),
                        ),
                      ]),
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Requesting a Ride',
                              textAlign: TextAlign.center,
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Please wait',
                              textAlign: TextAlign.center,
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Finding a Driver',
                              textAlign: TextAlign.center,
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                      SizedBox(height: 22),
                      GestureDetector(
                        onTap: () {
                          if (cancelContainerOpen) {
                            hideCancelContainer();
                          }
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: Icon(Icons.close, size: 26),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Cancel Ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //도착지 지도에 표시
  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).userPickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "로딩중"));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      if (details != null) {
        tripDirectDetails = details;
      }
    });

    Navigator.pop(context);

    if (details != null && details.encodePoint != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodePolyLinePointsResult =
          polylinePoints.decodePolyline(details.encodePoint!);

      pLineCoordinates.clear();
      if (decodePolyLinePointsResult.isNotEmpty) {
        decodePolyLinePointsResult.forEach((PointLatLng pointLatLng) {
          pLineCoordinates
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

      polylineSet.clear();
      setState(() {
        Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
      });

      LatLngBounds latLngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds =
            LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
            northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
            northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
      } else {
        latLngBounds =
            LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      newGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      setState(() {
        markersSet.add(Util.setMarker(BitmapDescriptor.hueYellow,
            initialPos.placeName.toString(), "현재위치", pickUpLatLng, "pickUpId"));
        markersSet.add(Util.setMarker(BitmapDescriptor.hueRed,
            finalPos.placeName.toString(), "도착지", dropOffLatLng, "dropOffId"));
        circlesSet
            .add(Util.setCircle(Colors.blueAccent, pickUpLatLng, "pickUpId"));
        circlesSet
            .add(Util.setCircle(Colors.deepPurple, dropOffLatLng, "dropOffId"));
      });
    }
  }
}
