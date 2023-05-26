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


class   CitizenDashboard extends StatefulWidget {
  //String phoneNumber;
  //String typeOfUser;
  AuthController authController;
  CitizenDashboard(this.authController, {super.key});
  /*HomeScreen(String typeOfUser,String phoneNumber, {super.key}){
    this.phoneNumber=phoneNumber;
    this.typeOfUser=typeOfUser;
  }*/

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();

  @override
  initState() {
    super.initState();
    authController = widget.authController;
    authController.getUserInfo();

  }
  // Start sending location data to Firebase periodically


  @override
  Widget build(BuildContext context) {

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
        drawer: buildDrawerAdmin(authController),
        body:Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0 ,right: 16.0,top :120),
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore.
                  collection('Citizen').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error retrieving data');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final firefighter = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: firefighter.length,
                      itemBuilder: (context, index) {
                        final metric = firefighter[index].data() as Map<String, dynamic>;
                        final nom = metric['firstName'];
                        final prenom = metric['lastName'];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(firefighter[index].id),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('firstName :${nom}'),
                                Text('lastName : ${prenom}'),
                                greenButton('delete citizen', (){
                                  firestore.collection('Citizen').doc(firefighter[index].id).delete();
                                }),
                                const SizedBox(
                                  height: 30,
                                ),

                              ],
                            ),
                            onTap: () {
                              // Handle onTap action
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

              ),

              buildProfileTile(authController),]));

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
