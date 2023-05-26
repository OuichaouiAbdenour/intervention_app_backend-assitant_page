import 'dart:developer';
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

import '../views/HomeScreenAdmin.dart';
import '../views/HomeScreenAssistant.dart';

class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;
  var isProfileUploading = false.obs;
  late String phoneNumber;
  late String typeOfUser;
  setPhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
  }

  settypeOfUser(String typeOfUser) {
    this.typeOfUser = typeOfUser;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  phoneAuth(phoneNumber) async {
    try {
      this.phoneNumber = phoneNumber;
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');

          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occured $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LogedIn");
    Get.to(() => ProfileSettingScreen(phoneNumber));

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      //decideRoute();
    }).catchError((e) {
      print("Error while sign In $e");
    });

    /*await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    }).catchError((e) {
      print("Error while sign In $e");
    });*/
  }

  Future<String> getUrlImageProfile() async {
    var storageRef = FirebaseStorage.instance;

    String userId = 'users'; // Replace with the actual user ID or file path
    String fileName =
        phoneNumber + '.jpg'; // Replace with the actual file name or file path

    Reference ref = storageRef.ref().child('$userId/$fileName');

    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImage(File image) async {
    final imageUri = Uri.parse(image.path);
    final String outputUri = imageUri.resolve('./output.jpeg').toString();
    print(imageUri.toFilePath());

    File? compressed = await FlutterImageCompress.compressAndGetFile(
        imageUri.toString(), outputUri,
        quality: 80, format: CompressFormat.jpeg);
    print(imageUri);
    print(outputUri);
    var reference = FirebaseStorage.instance.ref().child(
        'users/$phoneNumber.jpg'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(compressed!);
    String imageUrl = "";
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        imageUrl = value;
        print("Download URL: $value");
      },
    );
    return imageUrl;
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPassword(String password, String hashedPassword) {
    var bytes = utf8.encode(password);
    final sha256 = SHA256Digest().process(Uint8List.fromList(bytes));
    final base64Sha256 = base64.encode(sha256);

    return base64Sha256 == hashedPassword;
  }

  void addDataToFirestore(
      String firstName,
      String lastName,
      String username,
      String email,
      String password,
      String gender,
      String registrationNumber,
      File? selectedImage,
      DateTime birthDate) async {
    try {
      String? url_new = null;
      if (selectedImage != null) {
        url_new = await uploadImage(selectedImage);
      }
      password = hashPassword(password);
      if (typeOfUser == "Citizen") {
        await _firestore.collection(typeOfUser).doc(phoneNumber).set({
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
          'gender': gender,
          'image': url_new,
          'registrationNumber': registrationNumber,
          'birthDate': birthDate,


        }).then((value) {
          isProfileUploading(false);
        });
        print('Data added successfully!');
      }
      else{
        await _firestore.collection(typeOfUser).doc(phoneNumber).set({
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
          'gender': gender,
          'image': url_new,
          'registrationNumber': registrationNumber,
          'birthDate': birthDate,
          'latitude': 0,
          'longitude': 0,
          'citizenPhoneNumber':"",
          'lastInterventionDate':DateTime.now(),
          'valid':false,
          'isConnected':true,
          'occupee':'libre',
          'countIntervention':0


        }).then((value) {
          isProfileUploading(false);
        });
      }
    } catch (e) {
      print('Error adding data: $e');
      Get.to(() => ProfileSettingScreen(phoneNumber));
    }
  }
updatePosition(LatLng position) async {
  await _firestore.collection(typeOfUser).doc(phoneNumber).update({
    'latitude': position.latitude,
    'longitude':position.longitude,});
}
void UpdateDataToFirestore(
      String firstName,
      String lastName,
      String username,
      String email,
      String password,
      String gender,
      String registrationNumber,
      String selectedImage,
      DateTime birthDate) async {
    try {
      password = hashPassword(password);
      await _firestore.collection(typeOfUser).doc(phoneNumber).update({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
        'gender': gender,
        'image': selectedImage,
        'registrationNumber': registrationNumber,
        'birthDate': birthDate,
        'isConnected':true
      }).then((value) {
        isProfileUploading(false);
        if (typeOfUser == "Citizen")
          Get.to(() => HomeScreenCitizen(this));
        else if (typeOfUser != "Admin") Get.to(() => HomeScreenAssistant(this));
      });
      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
      Get.to(() => MyProfile());
    }
  }

  /*storeUserInfo(
      File? selectedImage,
      String firstname,
      String lastname,
      String username,
      String email,
      String password) async {

    if (selectedImage != null) {
      String url = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'email': email,
      'password' : password

    }).then((value) {
      isProfileUploading(false);
      Get.to(() => LoginScreen());
    });
  }*/

  loginUser(String phoneNumber, String password, String typeOfUser) async {
    var collection = _firestore.collection(typeOfUser);
    var field = collection.doc(phoneNumber);
    var value = field.get();
    await _firestore
        .collection(typeOfUser)
        .doc(phoneNumber)
        .get()
        .then((value) {
      /*if(isLoginAsDriver){*/

      if (value.exists) {
        print(value["firstName"]);


        if (value["password"] == hashPassword(password)) {
          this.isProfileUploading(false);
          this.phoneNumber = phoneNumber;
          this.typeOfUser = typeOfUser;
            if (typeOfUser == "admin")
              Get.to(() => HomeScreenAdmin(this));
            else if (typeOfUser == "Citizen")
              Get.to(() => HomeScreenCitizen(this));
            else {
              if(value['valid']) {
                Map<String, dynamic> data = {
                  'isConnected': true,
                };
                _firestore
                    .collection(typeOfUser)
                    .doc(phoneNumber)
                    .update(data);
                Get.to(() => HomeScreenAssistant(this));
              }else{
                this.isProfileUploading(false);
                Get.back();
                Get.to(() => LoginScreen("the account is not valid"));
              }
            }
          }
         else {
          this.isProfileUploading(false);
          Get.back();
          Get.to(LoginScreen("wrong password"));
        }}
      else {
        this.isProfileUploading(false);
        Get.back();
        Get.to(LoginScreen("wrong phone number"));
        //Get.offAll(() => DriverProfileSetup());
      }

      /*}else{
          if (value.exists) {
            Get.offAll(() => HomeScreen());
          } else {
            Get.offAll(() => ProfileSettingScreen());
          }
        }*/
    }).catchError((e) {
      print("Error while decideRoute is $e");
      this.isProfileUploading(false);
      Get.back();
      Get.to(() => LoginScreen("wrong phone number or wrong connection"));
    });
  }
logout(){
  Map<String, dynamic> data = {
    'isConnected': false,
  };
  _firestore.collection(typeOfUser).doc(phoneNumber).update(data);
  FirebaseAuth.instance.signOut();
}
// Fonction pour obtenir la position actuelle de l'utilisateur
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  /*late UserModel user;

  Future<void> getUserFromFirebase() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection(typeOfUser).doc(phoneNumber).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        this.user = UserModel.fromJson(data);
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('Exception: $e');
    }
  }*/

  var myUser = UserModel().obs;
  var myIntervenant = UserModel().obs;
  getUserInfo() async {
    await _firestore
        .collection(typeOfUser)
        .doc(phoneNumber)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
      myUser.value.phoneNumber=event.id;
      myUser.value.typeOfUser=this.typeOfUser;
    });
  }

  getIntervenantData(String typeOfIntervenant,phoneNumber)  async {
    await _firestore
        .collection(typeOfIntervenant)
        .doc(phoneNumber)
        .snapshots()
        .listen((event) {
          if(event.data()!=null){
      myIntervenant.value = UserModel.fromJson(event.data()!);
      myIntervenant.value.phoneNumber=event.id;
      myIntervenant.value.typeOfUser=typeOfIntervenant;}
          else{

            myIntervenant.value.phoneNumber=event.id;
            myIntervenant.value.typeOfUser=typeOfIntervenant;
          }
    });
  }


  getOtherCitizenInfo(String phoneNumberCitizen) async {
    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection("Citizen");
    DocumentReference<Map<String, dynamic>> documentReference =
        collectionReference.doc(phoneNumberCitizen);
    print(phoneNumberCitizen);
    dynamic fieldValue;
// Get the value of a specific field
    await documentReference
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        // Access the field value
        fieldValue = snapshot.data()!;

        // Do something with the field value
        print(fieldValue);
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error retrieving field value: $error');
    });

    return fieldValue;
  }

  validateIntervention() {
    Map<String, dynamic> data = {
      'occupee': "occupee",
      'countIntervention': myUser.value.countIntervention!+1,
    };
    _firestore.collection(this.typeOfUser).doc(this.phoneNumber).update(data);
  }

  terminateIntervention() {
    Map<String, dynamic> data = {
      'occupee': "libre",
    };
    _firestore.collection(this.typeOfUser).doc(this.phoneNumber).update(data);
  }

  updateLocation(Position currentPosition) {
    DocumentReference docRef =
        _firestore.collection(this.typeOfUser).doc(this.phoneNumber);

    // Create a data map with the current location data
    Map<String, dynamic> data = {
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Set the data in the Firestore document
    docRef.update(data).catchError((error) {
      print('Error sending location data to Firebase: $error');
    });
  }

  /*Future<Prediction?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "dz",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: AppConstants.kGoogleApiKey,
      components: [new Component(Component.country, "pk")],
      types: [],
      hint: "Search City",
    );

    return p;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
    await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }*/
}
