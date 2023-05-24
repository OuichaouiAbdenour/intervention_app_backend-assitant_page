import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:app_intervention/controller/auth_controller.dart';
import 'package:app_intervention/utils/app_colors.dart';
import 'package:intl/intl.dart';

import 'package:app_intervention/widgets/intervetion_intro_widget.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
//import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart' as Path;
import 'package:app_intervention/controller/auth_controller.dart';
import '../controller/auth_controller.dart';

class ProfileSettingScreen extends StatefulWidget {
  String phoneNumber;
  ProfileSettingScreen(this.phoneNumber, {super.key});
  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController registrationNumberController = TextEditingController();

  AuthController authController= Get.put(AuthController());
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.phoneAuth(widget.phoneNumber);
  }




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

  List<String> userTypes = ['Citizen', 'Firefighter', 'Police officer'];
  late String userTypeController = 'Citizen';

  int _userTypeIndex = 0;
  //int _genderIndex = 0 ;
  String _genderIndex = 'male';

  bool isLoading=false;
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
  @override
  Widget build(BuildContext context) {
    registrationNumberController.text="";
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  interventionIntroWidgetWithoutLogos(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      child: selectedImage == null
                          ? Container(
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
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(input)) {
                          return "Username must contain both letters and numbers";
                        }
                        return null;

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
                      'Confirm PassWord',
                      Icons.password_outlined,
                      confirmPasswordController,
                      "password",
                          (String? input) {
                        // validation confirm password (password=confirmpassword)
                        if (confirmPasswordController.text !=
                            passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //creere drop dawn button pour select type users
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
                                    _genderIndex = 'Male';
                                  });
                                },
                              ),
                              Text(userTypes[index]),
                            ],
                          ),
                        ),
                      ],
                    ),

                    //gender
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sexe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (userTypeController == 'Firefighter')
                      Row(
                        children: [
                          Radio(
                            value: 'Male',
                            groupValue: _genderIndex,
                            onChanged: (value) {
                              setState(() {
                                _genderIndex = value
                                    .toString(); // affecter directement la chaîne de caractères à _genderIndex
                              });
                            },
                          ),
                          Text('male'),
                        ],
                      ),
                    if (userTypeController == 'Police officer' ||
                        userTypeController == 'Citizen')
                      Row(
                        children: [
                          Radio(
                            value: 'male',
                            groupValue: _genderIndex,
                            onChanged: (value) {
                              setState(() {
                                _genderIndex = value
                                    .toString(); // affecter directement la chaîne de caractères à _genderIndex
                              });
                            },
                          ),
                          Text('male'),
                          Radio(
                            value: 'Female',
                            groupValue: _genderIndex,
                            onChanged: (value) {
                              setState(() {
                                _genderIndex = value
                                    .toString(); // affecter directement la chaîne de caractères à _genderIndex
                              });
                            },
                          ),
                          Text('Female'),
                        ],
                      ),

                    if (userTypeController == 'Firefighter' ||
                        userTypeController == 'Police officer')
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
                      height: 30,
                    ),
                    Obx(() => authController.isProfileUploading.value
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : greenButton('Submit', () {


                      if(!formkey.currentState!.validate()){
                        return;
                      }

                      if (selectedImage == null) {
                        Get.snackbar('Warning', 'Please add your image');
                        return;
                      }
                      authController.isProfileUploading(true);
                      authController.settypeOfUser(userTypeController);
                      authController.setPhoneNumber(widget.phoneNumber);
                      authController.addDataToFirestore(
                          firstnameController.text,
                          lastnameController.text,
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          _genderIndex,
                          registrationNumberController.text,
                          selectedImage!,
                          selectedDate!,

                      );


                      //Get.to(()=>HomeScreen(userTypeController, widget.phoneNumber));
                    })),
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