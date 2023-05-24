import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_intervention/controller/auth_controller.dart';

Widget buildCurrentLocationIcon(
    GoogleMapController? myMapController /*,LatLng currentLocation*/
) {
  return Align(
    alignment: Alignment.bottomRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 40, right: 8),
      child: GestureDetector(
        onTap: () {


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
