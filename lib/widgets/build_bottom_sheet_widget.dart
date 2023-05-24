import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';

import 'package:google_places_for_flutter/google_places_for_flutter.dart';

String dropdownValue = 'Firefighter';
String dropdownValueTypeFirefighter = 'A fire';
String dropdownValueStateFirefighter='normal';
String dropdownValueTypePoliceOfficer = 'theft';
String dropdownValueStatePoliceOfficer='normal';
TextEditingController descriptionControllerPoliceOfficer = TextEditingController();
TextEditingController descriptionControllerFirefighter = TextEditingController();
TextEditingController  positionInterventionController =TextEditingController();
bool showDescriptionFieldPoliceOfficer = false;
bool showDescriptionFieldFirefighter = false;
bool isCheckedCurrentLocation=true;
late Position position;
late String apiKey;
late GooglePlace googlePlace;
late LatLng destination;
late List<AutocompletePrediction> predictions=[];
Widget buildBottomSheet(BuildContext context) {
  apiKey='AIzaSyBIRvT37fhcOSIcTJCVt8nIyNlMPeEB-LY';
  googlePlace=GooglePlace(apiKey);
  return Align(
    alignment: Alignment.bottomCenter,
    child: GestureDetector(
      onTap: () {
        buildSourceSheetPositionOfInterventation(context);
      },
      child: Container(
        width: Get.width * 0.8,
        height: Get.height*0.055,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            "Declaration Of Intervantaion",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
Future<Position> getUserCurrentLocation() async {
  await Geolocator.requestPermission()
      .then((value) {})
      .onError((error, stackTrace) async {
    await Geolocator.requestPermission();
    print("ERROR" + error.toString());
  });
  return await Geolocator.getCurrentPosition();
}

 showGoogleAutoComplete(String value) async {
  var result =await googlePlace.autocomplete.get(value);
  if (result != null && result.predictions != null )
  predictions=result!.predictions!;

}
void buildSourceSheetPositionOfInterventation(BuildContext context) {


  Get.bottomSheet(Container(
    width: Get.width,
    height: Get.height * 0.33,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "choose position of intervention",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      onChanged: (bool? value){
                        isCheckedCurrentLocation=value!;
                        Get.back();
                        buildSourceSheetPositionOfInterventation(context);
                      },
                      value: isCheckedCurrentLocation,
                    ),
                      Expanded(
                        child: Visibility(

                          visible: !isCheckedCurrentLocation,
                          child:TextFormField(
                            onChanged:(String? value){
                              showGoogleAutoComplete(value!);
                              debugPrint(predictions.toString());
                            },


                          ) )

                        ),

                    Expanded(
                        child: Visibility(

                            visible: isCheckedCurrentLocation,
                            child:Text("Select current position") )

                    ),

                  ],
                )
              ),
            ],
          ),
        ),


        const SizedBox(height: 20,),
        Container(
          width: Get.width,
          height: Get.height*0.06,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: () async {
              if (isCheckedCurrentLocation) {
                 position=await getUserCurrentLocation();
                buildSourceSheetTypeInterventation();
              } else {

              }
            },
            child: const Text('Next'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
          ),
        ),

      ],
    ),
  ));
}



void buildSourceSheetTypeInterventation() {


  Get.bottomSheet(Container(
    width: Get.width,
    height: Get.height * 0.33,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "À qui š'adresse cette déclaration?",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {

                    dropdownValue = newValue!;
                    Get.back();
                    buildSourceSheetTypeInterventation();
                  },
                  items: <String>['Firefighter', 'Police officer']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_downward_outlined,color: Colors.green,),
            ],
          ),
        ),


        const SizedBox(height: 20,),
        Container(
          width: Get.width,
          height: Get.height*0.06,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: () {
              if (dropdownValue == 'Firefighter') {
                dropdownValueTypeFirefighter='A fire';
                showDescriptionFieldFirefighter=false;
                buildSourceSheetFormFirefighter(showDescriptionFieldFirefighter);
              } else if (dropdownValue == 'Police officer') {
                dropdownValueTypePoliceOfficer = 'theft';
                showDescriptionFieldPoliceOfficer=false;
                buildSourceSheetFormPoliceOfficer(showDescriptionFieldPoliceOfficer);
              }
            },
            child: const Text('Next'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
          ),
        ),

      ],
    ),
  ));
}




void buildSourceSheetFormFirefighter(bool showDescriptionFieldFirefighter) {


  Get.bottomSheet(Container(
    width: Get.width,
    height: showDescriptionFieldFirefighter ? Get.height * 0.9 : Get.height * 0.5,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Statement For Firefighter",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Intervention Type",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValueTypeFirefighter,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {

                    if (newValue == "something else") {

                      showDescriptionFieldFirefighter= true;

                    } else {

                      showDescriptionFieldFirefighter = false;

                    }
                    dropdownValueTypeFirefighter = newValue!;
                    Get.back();
                    buildSourceSheetFormFirefighter(showDescriptionFieldFirefighter);



                  },
                  items: <String>['A fire', 'Gas' ,'Traffic Accident','something else']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_downward_outlined,color: Colors.green,),
            ],
          ),
        ),
        SizedBox(height: 5,),
        if (showDescriptionFieldFirefighter)
          Container(
            width: Get.width,
            height: Get.height * 0.08,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              controller: descriptionControllerPoliceOfficer,
              decoration: const InputDecoration(
                hintText: "Enter description",
                border: InputBorder.none,
              ),
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Accident Situation",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValueStateFirefighter,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {


                    dropdownValueStateFirefighter = newValue!;
                    Get.back();
                    buildSourceSheetFormFirefighter(showDescriptionFieldFirefighter);

                  },
                  items: <String>['normal', 'Difficult' ,'Very difficult']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_downward_outlined,color: Colors.green,),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.06,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: () {
              //selon les inpute "dropdownValueState" et "dropdownValueType" afficter vers bon recherche de pompier
            },
            child: const Text('Confirmation'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
          ),
        ),
      ],
    ),
  ));
}


void buildSourceSheetFormPoliceOfficer(bool showDescriptionField) {

  Get.bottomSheet(Container(
    width: Get.width,
    height: showDescriptionField ? Get.height * 0.9 : Get.height * 0.5,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Statement For Police Officer",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Intervention Type",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: Get.width,
          height: Get.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValueTypePoliceOfficer,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {
                    if (newValue == "something else") {

                        showDescriptionFieldPoliceOfficer = true;

                    } else {

                        showDescriptionFieldPoliceOfficer = false;

                    }
                    dropdownValueTypePoliceOfficer = newValue!;
                    Get.back();
                    buildSourceSheetFormPoliceOfficer(showDescriptionFieldPoliceOfficer);

                  },
                  items: <String>['fighting', 'theft', 'something else']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_downward_outlined, color: Colors.green),
            ],
          ),
        ),
        SizedBox(height: 5,),
        if (showDescriptionFieldPoliceOfficer)
          Container(
            width: Get.width,
            height: Get.height * 0.08,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              controller: descriptionControllerPoliceOfficer,
              decoration: const InputDecoration(
                hintText: "Enter description",
                border: InputBorder.none,
              ),
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Accident Situation",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValueStatePoliceOfficer,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {


                    dropdownValueStatePoliceOfficer = newValue!;
                    Get.back();
                    buildSourceSheetFormPoliceOfficer(showDescriptionField);

                  },
                  items: <String>['normal', 'Difficult' ,'Very difficult']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_downward_outlined,color: Colors.green,),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          height: Get.height*0.06,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 4,
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: () {

            },
            child: const Text('Confirmation'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
          ),
        ),
      ],
    ),
  ));
}
