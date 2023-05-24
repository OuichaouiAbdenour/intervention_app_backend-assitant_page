import 'package:app_intervention/views/HomeScreenAssistant.dart';
import 'package:app_intervention/views/HomeScreenCitizen.dart';
import 'package:app_intervention/views/login_screen.dart';
import 'package:app_intervention/views/profile_setting_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_intervention/views/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_platform_interface/src/types/polyline.dart';
import 'controller/auth_controller.dart';
import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'com.example.app_intervention',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    //AuthController authController = Get.put(AuthController());
    //authController.decideRoute();


    final textTheme = Theme.of(context).textTheme;

    AuthController authController = Get.put(AuthController());
    authController.setPhoneNumber("+213791857211");
    authController.settypeOfUser("Citizen");

    return  GetMaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
      ),
      home:  HomeScreenCitizen(authController),
    );
  }
}
