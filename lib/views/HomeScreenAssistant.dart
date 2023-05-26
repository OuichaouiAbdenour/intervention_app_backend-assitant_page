import 'dart:async';

import 'package:app_intervention/controller/auth_controller.dart';
import 'package:app_intervention/controller/location_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';

import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../widgets/build_bottom_sheet_widget.dart';
import '../widgets/build_current_location_icon_widget.dart';
import '../widgets/build_profile_tile_widget.dart';
import '../widgets/build_bottom_sheet_widget.dart';
import '../widgets/slaid_bar_widget.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'login_screen.dart';


class HomeScreenAssistant extends StatefulWidget {
  //String phoneNumber;
  //String typeOfUser;
  AuthController authController;
  HomeScreenAssistant(this.authController, {super.key});
  /*HomeScreen(String typeOfUser,String phoneNumber, {super.key}){
    this.phoneNumber=phoneNumber;
    this.typeOfUser=typeOfUser;
  }*/

  @override
  State<HomeScreenAssistant> createState() => _HomeScreenAssistantState();
}

class _HomeScreenAssistantState extends State<HomeScreenAssistant> {
  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();
  /*late LatLng source;
  Set<Marker> markers=Set<Marker>();*/
  late Position? _currentPosition = null;
  late LatLng ? destination = null;
  late Stream<QuerySnapshot> _dataStream;
late String stat="libre";
  final Set<Polyline> _polyline = {};
  @override
initState() {
    super.initState();
    authController = widget.authController;
   FirebaseFirestore.instance
        .collection(authController.typeOfUser)
        .doc(authController.phoneNumber)
        .snapshots()
        .listen((event) {
          setState(() {

            authController.myUser.value = UserModel.fromJson(event.data()!);
          });
    });


    _getCurrentLocation();
    _startSendingDataToFirebase();
  }

  // Get current location using Geolocator plugin
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
      _startSendingDataToFirebase();
    });
  }
  // Start sending location data to Firebase periodically
  void _startSendingDataToFirebase() {
    // Set up a timer to send location data every 5 seconds
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPosition != null) {
        // Create a Firestore document reference with a timestamp as the document ID

        authController.updateLocation(_currentPosition!);
      }
    });
  }


  Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )
    ),
  ];

  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {


    return _currentPosition == null || this.authController.myUser.value.stat=="libre"
        ? Scaffold(
        drawer: buildDrawer(authController),
        body: _currentPosition ==null ?Container(
            child: Center(
              child :CircularProgressIndicator()
            ))
    :Stack(
            children: [
              buildProfileTile(authController),
            ]))
        : Scaffold(
      drawer: buildDrawer(authController),
      body:Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  markers: Set<Marker>.of(_markers),
                  polylines: _polyline,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller)  async {
                    myMapController = controller;
                    // myMapController!.setMapStyle(_mapStyle);
                    var citizen=await authController.getOtherCitizenInfo(authController.myUser.value.citizenPhoneNumber!);
                    final LatLng startPoint = LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude);


                    setState(() {
                     destination =
                          LatLng(citizen["latitude"], citizen["longitude"]);
                      final LatLng endPoint=destination!;
                      final Polyline polyline = Polyline(
                        polylineId: PolylineId('myPolyline'),
                        color: Colors.blue,
                        points: [startPoint, endPoint],
                        width: 3,
                      );

                      _markers.add(Marker(
                        markerId: MarkerId("3"),

                        position: endPoint,
                        infoWindow: InfoWindow(
                          title: 'Intervenant position',
                        ),),);
                      _polyline.add(polyline);
                    });
                    _controller.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 14.4746,
                  ),
                ),

                buildProfileTile(authController),
              ],

            ),
          ),
          this.authController.myUser.value.stat=="demander"?
          greenButton("valider",()  {

            setState(() {
              authController.validateIntervention();
              LocationController locationController= LocationController();
              locationController.openGoogleMaps(_currentPosition!.latitude.toString(),_currentPosition!.longitude.toString(),destination!.latitude.toString(),destination!.longitude.toString());
             _markers.clear();
             _polyline.clear();
            });

          }):greenButton("terminer", () {
    setState(()  {
 authController.terminateIntervention();

    });
    }),


        ],
      ),
    );
  }




  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 8),
        child: GestureDetector(
          onTap: () async {
            _markers.add(Marker(
              markerId: MarkerId("2"),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: InfoWindow(
                title: 'My Current Location',
              ),
            ));

            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 14,
            );

            final GoogleMapController controller =
                await _controller.future;
            controller.animateCamera(
                CameraUpdate.newCameraPosition(cameraPosition));
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
  Widget greenButton(String title, Function onPressed) {
    return MaterialButton(
      minWidth: Get.width,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: AppColors.greenColor,
      onPressed: () => onPressed(),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }


}
