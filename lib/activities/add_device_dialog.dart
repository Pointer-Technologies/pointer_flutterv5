import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app_localizations.dart';
import '../components/input_text_field.dart';
import '../constants.dart' as Constants;


/// This activity is presented as a Scaffold,
/// but given to the Navigator as a full-screen dialog,
/// to make it easier to dismiss and more lightweight.
// ignore: must_be_immutable
class AddDeviceDialog extends StatelessWidget{
  AddDeviceDialog({Key key}) : super(key: key);

  List devices = new List();

  AddDeviceDialog.n({Key key,List devices}) : super(key: key){
    this.devices = devices;
  }

  TextEditingController editTextName = TextEditingController();
  TextEditingController editTextCode = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("ADD_DEVICE_TITLE")),
        elevation: 0,
      ),

      body:
        Center(
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                InputTextField.n(AppLocalizations.of(context).translate("NAME"),editTextName),

                // Hint below the device name input box.
                Text(
                  AppLocalizations.of(context).translate("DEVICE_NAME_HINT"),
                  style: TextStyle(
                    color: Constants.ACCENT_COLOR,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),

               InputTextField.n(AppLocalizations.of(context).translate("SERIAL_NUMBER"),editTextCode),

                // Hint below the serial number input box.
                Text(
                    AppLocalizations.of(context).translate("SERIAL_NUMBER_HINT"),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: Constants.ACCENT_COLOR,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  )
                ),

                SizedBox(height: 20),

                RaisedButton(
                  child: Text(AppLocalizations.of(context).translate("ADD")),
                  color: Constants.ACCENT_COLOR,
                  textColor: Colors.white,
                  elevation: Constants.BUTTON_ELEVATION,
                  onPressed: () async {
                    bool success = await newTry();
                    if(success){
                      Fluttertoast.showToast(msg: "Device successfully added.");
                      Navigator.pop(context);
                    }
                    else{
                      Fluttertoast.showToast(msg: "Please try again.");
                    }
                  }
                ),
              ]
            )
        )
    );
  }


  /// Checks the validity of the device that is going to be added.
  /// Checks for appropriate name length and an already existing name.
  /// Returns False if the user has to try again.
   Future<bool> newTry() async{
    if(editTextCode.text.length != 8){
      Fluttertoast.showToast(msg: "8-digit code is not valid.");
      return Future.value(false);
    }

    else if(editTextName.text.length < 3 || editTextName.text.length > 20){
      Fluttertoast.showToast(msg: "Device's name must be between 3 and 20 characters long.");
      return Future.value(false);
    }

    else{
      bool nameAlreadyExists = nameExists();
      if(nameAlreadyExists){
        Fluttertoast.showToast(msg: "Device's name already exists.");
        return Future.value(false);
      }
      else{
        bool successfullyAdded = await addData();
        if(successfullyAdded){
          return Future.value(true);
        }
        else
          return Future.value(false);
      }
    }
  }


  /// Checks if the name to be given already exists.
  bool nameExists(){
    for(int i = 0 ; i < devices.length; i++){
      if(editTextName.text.trim() == devices[i].name.toString().trim())
        return true;
    }
    return false;
  }


  /// Adds device to the user's device collection.
  Future<bool> addData() async{
    try{
      log("Reached here");
      Map<String, dynamic> device = {"name": editTextName.text, "8-digit code": editTextCode.text, "icon": 200};
      CollectionReference collectionReference = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("devices");
      await collectionReference.add(device);
      return Future.value(true);
    }
    catch(e){
      print(e.toString());
      return Future.value(false);
    }
  }

  
}
