import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

Widget intervetionIntroWidget() {
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/mask.png'), fit: BoxFit.cover)),
    height: Get.height * 0.6,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/equipe-dintervention-de-cummunity.png',
          height: 120,
          width: 120,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Intervention App',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget interventionIntroWidgetWithoutLogos({String title = "Register",String? subtitle}){
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/mask.png'),
            fit: BoxFit.fill
        )
    ),
    height: Get.height*0.3,
    child: Container(
        height: Get.height*0.1,
        width: Get.width,
        margin: EdgeInsets.only(bottom: Get.height*0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,style: GoogleFonts.poppins(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),),
            if(subtitle != null) Text(subtitle,style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.white),),

          ],
        )),

  );
}
