import 'dart:async';
import 'dart:ffi';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:app_intervention/controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_place/google_place.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/location_controller.dart';
import '../controller/polyline_handler.dart';
import '../utils/app_colors.dart';
import '../widgets/build_bottom_sheet_widget.dart';
import '../widgets/build_profile_tile_widget.dart';
import '../widgets/slaid_bar_widget.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'login_screen.dart';

class HomeScreenCitizen extends StatefulWidget {
  //String phoneNumber;
  //String typeOfUser;
  AuthController authController;
  HomeScreenCitizen(this.authController, {super.key});
  /*HomeScreen(String typeOfUser,String phoneNumber, {super.key}){
    this.phoneNumber=phoneNumber;
    this.typeOfUser=typeOfUser;
  }*/

  @override
  State<HomeScreenCitizen> createState() => _HomeScreenCitizenState();
}

class _HomeScreenCitizenState extends State<HomeScreenCitizen> {
  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();
  /*late LatLng source;
  Set<Marker> markers=Set<Marker>();*/
  late Position? _currentPosition = null;
  final Set<Polyline> _polyline = {};
  bool showError = false;

  bool showProgresseIndicator = false;
  late var intervenant = null;
  @override
  void initState() {
    super.initState();

    authController = widget.authController;
    authController.getUserInfo();
    if (intervenant != null)
      authController.getIntervenantData(dropdownValue, intervenant.id);
    _getCurrentLocation();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  _listenStatIntervenant(BuildContext context) async {
    if (intervenant != null){

        await authController.getIntervenantData(dropdownValue, intervenant.id);

        if(authController.myIntervenant.value.stat=="libre"){

          setState(() {
            _polyline.clear();
            _markers.clear();
          });
        }

    }
    Timer(Duration(seconds: 20), () async {
      if (intervenant == null) {
        setState(() {
          showProgresseIndicator = false;
          showError = true;
        });
      } else {
        if (authController.myIntervenant.value.stat != null) {
          if ("occupee" != authController.myIntervenant.value.stat) {
            Map<String, dynamic> data = {
              'occupee': "libre",
              'citizenPhoneNumber': "",
            };
            await FirebaseFirestore.instance
                .collection(authController.myIntervenant.value.typeOfUser!)
                .doc(authController.myIntervenant.value.phoneNumber!)
                .update(data)
                .catchError((error) {
              print('Error sending location data to Firebase: $error');
            });
            setState(() {
              showProgresseIndicator = false;
              showError = true;
            });
          } else {
            setState(() {
              showProgresseIndicator = false;
            });
            final LatLng startPoint =
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
            final LatLng endPoint =
                LatLng(intervenant["latitude"], intervenant["longitude"]);
            final Polyline polyline = Polyline(
              polylineId: PolylineId('myPolyline'),
              color: Colors.blue,
              points: [startPoint, endPoint],
              width: 3,
            );

            double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            double markerSize =
                48 * devicePixelRatio; // Adjust the size as needed

            ImageConfiguration configuration =
                createLocalImageConfiguration(context);
            BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
              configuration,
              'assets/pompier.png', // Replace with your image asset path
            );

            _markers.add(
              Marker(
                markerId: MarkerId("3"),
                icon: markerIcon,
                position: endPoint,
                infoWindow: InfoWindow(
                  title: 'Intervenant position',
                ),
              ),
            );
            _polyline.clear();
            _polyline.add(polyline);
          }
        }
      }
    });
  }

