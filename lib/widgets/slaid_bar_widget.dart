import 'package:app_intervention/views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/auth_controller.dart';
import '../utils/app_colors.dart';
import '../views/FirefightDashbord.dart';
import '../views/HomeScreenCitizen.dart';
import '../views/my_profile_screen.dart';
import '../views/register_screen.dart';

buildDrawerItem(
    {required String title,
    required Function onPressed,
    Color color = Colors.black,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    double height = 45,
    bool isVisible = false}) {
  return SizedBox(
    height: height,
    child: ListTile(
      contentPadding: EdgeInsets.all(0),
      // minVerticalPadding: 0,
      dense: true,
      onTap: () => onPressed(),
      title: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: fontSize, fontWeight: fontWeight, color: color),
          ),
          const SizedBox(
            width: 5,
          ),
          isVisible
              ? CircleAvatar(
                  backgroundColor: AppColors.greenColor,
                  radius: 15,
                  child: Text(
                    '1',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                )
              : Container()
        ],
      ),
    ),
  );
}

Widget buildDrawer(AuthController authController) {
  return Drawer(
    child: Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(() => const MyProfile());
          },
          child: Obx(
            () => authController.myUser.value.username == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    height: 150,
                    child: DrawerHeader(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: Get.width * 0.22,
                          height: Get.width * 0.22,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: authController.myUser.value.image == null
                                  ? const DecorationImage(
                                      image: AssetImage('assets/person.png'),
                                      fit: BoxFit.fill)
                                  : DecorationImage(
                                      image: NetworkImage(
                                          authController.myUser.value.image!),
                                      fit: BoxFit.fill)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Good Morning, ',
                                  style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.28),
                                      fontSize: 14)),
                              Text(
                                authController.myUser.value.username == null
                                    ? "Mark"
                                    : authController.myUser.value.username!,
                                style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            ],
                          ),
                        )
                      ],
                    )),
                  ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              buildDrawerItem(
                  title: 'Home',
                  onPressed: () => {Get.to(() => HomeScreenCitizen(authController))},
                  isVisible: true),
              buildDrawerItem(title: 'History', onPressed: () {}),
              buildDrawerItem(
                  title: 'Profile',
                  onPressed: () {
                    Get.to(() => const MyProfile());
                  }),
              buildDrawerItem(
                  title: 'Log Out',
                  onPressed: ()  {
                    FirebaseAuth.instance.signOut();
                    Get.to(()=>LoginScreen(""));

                  }),
            ],
          ),
        ),
        Spacer(),
        Divider(),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
  );
}

Widget buildDrawerAdmin(AuthController authController) {
  return Drawer(
    child: Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(() => const MyProfile());
          },
          child: Obx(
                () => authController.myUser.value.username == null
                ? Center(
              child: CircularProgressIndicator(),
            )
                : SizedBox(
              height: 150,
              child: DrawerHeader(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: Get.width * 0.22,
                        height: Get.width * 0.22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: authController.myUser.value.image == null
                                ? const DecorationImage(
                                image: AssetImage('assets/person.png'),
                                fit: BoxFit.fill)
                                : DecorationImage(
                                image: NetworkImage(
                                    authController.myUser.value.image!),
                                fit: BoxFit.fill)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Good Morning, ',
                                style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.28),
                                    fontSize: 14)),
                            Text(
                              authController.myUser.value.username == null
                                  ? "Mark"
                                  : authController.myUser.value.username!,
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              buildDrawerItem(
                  title: 'Home',
                  onPressed: () => {Get.to(() => HomeScreenCitizen(authController))},
                  isVisible: true),
              buildDrawerItem(title: 'History', onPressed: () {}),
              buildDrawerItem(
                  title: 'Profile',
                  onPressed: () {
                    Get.to(() => FirefightDashboard(authController));
                  }),
              buildDrawerItem(
                  title: 'Log Out',
                  onPressed: ()  {
                    FirebaseAuth.instance.signOut();
                    Get.to(()=>LoginScreen(""));

                  }),
            ],
          ),
        ),
        Spacer(),
        Divider(),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
  );
}

