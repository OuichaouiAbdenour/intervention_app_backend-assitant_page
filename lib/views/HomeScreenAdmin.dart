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


class HomeScreenAdmin extends StatefulWidget {
  //String phoneNumber;
  //String typeOfUser;
  AuthController authController;
  HomeScreenAdmin(this.authController, {super.key});
  /*HomeScreen(String typeOfUser,String phoneNumber, {super.key}){
    this.phoneNumber=phoneNumber;
    this.typeOfUser=typeOfUser;
  }*/

  @override
  State<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
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




  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {


    return  Scaffold(
        drawer: buildDrawer(authController),
        body: Stack(
            children: [
              buildProfileTile(authController),
            ]));
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
