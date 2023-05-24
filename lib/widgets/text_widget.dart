import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textWidget({required String text,double fontsize = 12,FontWeight fontWeight = FontWeight.normal}){
  return Text(
    text,
    style: GoogleFonts.poppins(fontSize: fontsize,fontWeight: fontWeight),

  );
}