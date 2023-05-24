import 'package:app_intervention/utils/app_colors.dart';
import 'package:app_intervention/widgets/pinput_widget.dart';
import 'package:app_intervention/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_constants.dart';

Widget otpVerificationWidget(){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(text: AppConstants.phoneVerification),
        textWidget(
            text: AppConstants.enterOtp,
            fontsize: 20,
            fontWeight: FontWeight.bold),
        const SizedBox(
          height: 40,
        ),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 3,
                    blurRadius: 3),
              ],
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                    width: Get.width,
                    height: 45,
                    child: RoundedWithShadow(),
                  )
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
            children: [
              TextSpan(
                text: AppConstants.resendCode + " ",
              ),
              TextSpan(
                  text: "10 "+AppConstants.seconds + " ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),

            ],
          ),
        ),
      ],
    ),
  );
}