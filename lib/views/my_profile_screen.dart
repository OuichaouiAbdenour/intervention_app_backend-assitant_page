import 'dart:io';
import 'dart:ui';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';

import '../controller/auth_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/intervetion_intro_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../widgets/slaid_bar_widget.dart';




class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userTypeController=TextEditingController();
  TextEditingController genderController=TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  TextEditingController NewPasswordController=TextEditingController();
  TextEditingController OldPasswordController=TextEditingController();
  late String imageUrl;

  TextEditingController registrationNumberController = TextEditingController();
  AuthController authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;




  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  void setImageFromUrl(String url) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File file = File('$tempPath/Profile_Image_'+'$usernameController'+'.jpg');
    final http.Response response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      selectedImage = file;
    });
  }
  DateTime selectedDate=DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool changePassword=false;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    firstnameController.text = authController.myUser.value.firstName ?? "";
    lastnameController.text = authController.myUser.value.lastName ?? "";
    usernameController.text = authController.myUser.value.username ?? "";
    emailController.text = authController.myUser.value.email ?? "";
    registrationNumberController.text=authController.myUser.value.registrationNumber??"";
    userTypeController.text=authController.myUser.value.userType??"";
    genderController.text=authController.myUser.value.gender??"";
    passwordController.text = authController.myUser.value.password ?? "";
    imageUrl = authController.myUser.value.image??"";

  }

  @override
  Widget build(BuildContext context) {


    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      drawer: buildDrawer(authController),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  interventionIntroWidgetWithoutLogos(title: 'My Profile'),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      child: selectedImage == null
                          ? authController.myUser.value.image != null
                              ? Container(
                                  width: 120,
                                  height: 120,
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(authController
                                              .myUser.value.image!),
                                          fit: BoxFit.fill),
                                      shape: BoxShape.circle,
                                      color: Color(0xffD6D6D6)),
                                )
                              : Container(
                                  width: 120,
                                  height: 120,
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffD6D6D6)),
                                  child: Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                          : Container(
                              width: 120,
                              height: 120,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.fill),
                                  shape: BoxShape.circle,
                                  color: Color(0xffD6D6D6)),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    TextFieldWidget(
                      'FirstName',
                      Icons.person_outlined,
                      firstnameController,
                      "",
                      (String? input) {
                        //validation de firstname (no empty)
                        if (input == null || input.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget(
                      'LastName',
                      Icons.person_outlined,
                      lastnameController,
                      "",
                      (String? input) {
                        //validation de lastname no empty
                        if (input == null || input.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget(
                      'UserName',
                      Icons.person_outlined,
                      usernameController,
                      "",
                      (String? input) {
                        //validation de username(no emply et lenth>8 et contient des lettre et number
                        if (input == null || input.isEmpty) {
                          return "Username is required";
                        }
                        if (input.length < 8) {
                          return "Username must be at least 8 characters";
                        }
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$')
                            .hasMatch(input)) {
                          return "Username must contain both letters and numbers";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //champ pour ajout la Date de naissance

                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget(
                      'Email',
                      Icons.email_outlined,
                      emailController,
                      "",
                      (String? input) {
                        //validation de email (no empty et validation forma de email)
                        if (input == null || input.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!EmailValidator.validate(input)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    if (authController.typeOfUser == 'Firefighter' ||
                        authController.typeOfUser == 'Police officer')
                      TextFieldWidget(
                        'registration number',
                        Icons.numbers_outlined,
                        registrationNumberController,
                        "",
                        (String? input) {
                          if (input == null || input.isEmpty) {
                            return 'Please enter your registration Number';
                          }
                        },

                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10),

                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null
                                  ? dateFormatter.format(selectedDate)
                                  : 'Select Date',
                            ),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setState(() {
                          changePassword = !changePassword;
                        });
                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (changePassword)
                      Column(
                        children: [
                          TextFieldWidget(
                            'old password',
                            Icons.password_outlined,
                            OldPasswordController,
                            "password",
                                (String? input) {

                              if (authController.verifyPassword(input!, passwordController.text)) {
                                return "The old password is wrong";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            'new password',
                            Icons.password_outlined,
                            NewPasswordController,
                            "password",
                                (String? input) {
                              // validation de password (no empty et lenth>8 et contient des lettre et number
                              if (input == null || input.isEmpty) {
                                return "New Password is required";
                              }
                              if (input.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(input)) {
                                return "The password must contain both letters and numbers";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            'Confirm new password',
                            Icons.password_outlined,
                            confirmNewPasswordController,
                            "password",
                                (String? input) {
                              // validation confirm password (password=confirmpassword)
                              if (confirmNewPasswordController.text !=
                                  NewPasswordController.text) {
                                passwordController.text=authController.hashPassword(input!);

                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(() => authController.isProfileUploading.value
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : greenButton('Update', () {
                      if (!formkey.currentState!.validate()) {
                        return;
                      }
                      if (selectedImage != null) {
                        authController.isProfileUploading(true);
                        authController.addDataToFirestore(
                          firstnameController.text,
                          lastnameController.text,
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          genderController.text,
                          registrationNumberController.text,
                          selectedImage!,
                          selectedDate
                        );
                      }
                      else {
                        authController.isProfileUploading(true);
                        authController.UpdateDataToFirestore(
                          firstnameController.text,
                          lastnameController.text,
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          genderController.text,
                          registrationNumberController.text,
                          imageUrl,
                          selectedDate
                        );
                      }

                    }),
                    ),
                  ],
                ),
              ),
            )
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
            validator: (input)=> validator!(input),
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
