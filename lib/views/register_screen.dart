import 'package:app_intervention/views/otp_verification_screen.dart';
import 'package:app_intervention/views/profile_setting_screen.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/auth_controller.dart';
import '../widgets/intervetion_intro_widget.dart';
import '../widgets/register_widget.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final countryPicker = const  FlCountryCodePicker();
  
  CountryCode countryCode = CountryCode(name: 'Algeria', code: "DZ", dialCode: "+213");

  onSubmit(String? input){
    Get.to(()=>OtpVerificationScreen(countryCode.dialCode+input!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              intervetionIntroWidget(),
              const SizedBox(
                height: 40,
              ),
              registerWidget(countryCode,()async{
                final code = await countryPicker.showPicker(context: context);
                if (code != null)  {countryCode = code;}
                setState(() {

                });
              },onSubmit),

            ],
          ),
        ),
      ),
    );
  }
}