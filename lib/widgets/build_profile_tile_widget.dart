import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';

import '../controller/auth_controller.dart';

Widget buildProfileTile(AuthController authController) {
  return Positioned(
    top: Get.height * 0.08,
    left: Get.width * 0.06,
    right: Get.width * 0.06,
    child: Obx(
      () => authController.myUser.value.username == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: Get.width * 0.15,
                    height: Get.width * 0.15,
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
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Good Morning  ",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14)),
                            TextSpan(
                                text:
                                    authController.myUser.value.username == null
                                        ? "Mark"
                                        : authController.myUser.value.username!,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text("Welcome to the Intervention App",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
    ),
  );
}
