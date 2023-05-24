/*import 'dart:developer';
import 'dart:io';

import 'package:app_intervention/views/HomeScreenCitizen.dart';
import 'package:app_intervention/views/my_profile_screen.dart';
//import 'package:google_maps_webservice/places.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:path/path.dart' as path;
import 'package:app_intervention/views/login_screen.dart';
import 'package:app_intervention/views/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_intervention/views/profile_setting_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as Path;
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';

import '../views/HomeScreenAssistant.dart';
import '../models/intervention_model.dart'







class AuthController extends GetxController{
  late String phoneNumberCitizen;
  late String phoneNumberIntervenant;
  late String stat;
  setPhoneNumberCitizen(String phoneNumberCitizen){
    this.phoneNumberCitizen=phoneNumberCitizen;
  }
  setPhoneNumberIntervenant(String phoneNumberIntervenant){
    this.phoneNumberIntervenant=phoneNumberIntervenant;
  }


  var myIntervention = InterventionModel().obs;

  getUserInfo() {
    FirebaseFirestore.instance
        .collection('intervention')
        .doc(phoneNumber)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }


}
*/