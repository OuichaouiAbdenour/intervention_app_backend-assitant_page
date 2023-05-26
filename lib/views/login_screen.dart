import 'dart:io';

import 'package:app_intervention/views/register_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:app_intervention/controller/auth_controller.dart';
import 'package:app_intervention/utils/app_colors.dart';
import 'package:app_intervention/widgets/intervetion_intro_widget.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
//import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart' as Path;
import 'package:app_intervention/controller/auth_controller.dart';
import '../controller/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {



  String errorMessage;
  LoginScreen(this.errorMessage, {super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode =
      CountryCode(name: 'Algeria', code: 'DZ', dialCode: '+213');

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  //*********backend********************************************

  /*uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
          (value) {
        imageUrl = value;
        print("Download URL: $value");
      },
    );
    return imageUrl;
  }*/
  //**********************************************************

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  List<String> userTypes = ['Citizen', 'Firefighter', 'Police officer','admin'];
  late String userTypeController = 'Citizen';

  AuthController authController = Get.find<AuthController>();
  int _userTypeIndex = 0;

  //int _genderIndex = 0 ;
  String _genderIndex = 'male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            intervetionIntroWidget(),
            const SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 1)
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => () async {
                                  final code = await countryPicker.showPicker(
                                      context: context);
                                  // Null check
                                  if (code != null) countryCode = code;
                                  setState(() {});
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                          child: Container(
                                        child: countryCode.flagImage,
                                      )),
                                      textWidget(text: countryCode.dialCode),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.keyboard_arrow_down_rounded)
                                    ],
                                  ),
                                ),
                              )),
                          Container(
                            width: 1,
                            height: 55,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: phoneNumberController,
                                  validator: (String? input) {
                                    // validation de password (no empty et lenth>8 et contient des lettre et number
                                    if (input == null || input.isEmpty) {
                                      return "phone number  is required";
                                    }

                                    if (!RegExp(r'^[0-9]{9}$')
                                        .hasMatch(input)) {
                                      return "phone number format is incorrect";
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    hintText: AppConstants.enterMobileNumber,
                                    border: InputBorder.none,
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                    TextFieldWidget(
                      'PassWord',
                      Icons.password_outlined,
                      passwordController,
                      "password",
                      (String? input) {
                        // validation de password (no empty et lenth>8 et contient des lettre et number
                        if (input == null || input.isEmpty) {
                          return "Password is required";
                        }
                        if (input.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$')
                            .hasMatch(input)) {
                          return "The password must contain both letters and numbers";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ...List.generate(
                          userTypes.length,
                          (index) => Row(
                            children: [
                              Radio(
                                value: index,
                                groupValue: _userTypeIndex,
                                onChanged: (value) {
                                  setState(() {
                                    _userTypeIndex = value!;
                                    userTypeController =
                                        userTypes[_userTypeIndex];
                                  });
                                },
                              ),
                              Text(userTypes[index]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Obx(() => authController.isProfileUploading.value
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : greenButton('Submit', ()async {

                             authController.phoneNumber =
                                phoneNumberController.text;

                            if (!formkey.currentState!.validate()) {
                              return;
                            }

                            authController.isProfileUploading(true);
                      await authController.loginUser(
                                countryCode.dialCode +
                                    phoneNumberController.text,
                                passwordController.text,
                                userTypeController);
                        }
                    ),
                    ),
                    Row(
                      children: [
                        Text(widget.errorMessage,style: TextStyle(color: Colors.red)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    greenButton("register", () => {Get.to(RegisterScreen())}),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  TextFieldWidget(
      String title, IconData iconData, TextEditingController controller,
      [String? option, Function? validator]) {
    bool isPassword = option == 'password';
    bool obscureText = isPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: Get.width,
          // height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            validator: (input) => validator!(input),
            controller: controller,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xffA7A7A7)),
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  iconData,
                  color: AppColors.greenColor,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.greenColor,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
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
