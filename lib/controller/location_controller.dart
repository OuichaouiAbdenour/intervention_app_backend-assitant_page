import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationController extends GetxController {
  late Position source;
  final double coffTime = 0.001;
  final double coffDistnace = 0.0002;
  final double coffAge = 0.0001;
  late String typeOfUser;
  setSource(Position source) {
    this.source = source;
  }

  setTypeOfUset(String typeOfUser) {
    this.typeOfUser = typeOfUser;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double radians(double degree) {
    return degree * pi / 180;
  }

  getDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers
    double latDistance = radians(lat1 - lat2);
    double lonDistance = radians(lon1 - lon2);
    double a = pow(sin(latDistance / 2), 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * pow(sin(lonDistance / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c; // distance in km
    return distance;
  }

  double costFunction(Timestamp birthDate , Timestamp timestamp, double distnace) {
    return coffAge * ((DateTime.now().difference(birthDate.toDate()).inDays)) +
        coffTime * (DateTime.now().difference(timestamp.toDate()).inDays) +
        coffDistnace * distnace;
  }

  void openGoogleMaps(String startLatitude, String startLongitude,
      String endLatitude, String endLongitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$endLatitude,$endLongitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  selectIntervenant(String phoneNumber) async {
    CollectionReference usersRef = await _firestore.collection(typeOfUser);

    // Query the users collection where age is greater than or equal to 18
    QuerySnapshot<Object?> querySnapshot =
    await usersRef.where('occupee', isEqualTo: "libre").get();
    double min = double.infinity;
    late var docRef=null;
    for (QueryDocumentSnapshot<Object?> documentSnapshot
    in querySnapshot.docs) {
      Timestamp birthDate = documentSnapshot.get('birthDate');
      Timestamp lastInterventionDate =
      documentSnapshot.get("lastInterventionDate");
      double lat1 = documentSnapshot.get("latitude");
      double lon1 = documentSnapshot.get("longitude");
      double distance =
      getDistance(lat1, lon1, source.latitude, source.longitude);
      double cost = costFunction(birthDate, lastInterventionDate, distance);
      if (min > cost) {
        min = cost;
        docRef = documentSnapshot.reference;
      }
      //print(name);
    }
    if (docRef != null){
      Map<String, dynamic> data = {'occupee': "demander",
        'citizenPhoneNumber': phoneNumber,

      };
    await docRef.update(data).catchError((error) {
      print('Error sending location data to Firebase: $error');
    });
    return docRef.get();
  }
  return null;

  }
}