  void _getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _kGooglePlex = CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.4746,
      );
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _kGooglePlex;
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {
    if (authController.myIntervenant.value.stat != null) {
      setState(() {
        FirebaseFirestore.instance
            .collection(dropdownValue)
            .doc(intervenant.id)
            .snapshots()
            .listen((event) {
          if (event.data() != null) {
            var data = event.data() as Map<String, dynamic>;
            if (data['occupee'] == "libre") {
              setState(() {
                _polyline.clear();
                _markers.clear();
              });
            }
          }
        });
      });
    }
    return _currentPosition == null
        ? Scaffold(
            drawer: buildDrawer(authController),
            body: Container(
                child: Center(
              child: CircularProgressIndicator(),
            )))
        : Scaffold(
            drawer: buildDrawer(authController),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    markers: Set<Marker>.of(_markers),
                    polylines: _polyline,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      myMapController = controller;
                      // myMapController!.setMapStyle(_mapStyle);
                      _controller.complete(controller);
                    },
                    initialCameraPosition: _kGooglePlex,
                  ),
                ),
                buildProfileTile(authController),
                buildCurrentLocationIcon(),
                buildBottomSheet(context),
                Center(
                  child: showProgresseIndicator
                      ? CircularProgressIndicator()
                      : showError
                          ? AlertDialog(
                              title: Text('Error'),
                              content: Text('No intervenants available.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showError = false;
                                    }); // Dismiss the dialog
                                    // Perform any additional actions here
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            )
                          : Center(),
                ),
              ],
            ),
          );
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 8),
        child: GestureDetector(
          onTap: () async {
            // marker added for current users location
            _markers.add(Marker(
              markerId: MarkerId("2"),
              position: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: InfoWindow(
                title: 'My Current Location',
              ),
            ));

            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _openGoogleMaps(String startLatitude, String startLongitude,
      String endLatitude, String endLongitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$endLatitude,$endLongitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Widget buildBottomSheet(BuildContext context) {
    apiKey = 'AIzaSyBIRvT37fhcOSIcTJCVt8nIyNlMPeEB-LY';
    googlePlace = GooglePlace(apiKey);
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
          buildSourceSheetTypeInterventation(context);
        },
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.055,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              "Declaration Of Intervantaion",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  showGoogleAutoComplete(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null)
      predictions = result!.predictions!;
  }
/*void buildSourceSheetPositionOfInterventation(BuildContext context) {


  Get.bottomSheet(Container(
    width: Get.width,
    height: Get.height * 0.33,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "choose position of intervention",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      onChanged: (bool? value){
                        isCheckedCurrentLocation=value!;
                        Get.back();
                        buildSourceSheetPositionOfInterventation(context);
                      },
                      value: isCheckedCurrentLocation,
                    ),
                      Expanded(
                        child: Visibility(

                          visible: !isCheckedCurrentLocation,
                          child:TextFormField(
                            onChanged:(String? value){
                              showGoogleAutoComplete(value!);
                              debugPrint(predictions.toString());
                            },


                          ) )

                        ),

                    Expanded(
                        child: Visibility(

                            visible: isCheckedCurrentLocation,
                            child:Text("Select current position") )

                    ),

                  ],
                )
              ),
            ],
          ),
        ),


        const SizedBox(height: 20,),
        Container(
          width: Get.width,
          height: Get.height*0.06,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: () async {
              if (isCheckedCurrentLocation) {
                 position=await getUserCurrentLocation();
                buildSourceSheetTypeInterventation();
              } else {

              }
            },
            child: const Text('Next'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
          ),
        ),

      ],
    ),
  ));
}

*/

  void buildSourceSheetTypeInterventation(BuildContext context) {
    Get.bottomSheet(Container(
      width: Get.width,
      height: Get.height * 0.33,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            "À qui š'adresse cette déclaration?",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.07,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    iconEnabledColor: Colors.white,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      dropdownValue = newValue!;
                      Get.back();
                      buildSourceSheetTypeInterventation(context);
                    },
                    items: <String>['Firefighter', 'Police officer']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_downward_outlined,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.06,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 4,
                      blurRadius: 10)
                ]),
            child: ElevatedButton(
              onPressed: () {
                if (dropdownValue == 'Firefighter') {
                  dropdownValueTypeFirefighter = 'A fire';
                  showDescriptionFieldFirefighter = false;
                  buildSourceSheetFormFirefighter(
                      showDescriptionFieldFirefighter, context);
                } else if (dropdownValue == 'Police officer') {
                  dropdownValueTypePoliceOfficer = 'theft';
                  showDescriptionFieldPoliceOfficer = false;
                  buildSourceSheetFormPoliceOfficer(
                      showDescriptionFieldPoliceOfficer, context);
                }
              },
              child: const Text('Next'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void buildSourceSheetFormFirefighter(
      bool showDescriptionFieldFirefighter, BuildContext context) {
    Get.bottomSheet(Container(
      width: Get.width,
      height:
          showDescriptionFieldFirefighter ? Get.height * 0.9 : Get.height * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Statement For Firefighter",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Intervention Type",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.07,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValueTypeFirefighter,
                    iconEnabledColor: Colors.white,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      if (newValue == "something else") {
                        showDescriptionFieldFirefighter = true;
                      } else {
                        showDescriptionFieldFirefighter = false;
                      }
                      dropdownValueTypeFirefighter = newValue!;
                      Get.back();
                      buildSourceSheetFormFirefighter(
                          showDescriptionFieldFirefighter, context);
                    },
                    items: <String>[
                      'A fire',
                      'Gas',
                      'Traffic Accident',
                      'something else'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_downward_outlined,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          if (showDescriptionFieldFirefighter)
            Container(
              width: Get.width,
              height: Get.height * 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: descriptionControllerPoliceOfficer,
                decoration: const InputDecoration(
                  hintText: "Enter description",
                  border: InputBorder.none,
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Accident Situation",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.07,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValueStateFirefighter,
                    iconEnabledColor: Colors.white,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      dropdownValueStateFirefighter = newValue!;
                      Get.back();
                      buildSourceSheetFormFirefighter(
                          showDescriptionFieldFirefighter, context);
                    },
                    items: <String>['normal', 'Difficult', 'Very difficult']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_downward_outlined,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              width: Get.width,
              height: Get.height * 0.06,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 4,
                        blurRadius: 10)
                  ]),
              child: ElevatedButton(
                onPressed: () async {
                  bool confirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Text("Are you sure you want to confirm?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                  true); // Renvoie true si l'option "Yes" est sélectionnée
                            },
                            child: Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                  false); // Renvoie false si l'option "No" est sélectionnée
                            },
                            child: Text("No"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    Get.back();
                    Get.back();
                    //selon les inpute "dropdownValueState" et "dropdownValueType" afficter vers bon recherche de pompier
                    LocationController locationController =
                        LocationController();
                    locationController.setSource(_currentPosition!);
                    locationController.setTypeOfUset(dropdownValue);

                    setState(() {
                      showProgresseIndicator = true;

                      showError = false;
                    });
                    intervenant = await locationController
                        .selectIntervenant(authController.phoneNumber);
// Attach a listener to the field

                    await _listenStatIntervenant(context);

                    //_openGoogleMaps(startLatitude,startLongitude,test["latitude"].toString(),test["longitude"].toString());
                  }
                },
                child: const Text('Confirmation'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void buildSourceSheetFormPoliceOfficer(
      bool showDescriptionField, BuildContext context) {
    Get.bottomSheet(Container(
      width: Get.width,
      height: showDescriptionField ? Get.height * 0.9 : Get.height * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Statement For Police Officer",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Intervention Type",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.07,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValueTypePoliceOfficer,
                    iconEnabledColor: Colors.white,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      if (newValue == "something else") {
                        showDescriptionFieldPoliceOfficer = true;
                      } else {
                        showDescriptionFieldPoliceOfficer = false;
                      }
                      dropdownValueTypePoliceOfficer = newValue!;
                      Get.back();
                      buildSourceSheetFormPoliceOfficer(
                          showDescriptionFieldPoliceOfficer, context);
                    },
                    items: <String>['fighting', 'theft', 'something else']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_downward_outlined, color: Colors.green),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          if (showDescriptionFieldPoliceOfficer)
            Container(
              width: Get.width,
              height: Get.height * 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: descriptionControllerPoliceOfficer,
                decoration: const InputDecoration(
                  hintText: "Enter description",
                  border: InputBorder.none,
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Accident Situation",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.07,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValueStatePoliceOfficer,
                    iconEnabledColor: Colors.white,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      dropdownValueStatePoliceOfficer = newValue!;
                      Get.back();
                      buildSourceSheetFormPoliceOfficer(
                          showDescriptionField, context);
                    },
                    items: <String>['normal', 'Difficult', 'Very difficult']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_downward_outlined,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: Get.width,
            height: Get.height * 0.06,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 4,
                      blurRadius: 10)
                ]),
            child: ElevatedButton(
              onPressed: () async {
                bool confirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmation"),
                      content: Text("Are you sure you want to confirm?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                                true); // Renvoie true si l'option "Yes" est sélectionnée
                          },
                          child: Text("Yes"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                                false); // Renvoie false si l'option "No" est sélectionnée
                          },
                          child: Text("No"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  Get.back();
                  Get.back();
                  //selon les inpute "dropdownValueState" et "dropdownValueType" afficter vers bon recherche de pompier
                  LocationController locationController =
                  LocationController();
                  locationController.setSource(_currentPosition!);
                  locationController.setTypeOfUset(dropdownValue);

                  setState(() {
                    showProgresseIndicator = true;

                    showError = false;
                  });
                  intervenant = await locationController
                      .selectIntervenant(authController.phoneNumber);
// Attach a listener to the field

                  await _listenStatIntervenant(context);

                  //_openGoogleMaps(startLatitude,startLongitude,test["latitude"].toString(),test["longitude"].toString());
                }
              },
              child: const Text('Confirmation'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  late Uint8List markIcons;

  loadCustomMarker() async {
    markIcons = await loadAsset('assets/dest_marker.png', 100);
  }

  Future<Uint8List> loadAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
